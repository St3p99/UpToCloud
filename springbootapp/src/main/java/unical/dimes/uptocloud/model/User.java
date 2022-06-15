package unical.dimes.uptocloud.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import javax.validation.constraints.Email;
import javax.validation.constraints.NotNull;
import java.util.List;
import java.util.Set;

/* lombok auto-generated code */
@Getter
@Setter
@EqualsAndHashCode
@ToString
/* lombok auto-generated code */

@Entity
@Table(
        name = "users",
        schema = "public"
)
public class User {
    /*     Utilizzata diagramma di tipo 3 per la generalizzazione (Non si materializza l'entità padre User)
    *    - si perde l'esclusività
    *    - va bene perchè User non ha relazioni
    * */

//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    @Column(name = "id", nullable = false)
//    private Long id;

    @Id
    @Column(name = "id")
    private String id;

    @NotNull
    @Email
    @Column(name = "email", nullable = false, unique = true)
    private String email;

    @NotNull
    @Column(name = "username", nullable = false, unique = true, length = 30)
    private String username;

    @JsonIgnore
    @Column(name = "container_name")
    private String containerName;

    @EqualsAndHashCode.Exclude
    @ToString.Exclude
    @JsonIgnore
    @OneToMany(mappedBy = "owner", cascade = CascadeType.ALL)
    @Column(insertable = false, updatable = false)
    private List<Document> documentsOwned;

    @ToString.Exclude
    @JsonIgnore
    @ManyToMany(mappedBy = "readers", cascade = CascadeType.ALL)
    @Column(insertable = false, updatable = false)
    private Set<Document> documentsReadable;
}
