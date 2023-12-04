package org.egov.waterconnection.web.models;

import java.math.BigDecimal;
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
public class BillReportData {
	
	@JsonProperty("tenantName")
	private String tenantName = null;
	
	@JsonProperty("consumerName")
	private String consumerName = null;
	
	@JsonProperty("connectionNo")
	private String connectionNo = null;

	@JsonProperty("oldConnectionNo")
	private String oldConnectionNo = null;

	@JsonProperty("consumerCreatedOnDate")
	private String consumerCreatedOnDate = null;
	
	@JsonProperty("penalty")
	private BigDecimal penalty = null;
	
	@JsonProperty("advance")
	private BigDecimal advance = null;
	
	@JsonProperty("demandAmount")
	private BigDecimal demandAmount =null;
	
	@JsonProperty("userId")
	private String userId = null;
}
