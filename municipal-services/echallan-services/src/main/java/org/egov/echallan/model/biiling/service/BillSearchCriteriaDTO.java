package org.egov.echallan.model.biiling.service;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Builder.Default;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class BillSearchCriteriaDTO {

    @NotNull
    @Size(max = 256)
    private String tenantId;

    private Set<String> billId;

    private Long fromPeriod;

    private Long toPeriod;

    @Default
    private Boolean retrieveOldest = false;

    private Boolean isActive;

    private Boolean isCancelled;

    private Set<String> consumerCode;

    @Size(max = 256)
    private String billNumber;

    @Size(max = 256)
    private String service;

    @Default
    private boolean isOrderBy = false;

    private Long size;

    private Long offset;

    @Email
    private String email;

    private BillDTO.BillStatus status;

    @Default
    private Boolean returnAllBills = false;

    @Pattern(regexp = "^[0-9]{10}$", message = "MobileNumber should be 10 digit number")
    private String mobileNumber;

}
