package org.egov.vendor.web.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;
import org.egov.common.contract.response.ResponseInfo;

import java.util.List;

@Builder
public class VendorReportResponse {

    @JsonProperty("VendorReportData")
    private List<VendorReportData> VendorReportData;

    @JsonProperty("requestInfo")
    private ResponseInfo responseInfo = null;
}
