package org.egov.mgramsevaifixadaptor.consumer;

import java.util.HashMap;

import org.egov.mgramsevaifixadaptor.config.PropertyConfiguration;
import org.egov.mgramsevaifixadaptor.contract.BillRequestV2;
import org.egov.mgramsevaifixadaptor.util.Constants;
import org.egov.mgramsevaifixadaptor.util.MgramasevaAdapterWrapperUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class MgramasevaAdapterBillConsumer {
	
	@Autowired
	MgramasevaAdapterWrapperUtil util;
	
	@KafkaListener(topics = { "${kafka.topics.create.bill}", "${kafka.topics.update.bill}"})
	public void listen(final HashMap<String, Object> record, @Header(KafkaHeaders.RECEIVED_TOPIC) String topic) throws Exception {
		ObjectMapper mapper = new ObjectMapper();
		BillRequestV2 billRequest=null;
		log.info("create and update bill topic");
		try {
			log.debug("Consuming record: " + record);
			billRequest = mapper.convertValue(record, BillRequestV2.class);
			util.callIFIXAdapter(billRequest, Constants.BILL, billRequest.getBills().get(0).getTenantId(),billRequest.getRequestInfo());
		} catch (final Exception e) {
			log.error("Error while listening to value: " + record + " on topic: " + topic + ": " + e);
		}
		
	}
}