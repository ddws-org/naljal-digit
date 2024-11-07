package org.egov.wscalculation.web.models;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonValue;
import lombok.*;

@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class WsDemandChangeAuditRequestWrapper {

   @JsonProperty("WsDemandChangeAuditRequest")
   private  WsDemandChangeAuditRequest wsDemandChangeAuditRequest;
}
