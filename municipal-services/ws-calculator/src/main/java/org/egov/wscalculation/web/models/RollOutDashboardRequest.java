package org.egov.wscalculation.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.egov.common.contract.request.RequestInfo;

import javax.validation.Valid;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Builder
public class RollOutDashboardRequest {

    @JsonProperty("RequestInfo")
    private RequestInfo requestInfo = null;

    @Valid
    @JsonProperty("rollOutDashboard")
    private RollOutDashboard rollOutDashboard = null;
}