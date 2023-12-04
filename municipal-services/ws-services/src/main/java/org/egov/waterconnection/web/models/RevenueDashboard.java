package org.egov.waterconnection.web.models;


import java.util.Map;

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
public class RevenueDashboard {

	@JsonProperty("demand")
	private String demand = "0";

	@JsonProperty("pendingCollection")
	private String pendingCollection = "0";

	@JsonProperty("actualCollection")
	private String actualCollection = "0";

	@JsonProperty("residetialColllection")
	private String residetialColllection = "0";

	@JsonProperty("comercialCollection")
	private String comercialCollection = "0";

	@JsonProperty("othersCollection")
	private String othersCollection = "0";

	@JsonProperty("totalApplicationsCount")
	private Map<String, Object> totalApplicationsCount;

	@JsonProperty("residentialsCount")
	private Map<String, Object> residentialsCount;

	@JsonProperty("comercialsCount")
	private Map<String, Object> comercialsCount;
	
	@JsonProperty("advanceAdjusted")
	private String advanceAdjusted = "0";
	
	@JsonProperty("pendingPenalty")
	private String pendingPenalty = "0";
	
	@JsonProperty("advanceCollection")
	private String advanceCollection = "0";
	
	@JsonProperty("penaltyCollection")
	private String penaltyCollection = "0";

}
