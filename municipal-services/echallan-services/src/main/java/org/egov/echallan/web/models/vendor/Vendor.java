package org.egov.echallan.web.models.vendor;

import org.springframework.validation.annotation.Validated;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonValue;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * Capture the vendor information in the system.
 */
@Validated
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Getter
@Setter
public class Vendor {


	@JsonProperty("id")
	private String id = null;


	@JsonProperty("tenantId")
	private String tenantId = null;


	@JsonProperty("name")
	private String name = null;

	@JsonProperty("additionalDetails")
	private Object additionalDetails = null;


	@JsonProperty("source")
	private String source = null;


	@JsonProperty("description")
	private String description = null;


	@JsonProperty("ownerId")
	private String ownerId = null;

	/**
	 * Inactive records will be consider as soft deleted
	 */
	public enum StatusEnum {
		ACTIVE("ACTIVE"),

		INACTIVE("INACTIVE");

		private String value;

		StatusEnum(String value) {
			this.value = value;
		}

		@Override
		@JsonValue
		public String toString() {

			return String.valueOf(value);
		}

		@JsonCreator
		public static StatusEnum fromValue(String text) {
			for (StatusEnum b : StatusEnum.values()) {
				if (String.valueOf(b.value).equals(text)) {
					return b;
				}
			}
			return null;
		}
	}

	@JsonProperty("status")
	private StatusEnum status = null;

}