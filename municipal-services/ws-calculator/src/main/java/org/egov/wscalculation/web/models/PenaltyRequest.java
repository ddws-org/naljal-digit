package org.egov.wscalculation.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import org.egov.common.contract.request.RequestInfo;
import org.springframework.validation.annotation.Validated;

@Validated
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Builder
public class PenaltyRequest {
    @JsonProperty("requestInfo")
    private RequestInfo requestInfo;

    @JsonProperty("addPenaltyCriteria")
    private AddPenaltyCriteria addPenaltyCriteria;
}