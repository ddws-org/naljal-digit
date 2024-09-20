package org.egov.naljalcustomisation.service;

import org.egov.common.contract.request.RequestInfo;

public interface CustomisationService {

    void generateDemandBasedOnTimePeriod(RequestInfo requestInfo, boolean isSendMessage);

    void sendPendingCollectionEvent(RequestInfo requestInfo);

    void sendTodaysCollection(RequestInfo requestInfo);

    void sendMonthSummaryEvent(RequestInfo requestInfo);

    void sendNewExpenditureEvent(RequestInfo requestInfo);

    void sendMarkExpensebillEvent(RequestInfo requestInfo);
}
