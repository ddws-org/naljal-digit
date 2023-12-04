package org.egov.echallan.repository;

import lombok.extern.slf4j.Slf4j;
import org.egov.common.contract.request.RequestInfo;
import org.egov.echallan.config.ChallanConfiguration;
import org.egov.echallan.model.RequestInfoWrapper;
import org.egov.echallan.model.biiling.service.BillResponseDTO;
import org.egov.tracer.model.ServiceCallException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.stereotype.Repository;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Optional;

import static org.egov.echallan.util.ChallanConstants.*;

@Repository
@Slf4j
public class BillingServiceRepository {
    @Autowired
    RestTemplate restTemplate;
    @Autowired
    private ChallanConfiguration applicationConfiguration;

    public Optional<BillResponseDTO> searchBill(String tenantId, String consumerCode, String businessService,
                                                RequestInfo requestInfo) {
        BillResponseDTO billResponseDTO = null;

        String url = applicationConfiguration.getBillingServiceHost()
                + applicationConfiguration.getBillingServiceSearchBillEndpoint();

        String urlTemplate = UriComponentsBuilder.fromHttpUrl(url)
                .queryParam(MGRAMSEVA_TENANT_ID, tenantId)
                .queryParam(BILLING_SERVICE_CONSUMER_CODE, consumerCode)
                .queryParam(BILLING_SERVICE_PARAMETER, businessService)
                .queryParam(RETURN_ALL_BILL_PARAMETER, true)
                .encode()
                .toUriString();

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        RequestInfoWrapper requestInfoWrapper = new RequestInfoWrapper();
        requestInfoWrapper.setRequestInfo(requestInfo);

        HttpEntity<RequestInfoWrapper> entity = new HttpEntity<>(requestInfoWrapper, headers);

        try {
            ResponseEntity<BillResponseDTO> response = restTemplate.exchange(urlTemplate, HttpMethod.POST, entity,
                    BillResponseDTO.class);

            billResponseDTO = response.getBody();

            if (billResponseDTO == null) {
                log.error("Unable to get bill");
                throw new ServiceCallException("Unable to get bill from bill search API");
            }
        } catch (Exception e) {
            throw new ServiceCallException("Exception while sending request to search bill");
        }
        return Optional.ofNullable(billResponseDTO);
    }
}
