package org.egov.wscalculation.config;

import java.math.BigDecimal;
import java.time.Instant;

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
public class WSCalculationConfiguration {

	@Value("${egov.ws.search.meterReading.pagination.default.limit}")
	private Integer meterReadingDefaultLimit;

	@Value("${egov.ws_calculation.meterReading.default.offset}")
	private Integer meterReadingDefaultOffset;


	/*
	 * Calculator Configs
	 */

	// billing service
	@Value("${egov.billingservice.host}")
	private String billingServiceHost;

	@Value("${egov.taxhead.search.endpoint}")
	private String taxheadsSearchEndpoint;

	@Value("${egov.taxperiod.search.endpoint}")
	private String taxPeriodSearchEndpoint;

	@Value("${egov.demand.create.endpoint}")
	private String demandCreateEndPoint;

	@Value("${egov.demand.update.endpoint}")
	private String demandUpdateEndPoint;

	@Value("${egov.demand.search.endpoint}")
	private String demandSearchEndPoint;
	
	@Value("${egov.bill.fetch.endpoint}")
	private String fetchBillEndPoint;
	
	@Value("${egov.demand.billexpirytime}")
	private Long demandBillExpiryTime;

	@Value("${egov.bill.gen.endpoint}")
	private String billGenEndPoint;

	// MDMS
	@Value("${egov.mdms.host}")
	private String mdmsHost;

	@Value("${egov.mdms.search.endpoint}")
	private String mdmsEndPoint;
	
    	@Value("${egov.bill.gen.endpoint}")
    	private String billGenerateEndpoint;

	// water demand configs

	@Value("${ws.module.code}")
	private String wsModuleCode;

	@Value("${ws.module.minpayable.amount}")
	private Integer ptMinAmountPayable;

	@Value("${ws.financialyear.start.month}")
	private String financialYearStartMonth;
	
	
	@Value("${egov.demand.businessservice}")
	private String businessService;
	  
	@Value("${egov.demand.minimum.payable.amount}")
	 private BigDecimal minimumPayableAmount;
	  
	 //water Registry
	 @Value("${egov.ws.host}")
	 private String waterConnectionHost;

	 @Value("${egov.wc.search.endpoint}")
	 private String waterConnectionSearchEndPoint;
	 
	 //Demand Topic
	 @Value("${ws.calculator.demand.successful.topic}")
	 private String onDemandsSaved;

	 @Value("${ws.calculator.demand.failed}")
	 private String onDemandsFailure;
	 
	 
	//Localization
	@Value("${egov.localization.host}")
	private String localizationHost;
	
	@Value("${egov.localization.context.path}")
	private String localizationContextPath;
	
	@Value("${egov.localization.search.endpoint}")
	private String localizationSearchEndpoint;
	
	@Value("${egov.localization.statelevel}")
	private Boolean isLocalizationStateLevel;
	
	 //SMS
    	@Value("${kafka.topics.notification.sms}")
    	private String smsNotifTopic;

    	@Value("${notification.sms.enabled}")
    	private Boolean isSMSEnabled;
    
    	@Value("${notification.sms.link}")
    	private String smsNotificationLink;
    
    	@Value("${notification.email.enabled}")
    	private Boolean isEmailEnabled;
    
  	//Email
    	@Value("${kafka.topics.notification.mail.name}")
    	private String emailNotifyTopic;
    
    	//User Configuration
    	@Value("${egov.user.host}")
    	private String userHost;

    	@Value("${egov.user.context.path}")
    	private String userContextPath;


    	@Value("${egov.user.search.path}")
    	private String userSearchEndpoint;
    
    	//payment 
    	@Value("${egov.usr.events.pay.triggers}")
   	private String billgenTopic;
    
    
    	//USER EVENTS
	@Value("${egov.ui.app.host}")
	private String uiAppHost;
    
	@Value("${egov.usr.events.create.topic}")
	private String saveUserEventsTopic;
		
