package org.egov.wscalculation.web.models;

import org.egov.common.contract.request.RequestInfo;
import org.springframework.validation.annotation.Validated;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Validated
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Builder
public class BulkDemand {

	@JsonProperty("RequestInfo")
	private RequestInfo requestInfo = null;
	
	@JsonProperty("tenantId")
	private String tenantId;
	
	@JsonProperty("connectionCategory")
	private String connectionCategory;
	
	@JsonProperty("billingPeriod")
	private String billingPeriod;

}
