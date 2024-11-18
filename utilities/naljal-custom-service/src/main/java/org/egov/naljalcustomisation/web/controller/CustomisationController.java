package org.egov.naljalcustomisation.web.controller;

import jakarta.validation.Valid;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;
import lombok.extern.slf4j.Slf4j;
import org.egov.common.contract.models.RequestInfoWrapper;
import org.egov.naljalcustomisation.service.CustomisationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@Getter
@Setter
@Builder
@RestController
public class CustomisationController {

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
}
