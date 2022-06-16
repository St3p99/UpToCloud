package unical.dimes.uptocloud.service;

import com.azure.storage.blob.BlobClient;
import com.azure.storage.blob.BlobContainerClient;
import com.azure.storage.blob.BlobServiceClient;
import com.azure.storage.blob.specialized.BlockBlobClient;
import org.apache.commons.io.FileUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import unical.dimes.uptocloud.configs.FileStorageProperties;
import unical.dimes.uptocloud.model.*;
import unical.dimes.uptocloud.repository.DocumentMetadataRepository;
import unical.dimes.uptocloud.repository.DocumentRepository;
import unical.dimes.uptocloud.repository.TagRepository;
import unical.dimes.uptocloud.support.exception.FileSizeExceededException;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;
import unical.dimes.uptocloud.support.exception.UnauthorizedUserException;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;
import java.util.logging.Level;
import java.util.logging.Logger;

@Service
public class FileService {
    Logger logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);
    private final BlobServiceClient blobServiceClient;
    private final DocumentRepository documentRepository;
    private final TagRepository tagRepository;
    private final DocumentService documentService;
    private final DocumentMetadataService documentMetadataService;
    private final UserService userService;
    private final Path fileStorageLocation;
    private final DocumentMetadataRepository documentMetadataRepository;
    private final SearchService searchService;
    @Value("${max-file-size}")
    private long max_file_size;
    @Autowired
    public FileService(BlobServiceClient blobServiceClient, TagRepository tagRepository, FileStorageProperties fileStorageProperties, DocumentRepository documentRepository, DocumentService documentService, DocumentMetadataService documentMetadataService, UserService userService, DocumentMetadataRepository documentMetadataRepository, SearchService searchService) {
        this.blobServiceClient = blobServiceClient;
        this.tagRepository = tagRepository;
        this.documentRepository = documentRepository;
        this.documentService = documentService;
        this.documentMetadataService = documentMetadataService;
        this.userService = userService;
        fileStorageLocation = Path.of(fileStorageProperties.getUploadDir());
        this.documentMetadataRepository = documentMetadataRepository;
        this.searchService = searchService;
        try {
            // creates directory/directories, if directory already exists, it will not throw exception
            Files.createDirectories(fileStorageLocation);
        } catch (IOException e) {
            logger.severe("Could not create the directory where the uploaded files will be stored.");
        }

    }

    public Document uploadDocument(String userID, MultipartFile file) throws Exception {
        if(file.getSize() > FileUtils.ONE_MB*max_file_size)
            throw new FileSizeExceededException();


        User u;
        Document d = new Document();
        DocumentMetadata dm;
        boolean success = false;
        try {
            u = userService.getById(userID);
            d.setOwner(u);
            d.setName( file.getOriginalFilename());
            documentRepository.save(d); // Save to generate docID

            String mimeType = file.getContentType();
            dm = new DocumentMetadata(d);
            dm.setFileType(mimeType);
            dm.setFileSize(file.getSize());

            BlockBlobClient blockBlobClient = getOrCreateAndGetContainerByOwner(u).getBlobClient(d.getId().toString()).getBlockBlobClient();

            // upload file to azure blob storage
            blockBlobClient.upload(new BufferedInputStream(file.getInputStream()), file.getSize(), true);
            logger.log(Level.INFO, () -> String.format("File %s uploaded in blob '%s'",  file.getOriginalFilename(), blockBlobClient.getBlobName()));

            d.setResourceUrl(blockBlobClient.getBlobUrl());

            Map<String, String> blobMetadata = new HashMap<>();

            blobMetadata.put(MetadataCategory.FILE_NAME.toString(),  file.getOriginalFilename());
            blobMetadata.put(MetadataCategory.FILE_TYPE.toString(), mimeType);
            blobMetadata.put(MetadataCategory.ID.toString(), d.getId().toString());
            blockBlobClient.setMetadata(blobMetadata);

            success = true;
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        } catch (IOException e) {
            logger.severe(e.toString());
            documentRepository.delete(d);
            throw new IOException();
        } catch (Exception e){
            logger.severe(e.toString());
            throw new Exception();
        } finally {
            if(!success) documentRepository.delete(d);
        }
        documentMetadataRepository.save(dm);
        return documentRepository.save(d);
    }
    public Document setMetadata(String userID, Long docID, String filename,
                            String description, Set<String> tagsName)
            throws IllegalArgumentException, ResourceNotFoundException, UnauthorizedUserException {
        User u;
        Document d;
        DocumentMetadata dm;
        List<Tag> tags = new LinkedList<>();
        try {
            u = userService.getById(userID);
            d = documentService.getById(docID);
            dm = documentMetadataService.getByDocument(d);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!d.getOwner().equals(u)){
            logger.warning("User doesn't have permission for this document to set metadata");
            throw new UnauthorizedUserException();
        }

        BlockBlobClient blockBlobClient = getOrCreateAndGetContainerByOwner(u).getBlobClient(d.getId().toString()).getBlockBlobClient();
        Map<String, String> blobMetadata = blockBlobClient.getProperties().getMetadata();

        if(filename!=null){
            d.setName(filename);
            blobMetadata.put(MetadataCategory.FILE_NAME.toString(), filename);
        }

        if(description!=null){
            dm.setDescription(description);
            blobMetadata.put(MetadataCategory.DESCRIPTION.toString(), description);
        }

        if(tagsName!=null && !tagsName.isEmpty()){
            StringBuilder sb = new StringBuilder();
            Tag t;
            for (String tagName: tagsName) {
                Optional<Tag> ot = tagRepository.findByName(tagName);
                if( ot.isPresent() ) t = ot.get();
                else{
                    t = new Tag(tagName);
                    tagRepository.save(t);
                }
                tags.add(t);
                sb.append(tagName).append(":");
            }
            dm.setTags(tags);
            blobMetadata.put(MetadataCategory.TAGS.toString(), sb.toString());
        }

        blockBlobClient.setMetadata(blobMetadata);
        documentMetadataRepository.save(dm);
        return documentRepository.save(d);
    }

    public DocumentMetadata getMetadata(String userID, Long docID)
            throws ResourceNotFoundException, UnauthorizedUserException{
        User u;
        Document d;

        try {
            u = userService.getById(userID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!canRead(u, d)){
            logger.warning("User can't read");
            throw new UnauthorizedUserException();
        }

        return d.getMetadata();
    }

    public Map<String, String> getBlobMetadata(String userID, Long docID)
            throws ResourceNotFoundException, UnauthorizedUserException{
        User u;
        Document d;

        try {
            u = userService.getById(userID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!canRead(u, d)){
            logger.warning("User can't read");
            throw new UnauthorizedUserException();
        }
        return getOrCreateAndGetContainerByOwner(u)
                .getBlobClient(d.getId().toString())
                .getBlockBlobClient()
                .getProperties()
                .getMetadata();
    }

    public Document downloadDocument(String userID, Long docID)
            throws ResourceNotFoundException,IOException, UnauthorizedUserException {
        User u;
        Document d;

        try {
            u = userService.getById(userID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!canRead(u, d)){
            logger.warning("User can't read");
            throw new UnauthorizedUserException();
        }

        BlobContainerClient blobContainerClient = getOrCreateAndGetContainerByOwner(d.getOwner());
        // Get a reference to a blob
        BlobClient blobClient = blobContainerClient.getBlobClient(d.getId().toString());
        logger.info("blobClient OK");
        try {
            String tempFilePath = getFileStorageLocation() + "/" + docID;
            Files.deleteIfExists(Paths.get(tempFilePath));
            // download file from azure blob storage to a file
            logger.info("Trying to download file from blob");
            blobClient.downloadToFile(new File(tempFilePath).getPath());
            logger.info("File downloaded");
        } catch (IOException e) {
            logger.severe(()->String.format("Error while processing file\nException: %s", e));
            throw e;
        }
        return d;
    }

    private boolean canRead(User u, Document d) {
        return d.getOwner().equals(u)
                || d.getReaders().contains(u);
    }

    public BlobContainerClient getOrCreateAndGetContainerByOwner(User u){
        BlobContainerClient c = blobServiceClient.getBlobContainerClient(u.getContainerName());
        if(c.exists()) return c;
        else return createContainer(u);
    }

    private BlobContainerClient createContainer(User u){
        //Create a unique name for the container
        String containerName = u.getUsername() + java.util.UUID.randomUUID();
        u.setContainerName(containerName);

        // Create the container and return a container client object
        BlobContainerClient blobContainerClient =blobServiceClient.createBlobContainer(containerName);

        // TODO: spostare dove vanno spostati
        searchService.getOrCreateAndGetDataSourceConnection(containerName);
        searchService.getOrCreateAndGetSearchIndexer(containerName);
        return blobContainerClient;
    }

    public Path getFileStorageLocation() {
        try {
            Files.createDirectories(this.fileStorageLocation);
        } catch (IOException e) {
            logger.severe("Could not create the directory where the uploaded file will be stored.");
        }
        return fileStorageLocation;
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public void addReader(String ownerID, String readerID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException {
        User owner, reader;
        Document d;

        try {
            owner = userService.getById(ownerID);
            reader = userService.getById(readerID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();

        d.addReader(reader);
        documentRepository.save(d);
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public void addReaders(String ownerID, List<String> readersID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException{
        User owner;
        List<User> readers = new LinkedList<>();
        Document d;

        try {
            owner = userService.getById(ownerID);
            for (String readerID: readersID) {
                readers.add(userService.getById(readerID));
            }
        
            d = documentService.getById(docID);
            if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();
            d.addReaders(readers);
    
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }
        documentRepository.save(d);
    }

        @Transactional(propagation = Propagation.REQUIRED)
    public void removeReaders(String ownerID, List<String> readersID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException{
        User owner;
        List<User> readers = new LinkedList<>();
        Document d;

        try {
            owner = userService.getById(ownerID);
            for (String readerID: readersID) {
                readers.add(userService.getById(readerID));
            }
            d = documentService.getById(docID);
            if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();
            d.removeReaders(readers);

        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }
        documentRepository.save(d);
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public void removeReader(String ownerID, String readerID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException{
        User owner, reader;
        Document d;

        try {
            owner = userService.getById(ownerID);
            reader = userService.getById(readerID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();

        d.removeReader(reader);
        documentRepository.save(d);
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public List<User> getReadersByDoc(String ownerID, Long docID) throws UnauthorizedUserException, ResourceNotFoundException{
        User owner;
        Document d;

        try {
            owner = userService.getById(ownerID);
            d = documentService.getById(docID);
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        if(!d.getOwner().equals(owner)) throw new UnauthorizedUserException();

        return d.getReaders();
    }

    @Transactional(propagation = Propagation.REQUIRED)
    public List<User> getShareSuggestions(String ownerID) throws ResourceNotFoundException{
        User loggedUser;
        List<User> suggestions = new LinkedList<>();
        try {
            loggedUser = userService.getById(ownerID);
            for (Document d: loggedUser.getDocumentsOwned()) {
                suggestions.addAll(d.getReaders());
            }
        }catch (ResourceNotFoundException e){
            logger.warning(e.toString());
            throw e;
        }

        return suggestions;
    }
}
