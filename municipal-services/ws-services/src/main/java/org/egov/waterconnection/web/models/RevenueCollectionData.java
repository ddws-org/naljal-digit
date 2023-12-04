package org.egov.waterconnection.web.models;

import org.egov.common.contract.response.ResponseInfo;

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
public class RevenueCollectionData {

	@JsonProperty("month")
	private long month;
	
	@JsonProperty("demand")
	private String demand = "0";

	@JsonProperty("pendingCollection")
	private String pendingCollection = "0";

	@JsonProperty("arrears")
	private String arrears = "0";

	@JsonProperty("actualCollection")
	private String actualCollection = "0";
	
	@JsonProperty("advanceAdjusted")
	private String advanceAdjusted = "0";
	
	@JsonProperty("pendingPenalty")
	private String pendingPenalty = "0";
	
	@JsonProperty("advanceCollection")
	private String advanceCollection = "0";
	
	@JsonProperty("penaltyCollection")
	private String penaltyCollection = "0";
}
