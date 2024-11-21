package org.egov.waterconnection.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class LedgerReport
{
    @JsonProperty("demand")
    private DemandLedgerReport demand=null;

    @JsonProperty("payment")
    private List<PaymentLedgerReport> payment=new ArrayList<>();

    @JsonProperty("totalPaymentInMonth")
    private BigDecimal totalPaymentInMonth=BigDecimal.ZERO;

    @JsonProperty("totalBalanceLeftInMonth")
    private BigDecimal totalBalanceLeftInMonth=BigDecimal.ZERO;
}
