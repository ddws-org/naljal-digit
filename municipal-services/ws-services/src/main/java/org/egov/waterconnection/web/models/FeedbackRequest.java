package org.egov.waterconnection.web.models;

import org.egov.common.contract.request.RequestInfo;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Setter
@Getter
public class FeedbackRequest {
	
	private RequestInfo requestInfo;
	
	private Feedback feedback;

}
