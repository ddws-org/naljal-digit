package org.egov.echallan.web.models.calculation;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import org.egov.echallan.model.Challan;
import org.springframework.validation.annotation.Validated;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.util.List;

/**
 * Calculation
 */
@Validated

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Calculation {


	@JsonProperty("challanNo")
	private String challanNo = null;

	@JsonProperty("challan")
	private Challan challan = null;

	@NotNull

	@JsonProperty("tenantId")
	@Size(min = 2, max = 256)
	private String tenantId = null;

	@JsonProperty("taxHeadEstimates")
	List<TaxHeadEstimate> taxHeadEstimates;

}
