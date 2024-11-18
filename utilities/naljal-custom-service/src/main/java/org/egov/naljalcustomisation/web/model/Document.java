package org.egov.naljalcustomisation.web.model;


import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
@EqualsAndHashCode(of= {"fileStoreId","documentUid","id"})
public class Document {


    @JsonProperty("id")
    private String id ;

    @JsonProperty("documentType")
    @NotNull

    private String documentType ;

    @JsonProperty("fileStoreId")
    @NotNull

    private String fileStoreId ;


    @JsonProperty("documentUid")
    private String documentUid ;

    @JsonProperty("auditDetails")
    private AuditDetails auditDetails;

    @JsonProperty("status")
    private Status status;
}


