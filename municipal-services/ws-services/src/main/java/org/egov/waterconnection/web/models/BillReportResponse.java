package org.egov.waterconnection.web.models;

import java.util.List;

import org.egov.common.contract.response.ResponseInfo;
import org.egov.waterconnection.web.models.RevenueCollectionDataResponse.RevenueCollectionDataResponseBuilder;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Builder;
@Builder

public class BillReportResponse {
	@JsonProperty("BillReportData")
	private List<BillReportData> BillReportData;

	@JsonProperty("responseInfo")
	private ResponseInfo responseInfo = null;

}
