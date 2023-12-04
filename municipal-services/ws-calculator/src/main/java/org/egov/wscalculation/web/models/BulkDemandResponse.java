package org.egov.wscalculation.web.models;

import java.util.List;

import org.egov.common.contract.response.ResponseInfo;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class BulkDemandResponse {

	 @JsonProperty("ResponseInfo")
     private ResponseInfo responseInfo;
	 
	 @JsonProperty("message")
	 String message;

}
