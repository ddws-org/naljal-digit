package org.egov.naljalcustomisation.web.controller;

import jakarta.validation.Valid;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.egov.naljalcustomisation.web.model.RequestInfoWrapper;
import org.egov.naljalcustomisation.service.CustomisationService;
import org.egov.naljalcustomisation.util.ResponseInfoFactory;
import org.egov.naljalcustomisation.web.model.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Slf4j
@Getter
@Setter
@Builder
@RestController
public class CustomisationController {

    @Autowired
    private final ResponseInfoFactory responseInfoFactory;

    @Autowired
    private CustomisationService customisationService;

    @PostMapping("/_jobscheduler/{isSendMessage}")
    public void jobscheduler(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper, @PathVariable boolean isSendMessage) {
        customisationService.generateDemandBasedOnTimePeriod(requestInfoWrapper.getRequestInfo(), isSendMessage);
    }

    @PostMapping("/_schedulerpendingcollection")
    public void schedulerpendingcollection(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
        customisationService.sendPendingCollectionEvent(requestInfoWrapper.getRequestInfo());
    }

    @PostMapping("/_schedulerTodaysCollection")
    public void schedulerTodaysCollection(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
        customisationService.sendTodaysCollection(requestInfoWrapper.getRequestInfo());
    }

    @PostMapping("/_schedulermonthsummary")
    public void schedulermonthsummary(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
        customisationService.sendMonthSummaryEvent(requestInfoWrapper.getRequestInfo());
    }

    @PostMapping("/_schedulernewexpenditure")
    public void schedulernewexpenditure(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
        customisationService.sendNewExpenditureEvent(requestInfoWrapper.getRequestInfo());
    }

    @PostMapping("/_schedulermarkexpensebill")
    public void schedulermarkexpensebill(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
        customisationService.sendMarkExpensebillEvent(requestInfoWrapper.getRequestInfo());
    }

