package org.egov.vendor.web.model.vehicle;

import java.util.List;

import org.egov.common.contract.response.ResponseInfo;
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
 * Response of vehicle detail
 */
//@Schema(description = "Response of vehicle detail")
@Validated
@AllArgsConstructor
@EqualsAndHashCode
@Getter
@NoArgsConstructor
@Setter
@ToString
@Builder
public class VehicleResponse {

	@JsonProperty("responseInfo")
	private ResponseInfo responseInfo = null;

	@JsonProperty("vehicle")
	private List<Vehicle> vehicle = null;
}
