package org.egov.waterconnection.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class InactiveConsumerReportData {

    @JsonProperty("tenantName")
    private String tenantName = null;

    @JsonProperty("connectionno")
    private String connectionno=null;

    @JsonProperty("status")
    private String status=null;

    @JsonProperty("inactiveDate")
    private Long inactiveDate = null;

    @JsonProperty("inactivatedByUuid")
    private String inactivatedByUuid=null;

    @JsonProperty("inactivatedByName")
    private String inactivatedByName=null;

}
