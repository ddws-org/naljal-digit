package org.egov.waterconnection.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PaymentMonthReport
{
    @JsonProperty("totalAmountPaid")
    private BigDecimal totalAmountPaid=BigDecimal.ZERO;

    @JsonProperty("firstTransactionDate")
    private Long firstTransactionDate=0L;

    @JsonProperty("remainingAmount")
    private BigDecimal remainingAmount=BigDecimal.ZERO;
}