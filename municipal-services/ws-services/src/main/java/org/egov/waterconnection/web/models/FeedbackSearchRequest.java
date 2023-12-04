package org.egov.waterconnection.web.models;



import org.egov.common.contract.request.RequestInfo;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
public class FeedbackSearchRequest {

	private RequestInfo requestInfo;
	
	private FeedbackSearchCriteria feedbackSearchCriteria;
	
}
