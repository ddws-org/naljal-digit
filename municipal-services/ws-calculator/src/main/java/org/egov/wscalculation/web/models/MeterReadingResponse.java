package org.egov.wscalculation.web.models;

import java.util.List;

import jakarta.validation.Valid;

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
public class MeterReadingResponse {
	@JsonProperty("ResponseInfo")
	private ResponseInfo responseInfo = null;
	
	@JsonProperty("meterReadings")
	@Valid
	private List<MeterReading> meterReadings = null;

}
