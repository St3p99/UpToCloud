package unical.dimes.uptocloud.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import java.util.List;

@Getter
@Setter
@ToString
public class EditMetadataModel {
    private String filename;
    private String description;
    private List<String> tags;
}
