package org.egov.naljalcustomisation.config;

import lombok.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder

@Component
public class CustomisationConfiguration {

    @Value("${egov.wscal.bulk.demand.schedular.topic}")
    private String bulkDemandSchedularTopic;

    @Value("${egov.user.event.notification.enabled}")
    private Boolean isUserEventsNotificationEnabled;

    @Value("${egov.usr.events.create.topic}")
    private String saveUserEventsTopic;

    @Value("${notification.sms.enabled}")
    private Boolean isSMSEnabled;

    // Localization
    @Value("${egov.localization.host}")
    private String localizationHost;

    @Value("${egov.localization.context.path}")
    private String localizationContextPath;

    @Value("${egov.localization.search.endpoint}")
    private String localizationSearchEndpoint;

    @Value("${egov.user.create.path}")
    private String userCreateEndPoint;

    @Value("${egov.user.update.path}")
    private String userUpdateEndPoint;

    @Value("${egov.user.search.path}")
    private String userSearchEndpoint;

    @Value("${egov.ui.path}")
    private String uiPath;

    @Value("${egov.month.revenue.dashboard.link}")
    private String monthRevenueDashboardLink;

    @Value("${egov.url.shortner.host}")
    private String urlShortnerHost;

    @Value("${egov.url.shortner.endpoint}")
    private String urlShortnerEndpoint;

    // SMS
    @Value("${kafka.topics.notification.sms}")
    private String smsNotifTopic;

    @Value("${sms.pending.collection.enabled}")
    private boolean isSMSForPendingCollectionEnabled;

    @Value("${egov.pending.collection.link}")
    private String pendingCollectionLink;

    //MDMS
    @Value("${egov.mdms.host}")
    private String mdmsHost;

    @Value("${egov.mdms.search.endpoint}")
    private String mdmsEndPoint;

    @Value("${egov.today.collection.link}")
    private String todayCollectionLink;

    @Value("${sms.todays.collection.enabled}")
    private boolean isSMSForTodaysCollectionEnabled;

    @Value("${egov.user.event.notification.enabled}")
    private Boolean isUserEventEnabled;

    @Value("${egov.monthly.summary.link}")
    private String monthlySummary;

    //USER EVENTS
    @Value("${egov.ui.app.host}")
    private String uiAppHost;

    @Value("${sms.monthy.summary.enabled}")
    private boolean isSmsForMonthlySummaryEnabled;

    @Value("${egov.new.Expenditure.link}")
    private String newExpenditureLink;

    @Value("${egov.expenditure.link}")
    private String expenditureLink;

    @Value("${sms.expenditure.enabled}")
    private boolean isSmsForExpenditureEnabled;

    @Value("${egov.mark.paid.Expenditure.link}")
    private String markPaidExpenditureLink;

    @Value("${egov.expense.bill.markpaid.link}")
    private String expenseBillMarkPaidLink;

    @Value("${sms.expenditure.mark.bill.enabled}")
    private boolean isSmsForMarkBillEnabled;


}
