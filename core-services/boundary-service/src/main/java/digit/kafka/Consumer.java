package digit.kafka;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import digit.config.ApplicationProperties;
import digit.web.models.MdmsRequest;
import digit.web.models.Mdms;
import lombok.extern.slf4j.Slf4j;
import org.egov.common.contract.request.RequestInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.util.HashMap;
import java.util.Map;

@Component
@Slf4j
public class Consumer {

    @Autowired
    private ObjectMapper mapper;

    @Autowired
    private ApplicationProperties config;

    /*
     * Uncomment the below line to start consuming record from kafka.topics.consumer
     * Value of the variable kafka.topics.consumer should be overwritten in application.properties
     */
    @KafkaListener(topics = {"${kafka.topics.push.boundary}"})
    public void createTenantWithPushBoundary(final HashMap<String, String> villageData) {
        try {
            // Convert the villageData to a nested structure
            Mdms mdms = buildMdmsStructure(villageData);

            ObjectMapper objectMapper = new ObjectMapper();
            RequestInfo requestInfo = null;
            if (villageData.containsKey("requestInfo")) {
                String requestInfoJson = villageData.get("requestInfo");
                requestInfo = objectMapper.readValue(requestInfoJson, RequestInfo.class);
            }
            MdmsRequest mdmsRequest = MdmsRequest.builder()
                    .requestInfo(requestInfo)
                    .mdms(mdms)
                    .build();

            log.info("MdmsRequest is "+mdmsRequest.toString());

            // Call the external API with the constructed MdmsRequest
            sendDataToExternalApi(mdmsRequest);
        } catch (Exception ex) {
            log.info("Error processing village data from topic: kafka.topics.push.boundary", ex);
        }
    }

    private Mdms buildMdmsStructure(HashMap<String, String> villageData)
    {
        Map<String, Object> cityData = new HashMap<>();
        cityData.put("code", villageData.getOrDefault("cityCode", ""));
        cityData.put("name", villageData.getOrDefault("cityName", ""));
        cityData.put("captcha", villageData.getOrDefault("captcha", ""));
        cityData.put("ddrName", villageData.getOrDefault("ddrName", ""));
        cityData.put("latitude", villageData.getOrDefault("latitude", "0"));
        cityData.put("ulbGrade", villageData.getOrDefault("ulbGrade", ""));
        cityData.put("localName", villageData.getOrDefault("localName", ""));
        cityData.put("longitude", villageData.getOrDefault("longitude", "0"));
        cityData.put("projectId", villageData.getOrDefault("projectId", ""));
        cityData.put("regionName", villageData.getOrDefault("regionName", ""));
        cityData.put("districtCode", villageData.getOrDefault("districtCode", ""));
        cityData.put("districtName", villageData.getOrDefault("districtName", ""));

        Map<String, Object> officeTimings = new HashMap<>();
        officeTimings.put("Mon - Fri", villageData.getOrDefault("officeTimings", "9.00 AM - 6.00 PM"));

        Map<String, Object> mdmsData = new HashMap<>();
        mdmsData.put("city", cityData);
        mdmsData.put("OfficeTimings", officeTimings);
        mdmsData.put("code", villageData.get("code"));
        mdmsData.put("name", villageData.get("name"));
        mdmsData.put("address", villageData.get("address"));
        mdmsData.put("description", villageData.get("description"));
        mdmsData.put("sectionCode", villageData.get("sectionCode"));
        mdmsData.put("sectionName", villageData.get("sectionName"));
        mdmsData.put("schemeCode", villageData.get("schemeCode"));
        mdmsData.put("schemeName", villageData.get("schemeName"));
        mdmsData.put("divisionCode", villageData.get("divisionCode"));
        mdmsData.put("divisionName", villageData.get("divisionName"));
        mdmsData.put("circleName", villageData.get("circleName"));
        mdmsData.put("circleCode", villageData.get("circleCode"));
        mdmsData.put("zoneName", villageData.get("zoneName"));
        mdmsData.put("zoneCode", villageData.get("zoneCode"));

        return Mdms.builder()
                .tenantId("pb")
                .schemaCode("tenant.tenants")
                .data(mapper.convertValue(mdmsData, JsonNode.class))
                .isActive(true)
                .build();
    }

    private void sendDataToExternalApi(MdmsRequest mdmsRequest) {
        try {
            // Construct the API URL
            String url = config.getMdmsHost() + config.getMdmsv2Endpoint() + "/tenant.tenants";
            log.info("Url is "+url);


            RestTemplate restTemplate = new RestTemplate();
            // Send POST request
             Map<String, Object> response = restTemplate.postForObject(url, mdmsRequest, Map.class);

            // Handle response
             if (response != null && !response.isEmpty()) {
                 log.info("Successfully pushed data to external API: {}", response);
             } else {
                 log.info("Failed to push data to external API. Empty or null response.");
             }
        } catch (Exception ex) {
            log.info("Error sending data to external API", ex);
        }
    }
}
