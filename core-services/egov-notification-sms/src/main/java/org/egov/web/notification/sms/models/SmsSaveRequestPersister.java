package org.egov.web.notification.sms.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Builder;

@Builder
public class SmsSaveRequestPersister {

        @JsonProperty("smsSaveRequest")
        private SmsSaveRequest smsSaveRequest = null;

}
