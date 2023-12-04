package org.egov.echallan.model.biiling.service;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.Valid;
import java.math.BigDecimal;
import java.util.List;

/**
 * BillDetail
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillDetailDTO {

    @JsonProperty("id")
    private String id;

    @JsonProperty("tenantId")
    private String tenantId;

    @JsonProperty("demandId")
    private String demandId;

    @JsonProperty("billId")
    private String billId;

    @JsonProperty("expiryDate")
    private Long expiryDate;

    @JsonProperty("amount")
    private BigDecimal amount;

    @JsonProperty("amountPaid")
    private BigDecimal amountPaid;

    @JsonProperty("fromPeriod")
    private Long fromPeriod;

    @JsonProperty("toPeriod")
    private Long toPeriod;

    @JsonProperty("additionalDetails")
    private Object additionalDetails;

    @JsonProperty("billAccountDetails")
    @Valid
    private List<BillAccountDetailDTO> billAccountDetails;
}
