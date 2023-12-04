package org.egov.waterconnection.web.models;

import java.math.BigDecimal;
import java.util.List;
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
public class CollectionReportData {
	
	@JsonProperty("tenantName")
	private String tenantName = null;
	
	@JsonProperty("consumerName")
	private String consumerName = null;
	
	@JsonProperty("connectionNo")
	private String connectionNo = null;

	@JsonProperty("oldConnectionNo")
	private String oldConnectionNo = null;
	
	@JsonProperty("userId")
	private String userId = null;
	
	@JsonProperty("paymentMode")
	private String paymentMode = null;
	
	@JsonProperty("paymentAmount")
	private BigDecimal paymentAmount = null;
}
