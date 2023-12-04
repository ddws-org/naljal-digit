package org.egov.waterconnection.web.models;

import java.util.HashMap;
import java.util.List;

import org.egov.common.contract.response.ResponseInfo;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@NoArgsConstructor
@AllArgsConstructor
@Setter
@Builder
public class OnBoardResponse {

	@JsonProperty("ResponseInfo")
	private ResponseInfo responseInfo = null;

//	@JsonProperty("users")
//	private List<User> users = null;
	
	@JsonProperty("messages")
	private HashMap messages = null;

}
