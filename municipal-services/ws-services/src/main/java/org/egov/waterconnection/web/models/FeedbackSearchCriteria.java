package org.egov.waterconnection.web.models;

import javax.validation.constraints.NotNull;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class FeedbackSearchCriteria {

    private String id;
	
	
	private String connectionNo;
	
	
	private String paymentId;
	
	
	private String billingCycle;
	
	@NotNull
	private String tenantId;
	
	
	private Long offset;
	
	private Long limit;
	
	@JsonProperty("fromDate")
	private Long fromDate = null;

	@JsonProperty("toDate")
	private Long toDate = null;
	
	
}
