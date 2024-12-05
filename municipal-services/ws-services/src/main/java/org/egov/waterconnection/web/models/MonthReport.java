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
public class MonthReport
{
    @JsonProperty("tenantName")
    private String tenantName = null;

    @JsonProperty("connectionNo")
    private String connectionNo = null;

    @JsonProperty("oldConnectionNo")
    private String oldConnectionNo = null;

    @JsonProperty("consumerCreatedOnDate")
    private Long consumerCreatedOnDate = null;

    @JsonProperty("consumerName")
    private String consumerName = null;

    @JsonProperty("userId")
    private String userId = null;

    @JsonProperty("demandGenerationDate")
    private Long demandGenerationDate=0L;

    @JsonProperty("penalty")
    private BigDecimal penalty = BigDecimal.ZERO;

    @JsonProperty("demandAmount")
    private BigDecimal demandAmount =BigDecimal.ZERO;

    @JsonProperty("advance")
    private BigDecimal advance = BigDecimal.ZERO;

    @JsonProperty("arrears")
    private BigDecimal arrears=BigDecimal.ZERO;

    @JsonProperty("totalAmount")
    private BigDecimal totalAmount=BigDecimal.ZERO;

    @JsonProperty("amountPaid")
    private BigDecimal paid=BigDecimal.ZERO;

    @JsonProperty("paidDate")
    private Long paidDate=0L;

    @JsonProperty("remainingAmount")
    private BigDecimal remainingAmount=BigDecimal.ZERO;
}