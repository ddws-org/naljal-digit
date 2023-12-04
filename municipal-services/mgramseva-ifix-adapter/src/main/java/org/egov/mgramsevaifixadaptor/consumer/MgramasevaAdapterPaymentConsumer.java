package org.egov.mgramsevaifixadaptor.consumer;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.HashMap;

import org.egov.mgramsevaifixadaptor.config.PropertyConfiguration;
import org.egov.mgramsevaifixadaptor.contract.PaymentRequest;
import org.egov.mgramsevaifixadaptor.models.Bill;
import org.egov.mgramsevaifixadaptor.models.BillDetail;
import org.egov.mgramsevaifixadaptor.models.EventTypeEnum;
import org.egov.mgramsevaifixadaptor.models.PaymentDetail;
import org.egov.mgramsevaifixadaptor.util.Constants;
import org.egov.mgramsevaifixadaptor.util.MgramasevaAdapterWrapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class MgramasevaAdapterPaymentConsumer {

	@Autowired
	MgramasevaAdapterWrapperUtil util;
	
	@KafkaListener(topics = { "${kafka.topics.create.payment}", "${kafka.topics.legacy.payments}" })
	public void listen(final HashMap<String, Object> record, @Header(KafkaHeaders.RECEIVED_TOPIC) String topic)
			throws Exception {
		ObjectMapper mapper = new ObjectMapper();
		PaymentRequest paymentRequest = null;
		log.info("crate payment topic");
		try {
			log.debug("Consuming record: " + record);
			paymentRequest = mapper.convertValue(record, PaymentRequest.class);
			String eventType=null;
			if(paymentRequest.getPayment().getPaymentDetails().get(0).getBusinessService().contains(Constants.EXPENSE))
			{
				eventType=EventTypeEnum.PAYMENT.toString();
			}else {
				eventType=EventTypeEnum.RECEIPT.toString();
			}
			
			if(paymentRequest != null && paymentRequest.getPayment() != null &&
					!CollectionUtils.isEmpty(paymentRequest.getPayment().getPaymentDetails())) {
				for(PaymentDetail pd : paymentRequest.getPayment().getPaymentDetails()) {
					pd.getBill().getBillDetails().removeIf(bd -> bd.getAmountPaid().equals(BigDecimal.ZERO));
				}
			}
			util.callIFIXAdapter(paymentRequest, eventType, paymentRequest.getPayment().getTenantId(),paymentRequest.getRequestInfo());
		} catch (final Exception e) {
			log.error("Error while listening to value: " + record + " on topic: " + topic + ": " + e);
		}

		// TODO enable after implementation
	}
	
	@KafkaListener(topics = { "${kafka.topics.cancel.payment}" })
	public void listenForCancel(final HashMap<String, Object> record, @Header(KafkaHeaders.RECEIVED_TOPIC) String topic)
			throws Exception {
		ObjectMapper mapper = new ObjectMapper();
		PaymentRequest paymentRequest = null;
		log.info("cancel payment topic");
		try {
			log.debug("Consuming record: " + record);
			paymentRequest = mapper.convertValue(record, PaymentRequest.class);
			log.info("paymentRequest: "+paymentRequest);
			String eventType=null;
			if(paymentRequest.getPayment().getPaymentDetails().get(0).getBusinessService().contains(Constants.EXPENSE))
			{
				eventType=EventTypeEnum.PAYMENT.toString();
			}else {
				eventType=EventTypeEnum.RECEIPT.toString();
			}
			paymentRequest.getPayment().getPaymentDetails().get(0).getBill().getBillDetails().get(0).getBillAccountDetails().get(0).setAmount(paymentRequest.getPayment().getPaymentDetails().get(0).getBill().getBillDetails().get(0).getBillAccountDetails().get(0).getAmount().negate());			
			paymentRequest.getPayment().getPaymentDetails().get(0).getBill().getBillDetails().get(0).getBillAccountDetails().get(0).setAdjustedAmount(paymentRequest.getPayment().getPaymentDetails().get(0).getBill().getBillDetails().get(0).getBillAccountDetails().get(0).getAdjustedAmount().negate());
			util.callIFIXAdapter(paymentRequest, eventType, paymentRequest.getPayment().getTenantId(),paymentRequest.getRequestInfo());
		} catch (final Exception e) {
			log.error("Error while listening to value: " + record + " on topic: " + topic + ": " + e);
		}

		// TODO enable after implementation
	}
	
}