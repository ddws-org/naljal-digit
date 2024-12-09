package org.egov.waterconnection.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import org.egov.common.contract.response.ResponseInfo;

import java.util.List;

@Builder
public class MonthReportResponse
{
    @JsonProperty("monthReport")
    private List<MonthReport> monthReport;

    @JsonProperty("tenantName")
    private String tenantName;

    @JsonProperty("monthPeriod")
    private String month;

    @JsonProperty("responseInfo")
    private ResponseInfo responseInfo = null;
}