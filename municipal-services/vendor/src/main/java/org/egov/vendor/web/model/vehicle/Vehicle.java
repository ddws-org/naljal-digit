package org.egov.vendor.web.model.vehicle;


import org.egov.vendor.web.model.AuditDetails;
import org.egov.vendor.web.model.user.User;
import org.hibernate.validator.constraints.SafeHtml;
import org.springframework.validation.annotation.Validated;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonValue;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

/**
 * Instance of Service request raised for a particular service. As per extension
 * propsed in the Service definition \&quot;attributes\&quot; carry the input
 * values requried by metadata definition in the structure as described by the
 * corresponding schema. * Any one of &#x27;address&#x27; or &#x27;(lat and
 * lang)&#x27; or &#x27;addressid&#x27; is mandatory
 */
//@Schema(description = "Instance of Service request raised for a particular service. As per extension propsed in the Service definition \"attributes\" carry the input values requried by metadata definition in the structure as described by the corresponding schema.  * Any one of 'address' or '(lat and lang)' or 'addressid' is mandatory ")
@Validated
@AllArgsConstructor
@EqualsAndHashCode
@Getter
@NoArgsConstructor
@Setter
@ToString
@Builder
public class Vehicle {

	@JsonProperty("owner")
	private User owner = null;

	@SafeHtml
	@JsonProperty("id")
	private String id = null;

	@SafeHtml
	@JsonProperty("tenantId")
	private String tenantId = null;

	@SafeHtml
	@JsonProperty("registrationNumber")
	private String registrationNumber = null;

	@SafeHtml
	@JsonProperty("model")
	private String model = null;

	@SafeHtml
	@JsonProperty("type")
	private String type = null;

	@JsonProperty("tankCapacity")
	private Long tankCapicity = null;

	@SafeHtml
	@JsonProperty("suctionType")
	private String suctionType = null;

	@JsonProperty("pollutionCertiValidTill")
	private Long pollutionCertiValidTill = null;

	@JsonProperty("InsuranceCertValidTill")
	private Long insuranceCertValidTill = null;

	@JsonProperty("fitnessValidTill")
	private Long fitnessValidTill = null;

	@JsonProperty("roadTaxPaidTill")
	private Long roadTaxPaidTill = null;

	@JsonProperty("gpsEnabled")
	private Boolean gpsEnabled = null;

	@JsonProperty("additionalDetail")
	private Object additionalDetail = null;

	@SafeHtml
	@JsonProperty("source")
	private String source = null;

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

	@JsonProperty("auditDetails")
	private AuditDetails auditDetails = null;

}
