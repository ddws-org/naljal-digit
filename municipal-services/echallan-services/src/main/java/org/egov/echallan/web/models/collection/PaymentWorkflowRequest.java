package org.egov.echallan.web.models.collection;


import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;

import org.egov.common.contract.request.RequestInfo;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentWorkflowRequest {

    @JsonProperty("RequestInfo")
    private RequestInfo requestInfo;

    @JsonProperty("PaymentWorkflows")
    @Size(min = 1)
    @Valid
	private List<PaymentWorkflow> paymentWorkflows;

}
