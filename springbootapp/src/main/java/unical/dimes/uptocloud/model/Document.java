package unical.dimes.uptocloud.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import javax.validation.constraints.NotNull;
import java.util.List;


/* lombok auto-generated code */
@Getter
@Setter
@EqualsAndHashCode
@ToString
/* lombok auto-generated code */

@Entity
@Table(
        name = "document",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "document_resource_name_id_unique",
                        columnNames = {"name", "owner_id"}
                )
        },
        schema = "public"
)
public class Document {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id", nullable = false)
    private Long id;

    @Column(name = "name")
    private String name;

    @JsonIgnore
    @Column(name = "resource_url")
    private String resourceUrl;

    @NotNull
    @ManyToOne
    @JoinColumn(name = "owner_id", nullable = false)
    private User owner;

    @ManyToMany(cascade = CascadeType.ALL)
    @JoinTable(
            name = "reading_permissions",
            joinColumns = { @JoinColumn(name = "document_id") },
            inverseJoinColumns = { @JoinColumn(name = "reader_id") },

            schema = "public"
    )
    private List<User> readers;

    @OneToOne(mappedBy = "document")
    private DocumentMetadata metadata;

    public void addReader(User reader){
        if(!this.readers.contains(reader))
            this.readers.add(reader);
    }

    public void addReaders(List<User> readers){
        for (User reader: readers) {
            if(!this.readers.contains(reader)) this.readers.add(reader);
        }
    }

    public void removeReader(User reader){
        this.readers.remove(reader);
    }

    public void removeReaders(List<User> readers){
        this.readers.removeAll(readers);
    }
}
