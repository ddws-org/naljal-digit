package org.egov.waterconnection.web.models;

import java.util.List;

import org.egov.common.contract.response.ResponseInfo;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Builder;
@Builder

public class CollectionReportResponse {
	@JsonProperty("CollectionReportData")
	private List<CollectionReportData> CollectionReportData;

	@JsonProperty("responseInfo")
	private ResponseInfo responseInfo = null;

}
