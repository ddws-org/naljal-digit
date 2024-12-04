package org.egov.encryption.config;


import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

import lombok.Getter;

@Getter
@Configuration
@PropertySource("classpath:enc.properties")
public class EncProperties {

    @Value("${kafka.topic.audit}")
    private String auditTopicName;

    @Value("${egov.mdms.host}")
    private String egovMdmsHost;
    
    @Value("${egov.mdms.search.endpoint}")
    private String egovMdmsSearchEndpoint;

    @Value("${state.level.tenant.id}")
    private String stateLevelTenantId;
    @Value("${default.encrypt.data.type}")
    private String defaultEncryptDataType;

    @Value("${egov.enc.host}")
    private String egovEncHost;
    
    @Value("${egov.enc.encrypt.endpoint}")
    private String egovEncEncryptPath;
    
    @Value("${egov.enc.decrypt.endpoint}")
    private String egovEncDecryptPath;
}
