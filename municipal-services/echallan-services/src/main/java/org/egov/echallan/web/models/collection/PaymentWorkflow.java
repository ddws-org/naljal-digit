package org.egov.echallan.web.models.collection;

import jakarta.validation.constraints.NotNull;

import org.hibernate.validator.constraints.Length;


import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import com.fasterxml.jackson.databind.JsonNode;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentWorkflow {


	@NotNull
	@Length(min = 1)
	private String paymentId;

	@NotNull
	private PaymentAction action;


	@NotNull
	@Length(min = 1)
	private String tenantId;


	private String reason;

	private JsonNode additionalDetails;

	/**
	 * Current status of the transaction
	 */
	public enum PaymentAction {
		CANCEL("CANCEL"), DISHONOUR("DISHONOUR"), REMIT("REMIT");

		private String value;

		PaymentAction(String value) {
			this.value = value;
		}

		@JsonCreator
		public static PaymentAction fromValue(String text) {
			for (PaymentAction b : PaymentAction.values()) {
				if (String.valueOf(b.value).equals(text)) {
					return b;
				}
			}
			return null;
		}

		@Override
		@JsonValue
		public String toString() {
			return String.valueOf(value);
		}
	}

}
