package digit.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.JsonNode;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.egov.common.contract.models.AuditDetails;
import org.springframework.validation.annotation.Validated;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

/**
 * Bind the request meta data(RequestInfo) and Schema defination
 */
@Schema(description = "Bind the request meta data(RequestInfo) and Schema defination")
@Validated
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Mdms {

    @JsonProperty("id")
    @Size(min = 2, max = 64)
    private String id;

    @JsonProperty("tenantId")
    @NotNull
    @Size(min = 2, max = 128)
    private String tenantId = null;

    @JsonProperty("schemaCode")
    @NotNull
    @Size(min = 2, max = 128)
    private String schemaCode = null;

    @JsonProperty("uniqueIdentifier")
    @Size(min = 1, max = 128)
    private String uniqueIdentifier = null;

    @JsonProperty("data")
    @NotNull
    private JsonNode data = null;

    @JsonProperty("isActive")
    private Boolean isActive = true;

    @JsonProperty("auditDetails")
    @Valid
    private AuditDetails auditDetails = null;

}