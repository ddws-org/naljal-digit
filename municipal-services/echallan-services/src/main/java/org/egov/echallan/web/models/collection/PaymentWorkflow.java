package org.egov.echallan.web.models.collection;

import javax.validation.constraints.NotNull;

import org.hibernate.validator.constraints.Length;
import org.hibernate.validator.constraints.SafeHtml;

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

	@SafeHtml
	@NotNull
	@Length(min = 1)
	private String paymentId;

	@NotNull
	private PaymentAction action;

	@SafeHtml
	@NotNull
	@Length(min = 1)
	private String tenantId;

	@SafeHtml
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
