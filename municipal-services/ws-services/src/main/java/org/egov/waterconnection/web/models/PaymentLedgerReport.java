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
public class PaymentLedgerReport
{
    @JsonProperty("paymentCollectionDate")
    private Long collectionDate;

    @JsonProperty("receiptNo")
    private String receiptNo=null;

    @JsonProperty("amountPaid")
    private BigDecimal paid= BigDecimal.ZERO;

    @JsonProperty("balanceLeft")
    private BigDecimal balanceLeft=BigDecimal.ZERO;
}
