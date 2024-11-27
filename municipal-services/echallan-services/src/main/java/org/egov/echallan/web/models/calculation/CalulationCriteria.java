package org.egov.echallan.web.models.calculation;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import org.egov.echallan.model.Challan;
import org.springframework.validation.annotation.Validated;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

@Validated

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class CalulationCriteria {
        @JsonProperty("challan")
        @Valid
        private Challan challan = null;

        @JsonProperty("challanNo")
        @Size(min=2,max=64) 
        private String challanNo = null;

        @JsonProperty("tenantId")
        @NotNull@Size(min=2,max=256) 
        private String tenantId = null;


}

