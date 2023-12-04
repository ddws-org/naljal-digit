package org.egov.echallan.web.models;

import org.egov.common.contract.response.ResponseInfo;
import org.egov.echallan.model.LastMonthSummary;
import org.egov.echallan.model.LastMonthSummaryResponse;

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
public class ExpenseDashboardResponse {

	@JsonProperty("ExpenseDashboard")
	private ExpenseDashboard ExpenseDashboard;

	@JsonProperty("responseInfo")
	private ResponseInfo responseInfo = null;

}
