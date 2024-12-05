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
public class DemandLedgerReport {

    @JsonProperty("consumerName")
    private String consumerName = null;

    @JsonProperty("connectionNo")
    private String connectionNo = null;

    @JsonProperty("oldConnectionNo")
    private String oldConnectionNo = null;

    @JsonProperty("userId")
    private String userId = null;

    @JsonProperty("month")
    private String monthAndYear;

    @JsonProperty("demandGenerationDate")
    private Long demandGenerationDate= 0L;

    @JsonProperty("code")
    private String code = null;

    @JsonProperty("monthlyCharges")
    private BigDecimal taxamount=BigDecimal.ZERO;

    @JsonProperty("penalty")
    private BigDecimal penalty=BigDecimal.ZERO;

    @JsonProperty("totalForCurrentMonth")
    private BigDecimal totalForCurrentMonth=BigDecimal.ZERO;

    @JsonProperty("previousMonthBalance")
    private BigDecimal arrears=BigDecimal.ZERO;

    @JsonProperty("totalDues")
    private BigDecimal total_due_amount=BigDecimal.ZERO;

    @JsonProperty("dueDateOfPayment")
    private Long dueDate= 0L;

    @JsonProperty("penaltyAppliedOnDate")
    private Long penaltyAppliedDate=0L;

}
