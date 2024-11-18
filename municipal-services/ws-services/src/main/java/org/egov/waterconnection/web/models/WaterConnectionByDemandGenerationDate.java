package org.egov.waterconnection.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Builder
public class WaterConnectionByDemandGenerationDate {
    @JsonProperty("count")
    Integer count;
    @JsonProperty("taxperiodto")
    private Long date;
}
