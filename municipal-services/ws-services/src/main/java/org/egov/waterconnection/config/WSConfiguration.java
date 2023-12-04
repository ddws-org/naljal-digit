package org.egov.waterconnection.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder

@Component
public class WSConfiguration {

	@Value("${egov.waterservice.pagination.default.limit}")
	private Integer defaultLimit;

	@Value("${egov.waterservice.pagination.default.offset}")
	private Integer defaultOffset;

	@Value("${egov.waterservice.pagination.max.limit}")
	private Integer maxLimit;

	// IDGEN
	@Value("${egov.idgen.wcid.name}")
	private String waterConnectionIdGenName;

	@Value("${egov.idgen.wcid.format}")
	private String waterConnectionIdGenFormat;

	@Value("${egov.idgen.wcapid.name}")
	private String waterApplicationIdGenName;

	@Value("${egov.idgen.wcapid.format}")
	private String waterApplicationIdGenFormat;

	// Idgen Config
	@Value("${egov.idgen.host}")
	private String idGenHost;

	@Value("${egov.idgen.path}")
	private String idGenPath;

	// Workflow
	@Value("${create.ws.workflow.name}")
	private String businessServiceValue;

	@Value("${workflow.context.path}")
	private String wfHost;

	@Value("${workflow.transition.path}")
	private String wfTransitionPath;

	@Value("${workflow.businessservice.search.path}")
	private String wfBusinessServiceSearchPath;
	
	@Value("${workflow.process.search.path}")
	private String wfProcessSearchPath;

	@Value("${is.external.workflow.enabled}")
	private Boolean isExternalWorkFlowEnabled;

	@Value("${egov.waterservice.updatewaterconnection.workflow.topic}")
	private String workFlowUpdateTopic;

	// Localization
	@Value("${egov.localization.host}")
	private String localizationHost;

	@Value("${egov.localization.context.path}")
	private String localizationContextPath;

	@Value("${egov.localization.search.endpoint}")
	private String localizationSearchEndpoint;

	@Value("${egov.localization.statelevel}")
	private Boolean isLocalizationStateLevel;

	// SMS
	@Value("${kafka.topics.notification.sms}")
	private String smsNotifTopic;

	@Value("${notification.sms.enabled}")
	private Boolean isSMSEnabled;

	@Value("${notification.sms.link}")
	private String smsNotificationLink;

	@Value("${notification.url}")
	private String notificationUrl;

	@Value("${egov.usr.events.create.topic}")
	private String saveUserEventsTopic;

	// Water Topic
	@Value("${egov.waterservice.createwaterconnection.topic}")
	private String onWaterSaved;

	@Value("${egov.waterservice.updatewaterconnection.topic}")
	private String onWaterUpdated;

	@Value("${egov.user.event.notification.enabled}")
	private Boolean isUserEventsNotificationEnabled;
	
	//User Configuration
	@Value("${egov.user.host}")
	private String userHost;

    	@Value("${egov.user.context.path}")
    	private String userContextPath;

    	@Value("${egov.user.search.path}")
    	private String userSearchEndpoint;
    
    	// water connection Calculator
    	@Value("${egov.ws.calculation.host}")
    	private String calculatorHost;

    	@Value("${egov.ws.calculation.endpoint}")
    	private String calculateEndpoint;
    
    	@Value("${egov.receipt.businessservice.topic}")
    	private String receiptBusinessservice;
    
    	@Value("${ws.meterreading.create.topic}")
    	private String createMeterReading;
    
    	@Value("${ws.meterreading.create.endpoint}")
    	private String createMeterReadingEndpoint;
    
    	@Value("${ws.mseva.app.link}")
    	private String mSevaAppLink;
    
    	@Value("${ws.view.history.link}")
    	private String viewHistoryLink;
    
    	@Value("${ws.connectiondetails.link}")
    	private String connectionDetailsLink;
    
    	@Value("${ws.application.pay.link}")
    	private String applicationPayLink;
	
	@Value("${egov.msg.download.receipt.link}")
	private String receiptDownloadLink;

	@Value("${egov.usr.events.download.receipt.link}")
	private String userEventReceiptDownloadLink;

	@Value("${egov.usr.events.pay.link}")
	private String userEventApplicationPayLink;
    
    	@Value("${egov.ws.estimate.endpoint}")
    	private String estimationEndpoint;