	@Value("${egov.usr.events.pay.link}")
	private String payLink;
	
	@Value("${egov.usr.events.pay.code}")
	private String payCode;
	
	@Value("${egov.user.event.notification.enabled}")
	private Boolean isUserEventsNotificationEnabled;

	@Value("${kafka.topics.billgen.topic}")
   	private String payTriggers;
	
	@Value("${egov.watercalculatorservice.createdemand.topic}")
	private String createDemand;
	
    	@Value("${ws.demand.based.batch.size}")
    	private Integer batchSize;
    
    	@Value("${persister.demand.based.dead.letter.topic.batch}")
    	private String deadLetterTopicBatch;

    	@Value("${persister.demand.based.dead.letter.topic.single}")
    	private String deadLetterTopicSingle;
    
    
    	@Value("${notification.url}")
    	private String notificationUrl;

    	@Value("${egov.shortener.url}")
	private String shortenerURL;
     
    	@Value("${egov.property.service.host}")
	private String propertyHost;

	@Value("${egov.property.searchendpoint}")
	private String searchPropertyEndPoint;

	@Value("${workflow.workDir.path}")
	private String workflowHost;

	@Value("${workflow.process.search.path}")
	private String searchWorkflowProcessEndPoint;
	
	@Value("${download.bill.link.path}")
	private String downLoadBillLink;

	@Value("${bulk.demand.link}")
	private String bulkDemandLink;
	
	//URL Shorting
	
    @Value("${egov.url.shortner.host}")
    private String urlShortnerHost;
    
    @Value("${egov.url.shortner.endpoint}")
    private String urlShortnerEndpoint;
    
    // Demand SMS link 

	@Value("${egov.demand.gp.user.link}")
	private String gpUserDemandLink;
	
	@Value("${egov.sms.bill.download.link}")
	private String billDownloadSMSLink;
	
	//Bulk Demand configuration Topics


	@Value("${egov.wscal.bulk.demand.schedular.topic}")
	private String bulkDemandSchedularTopic;
	
	@Value("${egov.generate.bulk.demand.manually.topic}")
	private String generateBulkDemandTopic;

	@Value("${egov.bilk.demand.failed.link}")
	private String bulkDemandFailedLink;

	@Value("${egov.sms.bill.payment.link}")
	private String billPaymentSMSLink;

	@Value("${egov.pspcl.vendor.number}")
	private String pspclVendorNumber;

	@Value("${sms.demand.enabled}")
	private  boolean isSmsForDemandEnable;

	@Value("${sms.payment.link.enabled}")
	private  boolean isSmsForPaymentLinkEnable;

	@Value("${sms.bill.download.enabled}")
	private boolean isSmsForBillDownloadEnabled;

	@Value("${sms.exclude.tenant}")
	private String smsExcludeTenant;

	@Value("${mGram.Consumer.NewBill}")
	private String billLocalizationCode;

	@Value("${bill.expriy.time}")
	private Long expiriyTime;
	
	@Value("${is.save.demand.audit.enabled}")
	private boolean isSaveDemandAuditEnabled;

	@Value("${egov.save.demand.audit.from.wscal}")
	private String saveDemandAudit;

	@Value("${penalty.applicable.in.days}")
	private Integer penaltyApplicableDays;

	@Value("${penalty.start.threshold.time}")
	private String penaltyStartThresholdTime;

	@Value("${is.penalty.feature.enable}")
	private boolean isPenaltyEnabled;

	@Value("${egov.update.demand.add.penalty}")
	private String updateAddPenaltytopic;

	@Value("${ws.generate.demand.bulk}")
	private String wsGenerateDemandBulktopic;

	@Value("${kafka.topic.roll.out.dashboard}")
	private String rollOutDashBoardTopic;

	@Value("${bulk.demand.duplicateCheck.duration.hours}")
	private Integer duplicateBulkDemandDurationHours;
	
}
