package org.egov.mgramsevaifixadaptor.controller;

import java.util.ArrayList;
import java.util.List;

import jakarta.validation.Valid;

import org.egov.mgramsevaifixadaptor.config.PropertyConfiguration;
import org.egov.mgramsevaifixadaptor.contract.DemandRequest;
import org.egov.mgramsevaifixadaptor.contract.PaymentRequest;
import org.egov.mgramsevaifixadaptor.models.Demand;
import org.egov.mgramsevaifixadaptor.models.DemandResponse;
import org.egov.mgramsevaifixadaptor.models.Payment;
import org.egov.mgramsevaifixadaptor.models.PaymentResponse;
import org.egov.mgramsevaifixadaptor.models.RequestInfoWrapper;
import org.egov.mgramsevaifixadaptor.models.SearchCriteria;
import org.egov.mgramsevaifixadaptor.producer.Producer;
import org.egov.mgramsevaifixadaptor.service.AdopterService;
import org.egov.mgramsevaifixadaptor.util.ResponseInfoFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;


@RestController
@RequestMapping("/mGramsevaAdopter/v1")
public class MgramsevaAdapterController {

	@Autowired
	private ResponseInfoFactory responseInfoFactory;

	@Autowired
	AdopterService adopterService;
	
	@Autowired
	Producer producer;

	@Autowired
	private PropertyConfiguration config;
	
	

	@RequestMapping(value = "/_legacydatatransfer", method = RequestMethod.POST)
	public ResponseEntity<DemandResponse> planeSearch(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute SearchCriteria criteria) {
		List<Demand> demands = new ArrayList<Demand>();
		List<String> tenantIds = requestInfoWrapper.getTenantIds();
		if(!tenantIds.isEmpty()) {
			for(String tenantId : tenantIds) {
				List<Demand> demandList = adopterService.legecyDemand(criteria, requestInfoWrapper.getRequestInfo(),tenantId);
				demands.addAll(demandList);
			}
		}
		DemandResponse response = new DemandResponse();
		if (!demands.isEmpty() && demands.size() > 0) {
			for (Demand demand : demands) {
				DemandRequest demandRequest = new DemandRequest();
				demandRequest.setRequestInfo(requestInfoWrapper.getRequestInfo());
				demandRequest.getDemands().add(demand);
				producer.push(config.getCreateLegacyDemandTopic(), demandRequest);
			}
			response = DemandResponse.builder().demands(demands).responseInfo(
					responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true))
					.build();
		}
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
	
	
	@RequestMapping(value = "/_paymentdatatransfer", method = RequestMethod.POST)
	public ResponseEntity<PaymentResponse> paymentDataTransfer(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute SearchCriteria criteria) {
		List<Payment> payments = adopterService.legecyPayment(criteria, requestInfoWrapper.getRequestInfo());
		PaymentResponse response = new PaymentResponse();
		if (!payments.isEmpty() && payments.size() > 0) {
			for (Payment payment : payments) {
				PaymentRequest paymentRequest = new PaymentRequest();
				paymentRequest.setRequestInfo(requestInfoWrapper.getRequestInfo());
				paymentRequest.setPayment(payment);
				producer.push(config.getPaymentsTopic(), paymentRequest);
			}
			response = PaymentResponse.builder().payments(payments).responseInfo(
					responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true))
					.build();
		}
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
}
