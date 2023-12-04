package org.egov.echallan.web.models;

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
public class ChallanCollectionDataResponse {
	@JsonProperty("ChallanCollectionData")
	private List<ChallanCollectionData> ChallanCollectionData;

	@JsonProperty("responseInfo")
	private ResponseInfo responseInfo = null;
}
