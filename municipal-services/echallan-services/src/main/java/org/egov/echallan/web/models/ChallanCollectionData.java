package org.egov.echallan.web.models;


import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChallanCollectionData {

	@JsonProperty("month")
	private long month;
	
	@JsonProperty("totalExpenditure")
	private String totalExpenditure = "0";

	@JsonProperty("amountUnpaid")
	private String amountUnpaid = "0";

	@JsonProperty("amountPaid")
	private String amountPaid = "0";
}
