package org.egov.naljalcustomisation.util;

import com.jayway.jsonpath.Configuration;
import com.jayway.jsonpath.JsonPath;
import com.jayway.jsonpath.Option;
import com.jayway.jsonpath.ReadContext;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.egov.common.contract.request.RequestInfo;
import org.egov.naljalcustomisation.config.CustomisationConfiguration;
import org.egov.naljalcustomisation.repository.ServiceRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Component
public class NotificationUtil {

    public static final String NOTIFICATION_LOCALE = "en_IN";
    public static final String LOCALIZATION_MSGS_JSONPATH = "$.messages[0].message";
    public static final String MSG_KEY="message";
    public static final String TEMPLATE_KEY="templateId";

    @Autowired
    private CustomisationConfiguration config;

    @Autowired
    private ServiceRequestRepository serviceRequestRepository;


    public HashMap<String, String> getLocalizationMessage(RequestInfo requestInfo, String code, String tenantId) {
        HashMap<String, String> msgDetail = new HashMap<String, String>();
        String locale = NOTIFICATION_LOCALE;
        if (!StringUtils.isEmpty(requestInfo.getMsgId()) && requestInfo.getMsgId().split("|").length >= 2)
            locale = requestInfo.getMsgId().split("\\|")[1];

        String templateId = null;
        Object result = null;
        StringBuilder uri = new StringBuilder();
        uri.append(config.getLocalizationHost()).append(config.getLocalizationContextPath())
                .append(config.getLocalizationSearchEndpoint()).append("?").append("locale=").append(locale)
                .append("&tenantId=").append(tenantId,0,2).append("&module=").append("mgramseva-common")
                .append("&codes=").append(code);

        Map<String, Object> request = new HashMap<>();
        request.put("RequestInfo", requestInfo);
        try {
            result = serviceRequestRepository.fetchResult(uri, request);
            Configuration suppressExceptionConfiguration = Configuration.defaultConfiguration()
                    .addOptions(Option.SUPPRESS_EXCEPTIONS);
            ReadContext jsonData = JsonPath.using(suppressExceptionConfiguration).parse(result);
            String message = jsonData.read(LOCALIZATION_MSGS_JSONPATH);
            msgDetail.put(MSG_KEY, message);
            msgDetail.put(TEMPLATE_KEY, templateId);
        } catch (Exception e) {
            log.error("Exception while fetching from localization: " + e);
        }
        return msgDetail;
    }
}