	@Value("${egov.collectiom.payment.search}")
	private String paymentSearch;
    
    	@Value("${ws.pdfservice.link}")
    	private String pdfServiceLink;
    
    	@Value("${ws.fileStore.link}")
    	private String fileStoreLink;
    
    	@Value("${egov.shortener.url}")
    	private String shortenerURL;
    
    	@Value("${egov.pdfservice.host}")
    	private String pdfServiceHost;
    
    	@Value("${egov.filestore.host}")
    	private String fileStoreHost;
    
    	@Value("${ws.editnotification.topic}")
    	private String editNotificationTopic;
    
	@Value("${ws.consume.filestoreids.topic}")
	private String fileStoreIdsTopic;

	@Value("${egov.waterservice.savefilestoreIds.topic}")
	private String saveFileStoreIdsTopic;
 
	@Value("${egov.user.create.path}")
	private String userCreateEndPoint;

	@Value("${egov.user.update.path}")
	private String userUpdateEndPoint;
	
	@Value("${modify.ws.workflow.name}")
	private String modifyWSBusinessServiceName;

	@Value("${egov.collection.host}")
	private String collectionHost;

	@Value("${state.level.tenant.id}")
	private String stateLevelTenantId;
	
	@Value("${egov.billing.service.host}")
	private String billingHost;
	
	@Value("${egov.demand.searchendpoint}")
	private String demandSearchUri;
	
	@Value("${egov.demand.update.endpoint}")
	private String demandUpdateEndPoint;
	
	@Value("${egov.ws.service.feedback}")
	private String saveFeedback;
	
	@Value("${ws.feedback.survey.link}")
	private String feedbackLink;

	
	@Value("${egov.mgramseva.ui.path}")
	private String webUiPath;
	
	@Value("${egov.ui.path}")
	private String uiPath;
	

    @Value("${egov.url.shortner.host}")
    private String urlShortnerHost;
    @Value("${egov.url.shortner.endpoint}")
    private String urlShortnerEndpoint;

	

	@Value("${egov.month.revenue.dashboard.link}")
	private String monthRevenueDashboardLink;
	
	@Value("${egov.month.dashboard.link}")
	private String monthDashboardLink;
	
	
	@Value("${egov.demand.generation.link}")
	private String demanGenerationLink;
	
	
	@Value("${egov.day.collection.link}")
	private String dayCollectionLink;
	
	
// adding Event notification paths.
	
	@Value("${egov.pending.collection.link}")
	private String pendingCollectionLink;
	
	@Value("${egov.monthly.summary.link}")
	private String monthlySummary;

	@Value("${egov.bilk.demand.failed.link}")
	private String bulkDemandFailedLink;

	@Value("${egov.today.collection.link}")
	private String todayCollectionLink;
	
    //MDMS
    @Value("${egov.mdms.host}")
    private String mdmsHost;

    @Value("${egov.mdms.search.endpoint}")
    private String mdmsEndPoint;
    
    // ES Config

    @Value("${egov.es.host}")
    private String esHost;

    @Value("${egov.waterservice.es.index}")
    private String esWSIndex;

    @Value("${egov.es.search.endpoint}")
    private String esSearchEndpoint;

    @Value("${egov.ws.search.name.fuziness}")
    private String nameFuziness;
    
    @Value("${egov.ws.search.mobileNo.fuziness}")
    private String MobileNoFuziness;

    @Value("${egov.ws.fuzzy.searh.is.wildcard}")
    private Boolean isSearchWildcardBased;
    
    @Value("${egov.ws.search.tenantId.fuziness}")
    private String tenantFuziness;

	@Value("${sms.pending.collection.enabled}")
	private boolean isSMSForPendingCollectionEnabled;

	@Value("${sms.todays.collection.enabled}")
	private boolean isSMSForTodaysCollectionEnabled;

	@Value("${sms.edit.water.connection.notification.enabled}")
	private boolean isSMSForEditWaterConnectionEnabled;

	@Value("${sms.payment.notification.enabled}")
	private boolean isSMSforPaymentNotificationEnabled;

	@Value("${sms.workflow.enabled}")
	private boolean isSMSForWorkflowEnabled;

	@Value("${sms.feedback.notification.enabled}")
	private boolean isSMSForFeedbackNotificationEnabled;
    
}
