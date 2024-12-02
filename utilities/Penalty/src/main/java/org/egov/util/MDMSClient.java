package org.egov.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.ObjectReader;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import net.minidev.json.JSONArray;
import org.egov.common.contract.request.RequestInfo;
import org.egov.config.PenaltyShedularConfiguration;
import org.egov.mdms.model.*;
import org.egov.model.Tenant;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import javax.annotation.PostConstruct;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

@Component
@Slf4j
@AllArgsConstructor
@NoArgsConstructor
public class MDMSClient {

    @Autowired
    private PenaltyShedularConfiguration adapterConfiguration;

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    private List<Tenant> tenantids = null;

    @PostConstruct
    protected void loadTenantsFromMdms() {
        try {
            MasterDetail masterDetail = MasterDetail.builder().name(PenaltySchedularConstant.MDMS_TENANT_MASTER_NAME).build();
            ModuleDetail moduleDetail = ModuleDetail.builder().moduleName(PenaltySchedularConstant.MDMS_MODULE_NAME)
                    .masterDetails(Arrays.asList(masterDetail)).build();

            MdmsCriteria mdmsCriteria = MdmsCriteria.builder().tenantId(adapterConfiguration.getTenantId())
                    .moduleDetails(Arrays.asList(moduleDetail)).build();

            MdmsCriteriaReq mdmsCriteriaReq = MdmsCriteriaReq.builder().requestInfo(RequestInfo.builder().build())
                    .mdmsCriteria(mdmsCriteria).build();

            //header
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            //request
            HttpEntity<MdmsCriteriaReq> request = new HttpEntity<>(mdmsCriteriaReq, headers);

            ResponseEntity<MdmsResponse> response =
                    restTemplate.postForEntity(adapterConfiguration.getEgovMdmsHost() + adapterConfiguration.getEgovMdmsSearchUrl(),
                            request, MdmsResponse.class);

            MdmsResponse mdmsResponse = null;
            if (response != null && response.getBody() != null) {
                mdmsResponse = response.getBody();
            }else {
                return;
            }

            if (mdmsResponse != null && (mdmsResponse.getMdmsRes() == null || mdmsResponse.getMdmsRes().isEmpty())) {
                log.info("Tenants file is missing in mdms!!");
            } else {
                if (mdmsResponse.getMdmsRes().get(PenaltySchedularConstant.MDMS_MODULE_NAME) != null && mdmsResponse.getMdmsRes().get(PenaltySchedularConstant.MDMS_MODULE_NAME)
                        .get(PenaltySchedularConstant.MDMS_TENANT_MASTER_NAME) != null) {
                    JSONArray tenantResponse = mdmsResponse.getMdmsRes().get(PenaltySchedularConstant.MDMS_MODULE_NAME)
                            .get(PenaltySchedularConstant.MDMS_TENANT_MASTER_NAME);

                    ObjectReader reader = objectMapper.readerFor(objectMapper.getTypeFactory().constructCollectionType(List.class,
                            Tenant.class));

                    tenantids = reader.readValue(tenantResponse.toString());
                }

            }

        } catch (IOException e) {
            log.info("Error occurred while getting the account to gp mapping from MDMS", e);
        }
    }

    public List<Tenant> getTenants() {
        if (tenantids == null || tenantids.isEmpty()) {
            return Collections.emptyList();
        }
        return tenantids;
    }
}
