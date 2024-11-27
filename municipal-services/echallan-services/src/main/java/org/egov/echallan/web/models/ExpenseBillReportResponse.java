package org.egov.echallan.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import org.apache.coyote.RequestInfo;
import org.egov.common.contract.response.ResponseInfo;

import java.util.List;


@Builder
public class ExpenseBillReportResponse {

    @JsonProperty("ExpenseBillReportData")
    private List<ExpenseBillReportData> ExpenseBillReportData;

    @JsonProperty("responseInfo")
    private ResponseInfo responseInfo = null;

}