    @RequestMapping(value = "/_billReport", method = RequestMethod.POST)
    public ResponseEntity<BillReportResponse> billReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
                                                         @RequestParam(value = "demandStartDate", required = true) String demandStartDate, @RequestParam(value = "demandEndDate", required = true) String demandEndDate, @RequestParam(value = "tenantId", required = true) String tenantId, @RequestParam(value = "offset", required = true) Integer offset, @RequestParam(value = "limit", required = true) Integer limit, @RequestParam(value = "sortOrder") String sortOrder) {
        List<BillReportData> billReport = customisationService.billReport(demandStartDate, demandEndDate, tenantId, offset, limit, sortOrder, requestInfoWrapper.getRequestInfo());

        BillReportResponse response = BillReportResponse.builder().BillReportData(billReport)
                .responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
                        true))
                .build();
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @RequestMapping(value = "/_collectionReport", method = RequestMethod.POST)
    public ResponseEntity<CollectionReportResponse> collectionReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
                                                                     @RequestParam(value = "paymentStartDate", required = true) String paymentStartDate, @RequestParam(value = "paymentEndDate", required = true) String paymentEndDate, @RequestParam(value = "tenantId", required = true) String tenantId, @RequestParam(value = "offset", required = true) Integer offset, @RequestParam(value = "limit", required = true) Integer limit, @RequestParam(value = "sortOrder") String sortOrder) {
        List<CollectionReportData> collectionReport = customisationService.collectionReport(paymentStartDate, paymentEndDate, tenantId, offset, limit, sortOrder, requestInfoWrapper.getRequestInfo());

        CollectionReportResponse response = CollectionReportResponse.builder().CollectionReportData(collectionReport)
                .responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
                        true))
                .build();
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @RequestMapping(value = "/_inactiveConsumerReport", method = RequestMethod.POST)
    public ResponseEntity<InactiveConsumerReportResponse> inactiveConsumerReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
                                                                                 @RequestParam(value = "monthStartDate", required = true) String monthStartDate, @RequestParam(value = "monthEndDate", required = true) String monthEndDate,
                                                                                 @RequestParam(value = "tenantId", required = true) String tenantId, @RequestParam(value = "offset", required = true) Integer offset, @RequestParam(value = "limit", required = true) Integer limit) {
        List<InactiveConsumerReportData> inactiveConsumerReport = customisationService.inactiveConsumerReport(monthStartDate, monthEndDate, tenantId, offset, limit, requestInfoWrapper.getRequestInfo());
        InactiveConsumerReportResponse response = InactiveConsumerReportResponse.builder().InactiveConsumerReportData(inactiveConsumerReport)
                .responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true)).build();

        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @RequestMapping(value = "/_countWCbyDemandGenerationDate", method = RequestMethod.POST)
    public ResponseEntity<WaterConnectionByDemandGenerationDateResponse> countWCbyDemandGenerationDate(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper, @Valid @ModelAttribute SearchCriteria criteria) {
        WaterConnectionByDemandGenerationDateResponse response = customisationService.countWCbyDemandGennerationDate(criteria, requestInfoWrapper.getRequestInfo());
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @PostMapping("/consumers/demand-not-generated")
    public ResponseEntity<WaterConnectionResponse> getConsumersWithDemandNotGenerated(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper, @RequestParam(value = "previousMeterReading") String previousMeterReading, @RequestParam(value = "tenantId") String tenantId) {
        WaterConnectionResponse response = customisationService.getConsumersWithDemandNotGenerated(previousMeterReading, tenantId, requestInfoWrapper.getRequestInfo());
        response.setResponseInfo(
                responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true));
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @PostMapping("/ledger-report")
    public ResponseEntity<LedgerReportResponse> getLedgerReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper, @RequestParam String consumercode, @RequestParam String tenantId, @RequestParam Integer offset, @RequestParam Integer limit, @RequestParam String year) {
        List<Map<String, Object>> list = customisationService.ledgerReport(consumercode, tenantId, offset, limit, year, requestInfoWrapper);
        LedgerReportResponse response = LedgerReportResponse.builder().ledgerReport(list).
                responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true)).
                tenantName(tenantId).financialYear(year).build();
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @PostMapping("/month-report")
    public ResponseEntity<?> getMonthReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper, @RequestParam String startDate, @RequestParam String endDate, @RequestParam String tenantId, @RequestParam Integer offset, @RequestParam Integer limit, @RequestParam String sortOrder) {
        List<MonthReport> monthReportList = customisationService.monthReport(startDate, endDate, tenantId, offset, limit, sortOrder);
        MonthReportResponse monthReportResponse = MonthReportResponse.builder().monthReport(monthReportList).
                tenantName(tenantId).month(startDate.concat("-" + endDate)).
                responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true)).build();
        return new ResponseEntity<>(monthReportResponse, HttpStatus.OK);
    }

    @PostMapping("/_lastMonthSummary")
    public ResponseEntity<LastMonthSummaryResponse> lastMonthSummary(
            @RequestBody @Valid final RequestInfoWrapper requestInfoWrapper,
            @Valid @ModelAttribute SearchCriteria criteria) {
        LastMonthSummary lastMonthSummary = customisationService.getLastMonthSummary(criteria,
                requestInfoWrapper.getRequestInfo());

        LastMonthSummaryResponse response = LastMonthSummaryResponse.builder().LastMonthSummary(lastMonthSummary)
                .responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
                        true))
                .build();
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @PostMapping("/_revenueDashboard")
    public ResponseEntity<RevenueDashboardResponse> _revenueDashboard(
            @RequestBody @Valid final RequestInfoWrapper requestInfoWrapper,
            @Valid @ModelAttribute SearchCriteria criteria) {
        RevenueDashboard dashboardData = customisationService.getRevenueDashboardData(criteria,
                requestInfoWrapper.getRequestInfo());

        RevenueDashboardResponse response = RevenueDashboardResponse.builder().RevenueDashboard(dashboardData)
                .responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
                        true))
                .build();
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @PostMapping("/_revenueCollectionData")
    public ResponseEntity<RevenueCollectionDataResponse> _revenueCollectionData(@RequestBody @Valid final RequestInfoWrapper requestInfoWrapper,
                                                                                @Valid @ModelAttribute SearchCriteria criteria) {
        List<RevenueCollectionData> collectionData = customisationService.getRevenueCollectionData(criteria,
                requestInfoWrapper.getRequestInfo());

        RevenueCollectionDataResponse response = RevenueCollectionDataResponse.builder().RevenueCollectionData(collectionData)
                .responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
                        true))
                .build();

        return new ResponseEntity<>(response, HttpStatus.OK);
    }
}
