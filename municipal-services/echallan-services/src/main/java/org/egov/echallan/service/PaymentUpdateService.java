package org.egov.echallan.service;


import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.egov.common.contract.request.RequestInfo;
import org.egov.echallan.config.ChallanConfiguration;
import org.egov.echallan.expense.validator.ExpenseValidator;
import org.egov.echallan.model.AuditDetails;
import org.egov.echallan.model.Challan;
import org.egov.echallan.model.Challan.StatusEnum;
import org.egov.echallan.model.ChallanRequest;
import org.egov.echallan.model.SearchCriteria;
import org.egov.echallan.producer.Producer;
import org.egov.echallan.util.CommonUtils;
import org.egov.echallan.web.models.collection.Payment;
import org.egov.echallan.web.models.collection.PaymentDetail;
import org.egov.echallan.web.models.collection.PaymentRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;
 

@Service
@Slf4j
public class PaymentUpdateService {
	
	@Autowired
	private ObjectMapper mapper; 
	
	@Autowired
	private ChallanService challanService;
	
	@Autowired
	private Producer producer;
	
	@Autowired
	private ChallanConfiguration config;
	
	@Autowired
	 private CommonUtils commUtils;

	@Autowired
	private CommonUtils utils;

	@Autowired
	private ExpenseValidator expenseValidator;

	@Autowired
	private UserService userService;
	
	
	
	public void process(HashMap<String, Object> record) {

		try {
			log.info("Process for object"+ record);
			PaymentRequest paymentRequest = mapper.convertValue(record, PaymentRequest.class);
			RequestInfo requestInfo = paymentRequest.getRequestInfo();
			//Update the challan only when the payment is fully done.
			if( paymentRequest.getPayment().getTotalAmountPaid().compareTo(paymentRequest.getPayment().getTotalDue())!=0) 
				return;
			List<PaymentDetail> paymentDetails = paymentRequest.getPayment().getPaymentDetails();
			for (PaymentDetail paymentDetail : paymentDetails) {
				SearchCriteria criteria = new SearchCriteria();
				criteria.setTenantId(paymentRequest.getPayment().getTenantId());
				criteria.setReferenceId(paymentDetail.getBill().getConsumerCode());
				criteria.setBusinessService(paymentDetail.getBusinessService());
				Map<String, String> finalData = new HashMap<String, String>();
				List<Challan> challans = challanService.search(criteria, requestInfo, finalData);
				//update challan only if payment is done for challan.

				if(!CollectionUtils.isEmpty(challans) ) {
					String uuid = requestInfo.getUserInfo().getUuid();
				    AuditDetails auditDetails = commUtils.getAuditDetails(uuid, true);

					challans.forEach(challan -> {
						ChallanRequest challanRequest = new ChallanRequest(requestInfo, challan);
						Object mdmsData = utils.mDMSCall(challanRequest);
						expenseValidator.validateFields(challanRequest, mdmsData);
						userService.setAccountUser(challanRequest);

						challan.setApplicationStatus(StatusEnum.PAID);
						challan.setIsBillPaid(true);
						challan.setAuditDetails(auditDetails);
						ChallanRequest request = ChallanRequest.builder().requestInfo(requestInfo).challan(challan).build();
						producer.push(config.getUpdateChallanTopic(), request);
					});
				}
			}
		} catch (Exception e) {
			log.error("Exception while processing payment update: ",e);
		}

	}

}
