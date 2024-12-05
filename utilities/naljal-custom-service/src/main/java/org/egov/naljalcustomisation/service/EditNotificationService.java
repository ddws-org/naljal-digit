package org.egov.naljalcustomisation.service;

import lombok.extern.slf4j.Slf4j;
import org.egov.naljalcustomisation.config.CustomisationConfiguration;
import org.egov.naljalcustomisation.producer.CustomisationProducer;
import org.egov.naljalcustomisation.web.model.EventRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class EditNotificationService {

    @Autowired
    private CustomisationProducer producer;

    @Autowired
    private CustomisationConfiguration configuration;

    public void sendEventNotification(EventRequest request) {
        producer.push(configuration.getSaveUserEventsTopic(), request);
    }
}
