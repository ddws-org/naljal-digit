package org.egov.mgramsevaifixadaptor.models;

import java.util.List;


import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class SearchCriteria {

	@JsonProperty("tenantId")
	private String tenantId;

	@JsonProperty("businessService")
	private String businessService;

	@JsonProperty("type")
	private String type;

	@JsonProperty("limit")
	private String limit;

	@JsonProperty("offset")
	private String offset;
}
