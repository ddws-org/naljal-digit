package digit.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import digit.util.FileReader;
import digit.web.models.MasterDataMigrationRequest;
import digit.web.models.Mdms;
import digit.web.models.MdmsRequest;
import lombok.extern.slf4j.Slf4j;
import net.minidev.json.JSONArray;
import org.egov.common.contract.models.AuditDetails;
import org.egov.common.contract.request.RequestInfo;
import org.egov.common.utils.AuditDetailsEnrichmentUtil;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import static digit.constants.ErrorCodes.*;
import static digit.constants.MDMSMigrationToolkitConstants.DOT_SEPARATOR;

import javax.validation.Valid;
import java.util.*;

@Service
@Slf4j
public class MasterDataMigrationService {

    @Autowired
    private FileReader fileReader;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private RestTemplate restTemplate;

    @Value("${master.schema.files.dir}")
    public String schemaFilesDirectory;

    /**
     * This methods accepts master data migration request and triggers
     * creation of MDMS objects
     * @param masterDataMigrationRequest
     */
    public void migrateMasterData(@Valid MasterDataMigrationRequest masterDataMigrationRequest) {

        // Get Master Data map
        Map<String, Map<String, Map<String, JSONArray>>> tenantMap = MDMSApplicationRunnerImpl.getTenantMap();

        // Get tenantId from request
        List<String> tenantIds = masterDataMigrationRequest.getMasterDataMigrationCriteria().getTenantId();
        //Set<String> tenantIds = tenantMap.keySet();
        log.info("size"+tenantIds.size());
        // Build audit details for mdms objects creation
        AuditDetails auditDetails = new AuditDetails();
        RequestInfo requestInfo = masterDataMigrationRequest.getRequestInfo();
        AuditDetailsEnrichmentUtil.enrichAuditDetails(auditDetails, requestInfo, Boolean.TRUE);

        List<Mdms> masterDataList = new ArrayList<>();

        tenantIds.stream().forEach(tenantId -> {
                if (tenantMap.containsKey(tenantId.toLowerCase())) {
                    tenantMap.get(tenantId.toLowerCase()).keySet().forEach(module -> {
                        if (module.equals("common-masters")  /*|| module.equals("common-masters")
                        || module.equals("DIGIT-UI") || module.equals("DataSecurity") || module.equals("mseva")*/) {

                            tenantMap.get(tenantId.toLowerCase()).get(module).keySet().forEach(master -> {
                                if ( master.equals("uiCommonConstants")  /*||
                             master.equals("EmployeeStatus") || master.equals("Specalization") ||master.equals("EmploymentTest")/*||master.equals("UsageCategory") ||
                              master.equals("PTApplication") ||master.equals("Rebate") || master.equals("OwnerShipCategory") */) {
                                    // Get master data array for current module and master
                                    JSONArray masterDataJsonArray = MDMSApplicationRunnerImpl
                                            .getTenantMap()
                                            .get(tenantId.toLowerCase())
                                            .get(module)
                                            .get(master);

                                    // Build MDMS objects
                                    masterDataJsonArray.forEach(masterDatum -> {
                                        // Convert JSONArray member to JsonNode
                                        log.info("master data :" + master);
                                        JsonNode masterDatumJsonNode = objectMapper.valueToTree(masterDatum);
                                        //if(master.equals("Penalty"))
                                        // Build MDMS objects
                                  /*      if("RESIDENTIAL".equalsIgnoreCase(masterDatumJsonNode.get("buildingType").asText()) || "COMMERCIAL".equalsIgnoreCase(masterDatumJsonNode.get("buildingType").asText())) {
                                           if ("Water consumption".equalsIgnoreCase(masterDatumJsonNode.get("calculationAttribute").asText()) || "Flat".equalsIgnoreCase(masterDatumJsonNode.get("calculationAttribute").asText())) {*/
                                                Mdms mdms = Mdms.builder()
                                                        .schemaCode(module + DOT_SEPARATOR + master)
                                                        .data(masterDatumJsonNode)
                                                        .isActive(Boolean.TRUE)
                                                        .tenantId(tenantId.toLowerCase())
                                                        .uniqueIdentifier(UUID.randomUUID().toString())
                                                        .auditDetails(auditDetails)
                                                        .build();

                                                MdmsRequest mdmsRequest = MdmsRequest.builder()
                                                        .mdms(mdms)
                                                        .requestInfo(requestInfo)
                                                        .build();


                                                log.info("mdmsrequest:" + mdmsRequest);
                                                // TODO - Make call to MDMS Service with the created request
                                                restTemplate.postForObject("http://localhost:8094/uat/mdms-v2/v2/_create/" + mdmsRequest.getMdms().getSchemaCode(), mdmsRequest, Map.class);
                                           //}
                                        //}
                                    });
                                }
                            });
                        }
                    });

                } else {
                    throw new CustomException(MASTER_DATA_MIGRATION_ERROR_CODE, MASTER_DATA_MIGRATION_TENANTID_DOES_NOT_EXIST_ERROR_MESSAGE + masterDataMigrationRequest.getMasterDataMigrationCriteria().getTenantId());
                }
        });

    }

}
