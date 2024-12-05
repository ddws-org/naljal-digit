package org.egov.echallan.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;
import org.egov.echallan.model.Amount;

import java.util.List;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ExpenseBillReportData
{
    @JsonProperty("typeOfExpense")
    private String typeOfExpense;

    @JsonProperty("vendorName")
    private String vendorName;

    @JsonProperty("amount")
    private Long amount;

    @JsonProperty("billDate")
    private Long billDate;

    @JsonProperty("taxPeriodFrom")
    private Long taxPeriodFrom;

    @JsonProperty("taxPeriodTo")
    private Long taxPeriodTo;

    @JsonProperty("applicationStatus")
    private String applicationStatus;

    @JsonProperty("paidDate")
    private Long paidDate;

    @JsonProperty("filestoreid")

    private String filestoreid;

    @JsonProperty("lastModifiedTime")
    private Long lastModifiedTime;

    @JsonProperty("lastModifiedByUuid")
    private String lastModifiedByUuid;

    @JsonProperty("lastModifiedBy")
    private String lastModifiedBy;

    @JsonProperty("tenantId")
    private String tenantId;
}
