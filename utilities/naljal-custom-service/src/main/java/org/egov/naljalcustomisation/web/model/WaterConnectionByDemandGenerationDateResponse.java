package org.egov.naljalcustomisation.web.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.util.List;
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Builder
public class WaterConnectionByDemandGenerationDateResponse {

    @JsonProperty("WaterConnectionsDemandGenerated")
    List<WaterConnectionByDemandGenerationDate> waterConnectionByDemandGenerationDates;
    @JsonProperty("WaterConnectionsDemandNotGenerated")
    List<WaterConnectionByDemandGenerationDate> waterConnectionByDemandNotGeneratedDates;
}
