package org.egov.mgramsevaifixadaptor.service;

import java.util.List;

import jakarta.validation.Valid;

import org.egov.common.contract.request.RequestInfo;
import org.egov.mgramsevaifixadaptor.config.PropertyConfiguration;
import org.egov.mgramsevaifixadaptor.models.Demand;
import org.egov.mgramsevaifixadaptor.models.DemandResponse;
import org.egov.mgramsevaifixadaptor.models.Payment;
import org.egov.mgramsevaifixadaptor.models.PaymentResponse;
import org.egov.mgramsevaifixadaptor.models.RequestInfoWrapper;
import org.egov.mgramsevaifixadaptor.models.SearchCriteria;
import org.egov.mgramsevaifixadaptor.repository.ServiceRequestRepository;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class AdopterService {

    @Autowired
    private ServiceRequestRepository serviceRequestRepository;

    @Autowired
    private PropertyConfiguration config;

    @Autowired
    private ObjectMapper mapper;
    
    
    
	public List<Demand> legecyDemand(@Valid SearchCriteria criteria, RequestInfo requestInfo, String tenantId) {

		String businessService = criteria.getBusinessService();
		if(tenantId.isEmpty() || tenantId == null) {
			throw new CustomException("MISSING PARAM ERROR","TenantId is mandetory");
		}if(businessService.isEmpty() || businessService == null) {
			throw new CustomException("MISSING PARAM ERROR","Businessservice is mandetory");
		}
		List<Demand> demands = null;
		if(tenantId != null &&  businessService != null) {
			 demands = searchDemand(tenantId,requestInfo,businessService);
		}
		
		return demands;
	}
	/**
     * Searches demand for the given consumerCode and tenantIDd
     * @param tenantId The tenantId of the tradeLicense
     * @param consumerCodes The set of consumerCode of the demands
     * @param requestInfo The RequestInfo of the incoming request
     * @return Lis to demands for the given consumerCode
     */
    private List<Demand> searchDemand(String tenantId,RequestInfo requestInfo, String businessService){
        String uri = getDemandSearchURL();
        String status = "ACTIVE";
        uri = uri.replace("{1}",tenantId);
        uri = uri.replace("{2}",businessService);
        uri = uri.replace("{3}",status);

        Object result = serviceRequestRepository.fetchResult(uri,RequestInfoWrapper.builder()
                                                      .requestInfo(requestInfo).build());
        DemandResponse response;
        try {
             response = mapper.convertValue(result,DemandResponse.class);
        }
        catch (IllegalArgumentException e){
            throw new CustomException("PARSING ERROR","Failed to parse response from Demand Search");
        }

        if(CollectionUtils.isEmpty(response.getDemands()))
            return null;

        else return response.getDemands();

    }
    

    /**
     * Creates demand Search url based on tenanatId,businessService and ConsumerCode
     * @return demand search url
     */
    public String getDemandSearchURL(){
        StringBuilder url = new StringBuilder(config.getBillingHost());
        url.append(config.getDemandSearchEndpoint());
        url.append("?");
        url.append("tenantId=");
        url.append("{1}");
        url.append("&");
        url.append("businessService=");
        url.append("{2}");
        url.append("&");
        url.append("status=");
        url.append("{3}");
        url.append("&");
        return url.toString();
    }
    
	public List<Payment> legecyPayment(@Valid SearchCriteria criteria, RequestInfo requestInfo) {
		String tenantId = criteria.getTenantId();
		String businessService = criteria.getBusinessService();
		if (tenantId.isEmpty() || tenantId == null) {
			throw new CustomException("MISSING PARAM ERROR", "TenantId is mandetory");
		}
		if (businessService.isEmpty() || businessService == null) {
			throw new CustomException("MISSING PARAM ERROR", "Businessservice is mandetory");
		}
		List<Payment> Payments = null;
		if (tenantId != null && businessService != null) {
			Payments = searchPayment(criteria, requestInfo);
		}
		return Payments;
	}

	private List<Payment> searchPayment(SearchCriteria criteria, RequestInfo requestInfo) {
		String uri = getPaymentSearchURL(criteria);
		uri = uri.replace("{1}", criteria.getTenantId());
		uri = uri.replace("{2}", criteria.getBusinessService());

		if (uri.contains("{3}")) {

			uri = uri.replace("{3}", criteria.getLimit());
		}
		if (uri.contains("{4}")) {

			uri = uri.replace("{4}", criteria.getOffset());
		}
		Object result = serviceRequestRepository.fetchResult(uri,
				RequestInfoWrapper.builder().requestInfo(requestInfo).build());
		PaymentResponse response;
		try {
			response = mapper.convertValue(result, PaymentResponse.class);
		} catch (IllegalArgumentException e) {
			throw new CustomException("PARSING ERROR", "Failed to parse response from Demand Search");
		}

		if (CollectionUtils.isEmpty(response.getPayments()))
			return null;

		else
			return response.getPayments();
	}

	private String getPaymentSearchURL(SearchCriteria criteria) {
		StringBuilder url = new StringBuilder(config.getCollectionHost());
		url.append(config.getCollectionPlainSearchEndpoint());
		url.append("?");
		url.append("tenantId=");
		url.append("{1}");
		url.append("&");
		url.append("businessService=");
		url.append("{2}");
		if (criteria.getLimit() != null) {

			url.append("&");
			url.append("limit=");
			url.append("{3}");
		}
		if (criteria.getOffset() != null) {

			url.append("&");
			url.append("offset=");
			url.append("{4}");
		}
		return url.toString();
	}
}
