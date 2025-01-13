package org.egov.naljalcustomisation.web.model;

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
