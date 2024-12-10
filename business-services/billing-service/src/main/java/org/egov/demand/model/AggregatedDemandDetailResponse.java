package org.egov.demand.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class AggregatedDemandDetailResponse {

    private List<Map<Long , List<DemandDetail>>> mapOfDemandDetailList;

    private BigDecimal advanceAvailable;

    private BigDecimal advanceAdjusted;

    private BigDecimal remainingAdvance;

    private BigDecimal currentmonthBill;

    private BigDecimal currentMonthPenalty;

    private BigDecimal currentmonthTotalDue;

    private BigDecimal currentmonthRoundOff;

    private BigDecimal totalAreas;

    private BigDecimal totalAreasWithPenalty;

    private BigDecimal totalAreasRoundOff;

    private BigDecimal netdue;

    private BigDecimal netDueWithPenalty;

    private BigDecimal totalApplicablePenalty;

    private long latestDemandCreatedTime;

    private long latestDemandPenaltyCreatedtime;
}