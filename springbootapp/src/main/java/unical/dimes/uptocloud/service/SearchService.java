package unical.dimes.uptocloud.service;

import com.azure.search.documents.SearchClient;
import com.azure.search.documents.implementation.models.SearchResult;
import com.azure.search.documents.indexes.SearchIndexClient;
import com.azure.search.documents.indexes.SearchIndexerClient;
import com.azure.search.documents.indexes.SearchIndexerDataSources;
import com.azure.search.documents.indexes.models.SearchIndexer;
import com.azure.search.documents.indexes.models.SearchIndexerDataSourceConnection;
import com.azure.search.documents.util.SearchPagedIterable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class SearchService {
    @Value("${azure.search.serviceName}")
    private String serviceName;
    @Value("${azure.search.serviceAdminKey}")
    private String adminKey;
    @Value("${azure.storage.connString}")
    private String blobConnectStr;

    @Value("${azure.search.indexName}")
    private String indexName;

    @Value("${azure.search.datasourceBaseName}")
    private String datasourceBaseName;
    @Value("${azure.search.indexerBaseName}")
    private String indexerBaseName;

    private final SearchIndexClient searchIndexClient;
    private final SearchClient searchClient;
    private final SearchIndexerClient searchIndexerClient;

    @Autowired
    public SearchService(SearchIndexClient searchIndexClient, SearchClient searchClient, SearchIndexerClient searchIndexerClient) {
        this.searchIndexClient = searchIndexClient;
        this.searchIndexerClient = searchIndexerClient;
        this.searchClient = searchClient;
    }


//    public Object searchText(String text){
//    queryType=full&search=/.*vuoto.*/&searchFields=tags
//        SearchPagedIterable searchPagedIterable  = searchClient.search(text);
////        searchPagedIterable.forEach(
////                searchResult -> {
////                    searchResult.getHighlights().get("id");
////                }
////        );
//        searchPagedIterable.
//        return null;
//    }




    public SearchIndexer getOrCreateAndGetSearchIndexer(String containerName){
        SearchIndexer indexer = null;
        try{
            indexer = searchIndexerClient.getIndexer(indexerBaseName+containerName);
        }catch (Exception e){
            indexer = searchIndexerClient.createIndexer(
                    new SearchIndexer(
                            indexerBaseName+containerName, datasourceBaseName+containerName, indexName
                    ));

        }finally {
            return indexer;
        }
    }

    public SearchIndexerDataSourceConnection getOrCreateAndGetDataSourceConnection(String containerName){
        SearchIndexerDataSourceConnection datasource = null;
        try{
            datasource = searchIndexerClient.getDataSourceConnection(datasourceBaseName+containerName);
        }catch (Exception e){
            datasource = searchIndexerClient.createDataSourceConnection(
                    SearchIndexerDataSources.createFromAzureBlobStorage(datasourceBaseName+containerName, blobConnectStr, containerName));

        }finally {
            return datasource;
        }
    }
}
