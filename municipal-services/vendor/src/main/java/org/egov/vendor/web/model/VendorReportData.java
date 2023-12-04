package org.egov.vendor.web.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class VendorReportData {

    @JsonProperty("tenantId")
    private String tenantId;

    @JsonProperty("vendor_name")
    private String vendor_name;

    @JsonProperty("mobile_no")
    private String mobile_no;

    @JsonProperty("type_of_expense")
    private String type_of_expense;

    @JsonProperty("bill_id")
    private String bill_id;

    @JsonProperty("owner_uuid")
    private String uuid;

}
