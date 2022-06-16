package unical.dimes.uptocloud.controller;

import io.swagger.v3.oas.annotations.Operation;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import unical.dimes.uptocloud.model.Document;
import unical.dimes.uptocloud.model.User;
import unical.dimes.uptocloud.model.DocumentMetadata;
import unical.dimes.uptocloud.service.FileService;
import unical.dimes.uptocloud.support.exception.FileSizeExceededException;
import unical.dimes.uptocloud.support.exception.ResourceNotFoundException;
import unical.dimes.uptocloud.support.exception.UnauthorizedUserException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.List;
import java.util.Set;

@RestController
@RequestMapping("${base-url}/files")
public class FileController {

    private final FileService fileService;

    @Value("${max-file-size}")
    private long max_file_size;

    @Autowired
    public FileController(FileService fileService) {
        this.fileService = fileService;
    }

    @Operation(method = "uploadFile", summary = "Upload a file as a blob in the user's container")
    @PreAuthorize("hasAuthority('user')")
    @PostMapping(value = "/upload", consumes = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<?> uploadFile(@AuthenticationPrincipal Jwt principal, @RequestParam("file") MultipartFile file) {
        try {
            if (fileService.uploadDocument(principal.getSubject(), file) != null) {
                return ResponseEntity.status(200).build();
            } else {
                return ResponseEntity.ok("Error");
            }
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (FileSizeExceededException e) {
            return ResponseEntity.badRequest().body("File size exceeded -- FILE SIZE LIMIT: " + max_file_size + "MB");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }

//    @Operation(method = "uploadFileAndMetadata", summary = "Upload a file as a blob in the user's container")
//    @PreAuthorize("hasAuthority('user')")
//    @PostMapping(value = "/upload_w_metadata", consumes = {  MediaType.APPLICATION_JSON_VALUE, MediaType.MULTIPART_FORM_DATA_VALUE })
//    public ResponseEntity<?> uploadFileAndMetadata(@AuthenticationPrincipal Jwt principal,
//                                                   @RequestPart("metadata") Map<String, String> metadata,
//                                                   @RequestPart("file") MultipartFile file) {
//        try {
//            if (fileService.uploadDocumentAndMetadata(principal.getSubject(), file, metadata) != null) {
//                return ResponseEntity.status(200).build();
//            }
//            else{
//                return ResponseEntity.ok("Error");
//            }
//        }
//        catch (ResourceNotFoundException e) {
//            return ResponseEntity.notFound().build();
//        } catch (IOException e) {
//            return ResponseEntity.internalServerError().build();
//        }
//    }

    @Operation(method = "setMetadata", summary = "Set metadata for the specified document")
    @PreAuthorize("hasAuthority('user')")
    @PostMapping(value = "/set_metadata/{doc_id}", consumes = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> setMetadata(@AuthenticationPrincipal Jwt principal,
                                         @PathVariable("doc_id") Long docID,
                                         @RequestParam(value = "filename", required = false) String filename,
                                         @RequestParam(value = "description", required = false) String description,
                                         @RequestParam(value = "tags", required = false) Set<String> tags) {
        try {
            return ResponseEntity.status(200).body(
                    fileService.setMetadata(
                            principal.getSubject(), docID, filename, description, tags
                    )
            );
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User must be the owner of the specified document");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    "Metadata null or wrong format");
        }
    }

    @Operation(method = "getMetadata", summary = "Get metadata for the specified document")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/get_metadata/{doc_id}", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> getMetadata(@AuthenticationPrincipal Jwt principal,
                                         @PathVariable("doc_id") Long docID) {
        try {
            DocumentMetadata metadata = fileService.getMetadata(principal.getSubject(), docID);
            return ResponseEntity.status(200)
                    .body(metadata);
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User must have read permissions");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    "Metadata null or wrong format");
        }
    }

    @Operation(method = "getBlobMetadata", summary = "Get Blob metadata for the specified document")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/get_blob_metadata/{doc_id}", produces = {MediaType.APPLICATION_JSON_VALUE})
    public ResponseEntity<?> getBlobMetadata(@AuthenticationPrincipal Jwt principal,
                                             @PathVariable("doc_id") Long docID) {
        try {
            return ResponseEntity.status(200)
                    .body(fileService.getBlobMetadata(principal.getSubject(), docID));
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User must have read permissions");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                    "Metadata null or wrong format");
        }
    }

    @Operation(method = "downloadFile", summary = "Download the specified file")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/download/", produces = {MediaType.MULTIPART_FORM_DATA_VALUE})
    public ResponseEntity<?> downloadFile(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID) {
        try {
            Document d = fileService.downloadDocument(principal.getSubject(), docID);
            String tempFilePath = fileService.getFileStorageLocation() + "/" + docID;
            if (d != null) {
                // readAllBytes -> LIMIT 2GB
                final ByteArrayResource resource = new ByteArrayResource(Files.readAllBytes(Paths.get(tempFilePath)));
                return ResponseEntity.status(200).contentLength(resource.contentLength()).body(resource);
            } else {
                return ResponseEntity.ok("Error");
            }
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("User must have read permissions to download the file");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(method = "addReader", summary = "Add a reader to the specified file")
    @PreAuthorize("hasAuthority('user')")
    @PutMapping(value = "/add-reader")
    public ResponseEntity<?> addReader(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID, @RequestParam("reader_id") String readerID) {
        try {
            fileService.addReader(principal.getSubject(), readerID, docID);
            return ResponseEntity.status(200).build();
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "addReaders", summary = "Add readers to the specified file")
    @PreAuthorize("hasAuthority('user')")
    @PutMapping(value = "/add-readers")
    public ResponseEntity<?> addReaders(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID, @RequestParam("readers_id") List<String> readersID) {
        try {
            fileService.addReaders(principal.getSubject(), readersID, docID);
            return ResponseEntity.status(200).build();

        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "removeReader", summary = "Remove a reader from the specified file")
    @PreAuthorize("hasAuthority('user')")
    @PutMapping(value = "/remove-reader")
    public ResponseEntity<?> removeReader(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID, @RequestParam("reader_id") String readerID) {
        try {
            fileService.removeReader(principal.getSubject(), readerID, docID);
            return ResponseEntity.status(200).build();
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "removeReaders", summary = "Remove readers from the specified file")
    @PreAuthorize("hasAuthority('user')")
    @PutMapping(value = "/remove-readers")
    public ResponseEntity<?> removeReaders(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID, @RequestParam("readers_id") List<String> readersID) {
        try {
            fileService.removeReaders(principal.getSubject(), readersID, docID);
            return ResponseEntity.status(200).build();

        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "getReadersByDoc", summary = "Get readers of specified document")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/readersByDoc")
    public ResponseEntity<?> getReadersByDoc(@AuthenticationPrincipal Jwt principal, @RequestParam("file_id") Long docID) {
        try {
            List<User> result = fileService.getReadersByDoc(principal.getSubject(), docID);
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.status(200).body(result);
        } catch (UnauthorizedUserException e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only owner's file can manage readers");
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }

    @Operation(method = "getShareSuggestions", summary = "Get users that are readers of at least one document owned by logged user")
    @PreAuthorize("hasAuthority('user')")
    @GetMapping(value = "/share-suggestions")
    public ResponseEntity<?> getShareSuggestions(@AuthenticationPrincipal Jwt principal) {
        try {
            List<User> result = fileService.getShareSuggestions(principal.getSubject());
            if (result.size() <= 0)
                return ResponseEntity.noContent().build();
            return ResponseEntity.status(200).body(result);
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        }
    }
}