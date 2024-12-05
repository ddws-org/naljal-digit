package org.egov.wscalculation.web.models;

import lombok.*;

import java.util.Map;

import static org.apache.commons.lang3.StringUtils.isNotEmpty;


@Getter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@ToString
public class WsDemandChangeAuditRequest {
    private Long id;
    private String consumercode;
    private String tenant_id;
    private String status;
    private String action;
    private Object data;
    private String createdby;
    private Long createdtime;
    public boolean isValid() {

        return isNotEmpty(consumercode);
    }
}
