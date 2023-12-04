package org.egov.echallan.model.biiling.service;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonValue;
import com.fasterxml.jackson.databind.JsonNode;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.egov.echallan.model.AuditDetails;

import javax.validation.Valid;
import javax.validation.constraints.Pattern;
import javax.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BillDTO {

    @JsonProperty("id")
    @Size(max = 256)
    private String id;

    @JsonProperty("mobileNumber")
    @Pattern(regexp = "^[0-9]{10}$", message = "MobileNumber should be 10 digit number")
    private String mobileNumber;

    @JsonProperty("payerName")
    @Size(max = 256)
    private String payerName;

    @JsonProperty("payerAddress")
    @Size(max = 1024)
    private String payerAddress;

    @JsonProperty("payerEmail")
    @Size(max = 256)
    private String payerEmail;

    @JsonProperty("status")
    private BillStatus status;

    @JsonProperty("totalAmount")
    private BigDecimal totalAmount;

    @JsonProperty("businessService")
    @Size(max = 256)
    private String businessService;

    @JsonProperty("billNumber")
    @Size(max = 256)
    private String billNumber;

    @JsonProperty("billDate")
    private Long billDate;

    @JsonProperty("consumerCode")
    @Size(max = 256)
    private String consumerCode;

    @JsonProperty("additionalDetails")
    private JsonNode additionalDetails;

    @JsonProperty("billDetails")
    @Valid
    private List<BillDetailDTO> billDetails;

    @JsonProperty("tenantId")
    @Size(max = 256)
    private String tenantId;

    @JsonProperty("fileStoreId")
    private String fileStoreId;

    @JsonProperty("auditDetails")
    private AuditDetails auditDetails;

    /**
     * status of the bill .
     */
    public enum BillStatus {

        ACTIVE("ACTIVE"),

        CANCELLED("CANCELLED"),

        PAID("PAID"),

        PARTIALLY_PAID("PARTIALLY_PAID"),

        PAYMENT_CANCELLED("PAYMENT_CANCELLED"),

        EXPIRED("EXPIRED");

        private String value;

        BillStatus(String value) {
            this.value = value;
        }

        @JsonCreator
        public static BillStatus fromValue(String text) {
            for (BillStatus b : BillStatus.values()) {
                if (String.valueOf(b.value).equalsIgnoreCase(text)) {
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
