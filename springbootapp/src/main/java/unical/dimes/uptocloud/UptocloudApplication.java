package unical.dimes.uptocloud;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import unical.dimes.uptocloud.configs.AzureSearchConfig;
import unical.dimes.uptocloud.configs.FileStorageProperties;
import unical.dimes.uptocloud.repository.UserRepository;
import unical.dimes.uptocloud.service.SearchService;

import javax.annotation.PostConstruct;
import java.util.TimeZone;

@SpringBootApplication
@EntityScan(basePackages = {"unical.dimes.uptocloud.model"})  // scan JPA entities
@EnableConfigurationProperties({FileStorageProperties.class})
public class UptocloudApplication {


    public static void main(String[] args) {
        SpringApplication.run(UptocloudApplication.class, args);

    }

    @PostConstruct
    public void init(){
        // Setting Spring Boot SetTimeZone
        TimeZone.setDefault(TimeZone.getTimeZone("UTC"));
    }

}



