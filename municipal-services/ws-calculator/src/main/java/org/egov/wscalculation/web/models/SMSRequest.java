package org.egov.wscalculation.web.models;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.ToString;


@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class SMSRequest {
    private String mobileNumber;
    private String message;
    private Category category;
    private Long expiryTime;
    private String tenantid;
}
