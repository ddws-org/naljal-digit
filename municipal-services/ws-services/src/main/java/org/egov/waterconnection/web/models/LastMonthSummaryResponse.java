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
public class LastMonthSummaryResponse {

	@JsonProperty("LastMonthSummary")
	private LastMonthSummary LastMonthSummary;

	@JsonProperty("responseInfo")
	private ResponseInfo responseInfo = null;

}
