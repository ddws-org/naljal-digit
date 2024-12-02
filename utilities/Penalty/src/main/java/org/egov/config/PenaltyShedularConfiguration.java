package org.egov.config;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.List;
import java.util.TimeZone;

@Component
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PenaltyShedularConfiguration {

    @Value("${app.timezone}")
    private String timeZone;

    @PostConstruct
    public void initialize() {
        TimeZone.setDefault(TimeZone.getTimeZone(timeZone));
    }

    //egov-mdms
    @Value("${egov.mdms.host}")
    private String egovMdmsHost;

    @Value("${egov.mdms.search.endpoint}")
    private String egovMdmsSearchUrl;

    @Value("${mdms.event.tenantId}")
    private String tenantId;

    @Value("${egov.wscalculator.host}")
    private String egovWaterCalculatorHost;

    @Value("${egov.wscalculator.url}")
    private String egovWaterCalculatorSearchUrl;

    @Value("${egov.penalty.enabled}")
    private boolean isPenaltyEnabled;

    @Value("#{'${egov.penalty.enabled.division.code.list}'.split(',')}")
    private List<String> penaltyEnabledDivisionlist;

    @Value ("${user.system.uuid}")
    private String uuid;

    @Value("${user.system.mobileNumber}")
    private String userName;

    @Value("${user.system.role}")
    private String role;
}

