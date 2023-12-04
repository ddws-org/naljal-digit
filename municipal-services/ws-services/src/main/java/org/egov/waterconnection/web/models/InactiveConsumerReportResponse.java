package org.egov.waterconnection.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import org.egov.common.contract.response.ResponseInfo;

import java.util.List;

@Builder
public class InactiveConsumerReportResponse {

    @JsonProperty("InactiveConsumerReport")
    private List<InactiveConsumerReportData> InactiveConsumerReportData;

    @JsonProperty("responseInfo")
    private ResponseInfo responseInfo = null;
}
