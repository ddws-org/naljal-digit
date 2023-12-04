package org.egov.waterconnection.web.models;

import java.util.List;

import org.egov.common.contract.response.ResponseInfo;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class FeedbackResponse {

	
	private ResponseInfo responseInfo;
	
	private Object feedback;
}
