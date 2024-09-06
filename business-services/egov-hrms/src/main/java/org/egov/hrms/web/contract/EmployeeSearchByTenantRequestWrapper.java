package org.egov.hrms.web.contract;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.egov.common.contract.request.RequestInfo;
import org.egov.hrms.model.Employee;
import org.hibernate.validator.constraints.NotEmpty;
import org.springframework.validation.annotation.Validated;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import java.util.List;

@Validated
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class EmployeeSearchByTenantRequestWrapper {
    @NotNull
    @JsonProperty("RequestInfo")
    private RequestInfo requestInfo;

    @Valid
    @JsonProperty("criteria")
    private EmployeeSearchCriteria criteria;

}