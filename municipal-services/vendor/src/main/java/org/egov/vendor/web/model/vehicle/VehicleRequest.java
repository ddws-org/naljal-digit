package org.egov.vendor.web.model.vehicle;


import org.egov.common.contract.request.RequestInfo;
import org.springframework.validation.annotation.Validated;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;


/**
 * Request for vehicle details
 */
//@Schema(description = "Request for vehicle details")
@Validated
@AllArgsConstructor
@EqualsAndHashCode
@Getter
@NoArgsConstructor
@Setter
@ToString
@Builder
public class VehicleRequest {

	@JsonProperty("RequestInfo")
	private RequestInfo RequestInfo = null;

	@JsonProperty("vehicle")
	private Vehicle vehicle = null;
}
