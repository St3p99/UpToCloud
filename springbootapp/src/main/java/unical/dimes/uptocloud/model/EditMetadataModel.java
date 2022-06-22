package unical.dimes.uptocloud.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.List;

@Getter
@Setter
@ToString
public class EditMetadataModel {
    @JsonProperty("filename")
    private String filename;

    @JsonProperty("description")
    private String description;

    @JsonProperty("tags")
    private List<String> tags;




}
