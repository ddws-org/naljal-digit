package org.egov.naljalcustomisation.service;

import jakarta.validation.Valid;
import org.egov.common.contract.request.RequestInfo;
import org.egov.naljalcustomisation.web.model.*;

import java.util.List;
import java.util.Map;

public interface CustomisationService {

    void generateDemandBasedOnTimePeriod(RequestInfo requestInfo, boolean isSendMessage);

    void sendPendingCollectionEvent(RequestInfo requestInfo);

    void sendTodaysCollection(RequestInfo requestInfo);

    void sendMonthSummaryEvent(RequestInfo requestInfo);

    void sendNewExpenditureEvent(RequestInfo requestInfo);

    void sendMarkExpensebillEvent(RequestInfo requestInfo);

    List<BillReportData> billReport(@Valid String demandStartDate, @Valid String demandEndDate, @Valid String tenantId, @Valid Integer offset, @Valid Integer limit, @Valid String sortOrder, RequestInfo requestInfo);

    List<CollectionReportData> collectionReport(String paymentStartDate, String paymentEndDate, String tenantId,@Valid Integer offset, @Valid Integer limit, @Valid String sortOrder,
                                                RequestInfo requestInfo);
    List<InactiveConsumerReportData> inactiveConsumerReport(String monthStartDate, String monthEndDate, String tenantId, @Valid Integer offset, @Valid Integer limit, RequestInfo requestInfo);

    WaterConnectionByDemandGenerationDateResponse countWCbyDemandGennerationDate(SearchCriteria criteria, RequestInfo requestInfo);

    WaterConnectionResponse getConsumersWithDemandNotGenerated(String previousMeterReading, String tenantId,RequestInfo requestInfo);

    List<Map<String, Object>> ledgerReport(String consumercode, String tenantId, Integer offset, Integer limit, String year, RequestInfoWrapper requestInfoWrapper);

    List<MonthReport> monthReport(String startDate, String endDate, String tenantId, Integer offset, Integer limit,String sortOrder);

    LastMonthSummary getLastMonthSummary(@Valid SearchCriteria criteria, RequestInfo requestInfo);

    RevenueDashboard getRevenueDashboardData(@Valid SearchCriteria criteria, RequestInfo requestInfo);

    List<RevenueCollectionData> getRevenueCollectionData(@Valid SearchCriteria criteria, RequestInfo requestInfo);

}
