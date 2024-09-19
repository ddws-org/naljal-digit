package org.egov.hrms.web.contract;

import lombok.*;
import org.apache.commons.lang3.StringUtils;
import javax.validation.constraints.Size;
import java.util.List;


@AllArgsConstructor
@Getter
@NoArgsConstructor
@Setter
@ToString
@Builder
public class EmployeePlainSearchCriteria {

	@Size(max = 250)
	public String tenantId;

	private List<String> uuids;

	private Long createdDateFrom;

	private Long createdDateTo;

	public Integer offset;
	
	public Integer limit;
	
	
	public boolean isPlainSearchCriteriaEmpty(EmployeePlainSearchCriteria criteria) {
		if(StringUtils.isEmpty(criteria.getTenantId()) && null == createdDateFrom
				&& null == createdDateTo) {
			return true;
		}else {
			return false;
		}
	}

}
