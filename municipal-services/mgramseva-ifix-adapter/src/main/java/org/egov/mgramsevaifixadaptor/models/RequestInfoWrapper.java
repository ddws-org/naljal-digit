package org.egov.mgramsevaifixadaptor.models;

import org.egov.common.contract.request.RequestInfo;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class RequestInfoWrapper {

	@JsonProperty("RequestInfo")
	private RequestInfo requestInfo;
	
	@JsonProperty("tenantIds")
	private List<String> tenantIds;
	
}
