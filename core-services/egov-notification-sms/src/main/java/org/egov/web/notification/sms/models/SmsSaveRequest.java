package org.egov.web.notification.sms.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.ToString;

import static org.apache.commons.lang3.StringUtils.isNotEmpty;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class SmsSaveRequest {

    @JsonProperty("id")
    private Long id;
    @JsonProperty("mobileNumber")
    private String mobileNumber;
    @JsonProperty("message")
    private String message;
    @JsonProperty("category")
    private Category category;
    @JsonProperty("createdtime")
    private Long createdtime;
    @JsonProperty("templateId")
    private String templateId;
    @JsonProperty("tenantId")
    private String tenantId;
    public boolean isValid() {

        return isNotEmpty(mobileNumber) && isNotEmpty(message);
    }
}