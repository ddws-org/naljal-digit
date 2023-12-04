package org.egov.wscalculation.web.models;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import javax.validation.Valid;

import org.egov.common.contract.response.ResponseInfo;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * CalculationRes
 */

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DemandPenaltyResponse   {
	
        @JsonProperty("ResponseInfo")
        private ResponseInfo responseInfo;

        @JsonProperty("Demands")
        @Valid
        private List<Demand> demands;

        private BigDecimal totalApplicablePenalty;


}