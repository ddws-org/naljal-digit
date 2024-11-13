package org.egov.wscalculation.consumer;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.apache.commons.lang3.StringUtils;
import org.egov.common.contract.request.RequestInfo;
import org.egov.tracer.model.CustomException;
import org.egov.wscalculation.config.WSCalculationConfiguration;
import org.egov.wscalculation.constants.WSCalculationConstant;
import org.egov.wscalculation.producer.WSCalculationProducer;
import org.egov.wscalculation.repository.WSCalculationDao;
import org.egov.wscalculation.service.DemandService;
import org.egov.wscalculation.service.EstimationService;
import org.egov.wscalculation.service.MasterDataService;
import org.egov.wscalculation.service.UserService;
import org.egov.wscalculation.service.WSCalculationServiceImpl;
import org.egov.wscalculation.util.CalculatorUtil;
import org.egov.wscalculation.util.NotificationUtil;
import org.egov.wscalculation.util.WSCalculationUtil;
import org.egov.wscalculation.validator.WSCalculationValidator;
import org.egov.wscalculation.validator.WSCalculationWorkflowValidator;
import org.egov.wscalculation.web.models.*;
import org.egov.wscalculation.web.models.users.UserDetailResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.messaging.Message;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class DemandGenerationConsumer {

	@Autowired
	private ObjectMapper mapper;

	@Autowired
	private WSCalculationConfiguration config;

	@Autowired
	private WSCalculationServiceImpl wSCalculationServiceImpl;

	@Autowired
	private WSCalculationProducer producer;

	@Autowired
	private MasterDataService mDataService;

	@Autowired
	private WSCalculationWorkflowValidator wsCalulationWorkflowValidator;

	@Autowired
	private NotificationUtil util;

    @Autowired
    private KafkaTemplate kafkaTemplate;

	@Autowired
	private CalculatorUtil calculatorUtils;

	@Autowired
	private WSCalculationDao waterCalculatorDao;

	@Autowired
	private EstimationService estimationService;

	@Autowired
	private WSCalculationProducer wsCalculationProducer;

	@Autowired
	private UserService userService;

	@Autowired
	private WSCalculationUtil wsCalculationUtil;

	@Autowired
	private WSCalculationValidator wsCalculationValidator;
	
	@Autowired
	private DemandService demandService;

	/**
	 * Listen the topic for processing the batch records.
	 * 
	 * @param records would be calculation criteria.
	 */
	@KafkaListener(topics = {
			"${egov.watercalculatorservice.createdemand.topic}" }, containerFactory = "kafkaListenerContainerFactoryBatch")
	public void listen(final List<Message<?>> records) {
		CalculationReq calculationReq = mapper.convertValue(records.get(0).getPayload(), CalculationReq.class);
		Map<String, Object> masterMap = mDataService.loadMasterData(calculationReq.getRequestInfo(),
				calculationReq.getCalculationCriteria().get(0).getTenantId());
		List<CalculationCriteria> calculationCriteria = new ArrayList<>();
		boolean isSendMessage = false;
		records.forEach(record -> {
			try {
				CalculationReq calcReq = mapper.convertValue(record.getPayload(), CalculationReq.class);
				calculationCriteria.addAll(calcReq.getCalculationCriteria());
			} catch (final Exception e) {
				StringBuilder builder = new StringBuilder();
				try {
					builder.append("Error while listening to value: ").append(mapper.writeValueAsString(record))
							.append(" on topic: ").append(e);
				} catch (JsonProcessingException e1) {
					log.error("KAFKA_PROCESS_ERROR", e1);
				}
				log.error(builder.toString());
			}
		});
		CalculationReq request = CalculationReq.builder().calculationCriteria(calculationCriteria)
				.requestInfo(calculationReq.getRequestInfo()).isconnectionCalculation(true).build();
		try {
			generateDemandInBatch(request, masterMap, config.getDeadLetterTopicBatch(), isSendMessage);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		log.info("Number of batch records:  " + records.size());
	}

	/**
	 * Listens on the dead letter topic of the bulk request and processes every
	 * record individually and pushes failed records on error topic
	 * 
	 * @param records failed batch processing
	 */
	@KafkaListener(topics = {
			"${persister.demand.based.dead.letter.topic.batch}" }, containerFactory = "kafkaListenerContainerFactory")
	public void listenDeadLetterTopic(final List<Message<?>> records) {
		CalculationReq calculationReq = mapper.convertValue(records.get(0).getPayload(), CalculationReq.class);
		Map<String, Object> masterMap = mDataService.loadMasterData(calculationReq.getRequestInfo(),
				calculationReq.getCalculationCriteria().get(0).getTenantId());
		boolean isSendMessage = false;
		records.forEach(record -> {
			try {
				CalculationReq calcReq = mapper.convertValue(record.getPayload(), CalculationReq.class);

				calcReq.getCalculationCriteria().forEach(calcCriteria -> {
					CalculationReq request = CalculationReq.builder().calculationCriteria(Arrays.asList(calcCriteria))
							.requestInfo(calculationReq.getRequestInfo()).isconnectionCalculation(true).build();
					try {
						log.info("Generating Demand for Criteria : " + mapper.writeValueAsString(calcCriteria));
						// processing single
						generateDemandInBatch(request, masterMap, config.getDeadLetterTopicSingle(), isSendMessage);
					} catch (final Exception e) {
						StringBuilder builder = new StringBuilder();
						try {
							builder.append("Error while generating Demand for Criteria: ")
									.append(mapper.writeValueAsString(calcCriteria));
						} catch (JsonProcessingException e1) {
							log.error("KAFKA_PROCESS_ERROR", e1);
						}
						log.error(builder.toString(), e);
					}
				});
			} catch (final Exception e) {
				StringBuilder builder = new StringBuilder();
				builder.append("Error while listening to value: ").append(record).append(" on dead letter topic.");
				log.error(builder.toString(), e);
			}
		});
	}

	/**
	 * Generate demand in bulk on given criteria
	 * 
	 * @param request       Calculation request
	 * @param masterMap     master data
	 * @param errorTopic    error topic
	 * @param isSendMessage
	 */
	private void generateDemandInBatch(CalculationReq request, Map<String, Object> masterMap, String errorTopic,
			boolean isSendMessage) throws Exception {
		/*for (CalculationCriteria criteria : request.getCalculationCriteria()) {
			Boolean genratedemand = true;
			wsCalulationWorkflowValidator.applicationValidation(request.getRequestInfo(), criteria.getTenantId(),
					criteria.getConnectionNo(), genratedemand);
		}*/
		//System.out.println("Calling Bulk Demand generation connection Number" + request.getCalculationCriteria().get(0).getConnectionNo());
		wSCalculationServiceImpl.bulkDemandGeneration(request, masterMap);
		/*String connectionNoStrings = request.getCalculationCriteria().stream()
				.map(criteria -> criteria.getConnectionNo()).collect(Collectors.toSet()).toString();
		StringBuilder str = new StringBuilder("Demand generated Successfully. For records : ")
				.append(connectionNoStrings);*/
//			producer.push(errorTopic, request);
//			remove the try catch or throw the exception to the previous method to catch it.

	}

	/**
	 * 
	 * @param tenantId TenantId for getting master data.
	 */
	@KafkaListener(topics = {
			"${egov.wscal.bulk.demand.schedular.topic}" }, containerFactory = "kafkaListenerContainerFactory")
	public void generateDemandForTenantId(HashMap<Object, Object> messageData) {
		String tenantId;
		RequestInfo requestInfo;
		boolean isSendMessage;
		HashMap<Object, Object> demandData = (HashMap<Object, Object>) messageData;
		tenantId = demandData.get("tenantId").toString();
		isSendMessage = mapper.convertValue(demandData.get("isSendMessage"), boolean.class);
		requestInfo = mapper.convertValue(demandData.get("requestInfo"), RequestInfo.class);
		requestInfo.getUserInfo().setTenantId(tenantId);
		Map<String, Object> billingMasterData = calculatorUtils.loadBillingFrequencyMasterData(requestInfo, tenantId);
		
		generateDemandForULB(billingMasterData, requestInfo, tenantId, isSendMessage);
	}

	/**
	 * 
	 * @param master      Master MDMS Data
	 * @param requestInfo Request Info
	 * @param tenantId    Tenant Id
	 */
	@SuppressWarnings("unchecked")
	public void generateDemandForULB(Map<String, Object> master, RequestInfo requestInfo, String tenantId,
			boolean isSendMessage) {
		log.info("Billing master data values for non metered connection:: {}", master);
		long startDay = (((int) master.get(WSCalculationConstant.Demand_Generate_Date_String)) / 86400000);

		List<Event> events = new ArrayList<>();

		if (isCurrentDateIsMatching((String) master.get(WSCalculationConstant.Billing_Cycle_String), startDay)) {

			LocalDate firstDate = LocalDate.now().with(TemporalAdjusters.firstDayOfMonth());
			LocalDate lastDate = LocalDate.now().with(TemporalAdjusters.lastDayOfMonth());

			DateTimeFormatter formatters = DateTimeFormatter.ofPattern("d/MM/uuuu");
			String fromDate = firstDate.format(formatters);
			String toDate = lastDate.format(formatters);
			String billingCycle = fromDate + " - " + toDate;
			boolean isManual = false;
			log.info("CALL FROM TOPIC egov.wscal.bulk.demand.schedular.topic" );
			generateDemandAndSendnotification(requestInfo, tenantId, billingCycle, master, isSendMessage, isManual);
		}
	}

	@SuppressWarnings("null")
	private void generateDemandAndSendnotification(RequestInfo requestInfo, String tenantId, String billingCycle,
			Map<String, Object> master, boolean isSendMessage, boolean isManual) {
		// TODO Auto-generated method stub
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");


		LocalDate fromDate = LocalDate.parse(billingCycle.split("-")[0].trim(), formatter);
		LocalDate toDate = LocalDate.parse(billingCycle.split("-")[1].trim(), formatter);

		Long dayStartTime = LocalDateTime
				.of(fromDate.getYear(), fromDate.getMonth(), fromDate.getDayOfMonth(), 0, 0, 0)
				.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		Long dayEndTime = LocalDateTime
				.of(toDate.getYear(), toDate.getMonth(), toDate.getDayOfMonth(), 23, 59, 59, 999000000)
				.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		Long StartTimeForGetConnetion = System.currentTimeMillis();
		
		List<String> connectionNos = waterCalculatorDao.getNonMeterConnectionsList(tenantId, dayStartTime, dayEndTime);

		
		
		/*Calendar previousFromDate = Calendar.getInstance();
		Calendar previousToDate = Calendar.getInstance();
		
		previousFromDate.setTimeInMillis(dayStartTime);
		previousToDate.setTimeInMillis(dayEndTime);

		previousFromDate.add(Calendar.MONTH, -1); //assuming billing cycle will be first day of month
		previousToDate.add(Calendar.MONTH, -1); 
		int max = previousToDate.getActualMaximum(Calendar.DAY_OF_MONTH);
		previousToDate.set(Calendar.DAY_OF_MONTH, max);*/
		String assessmentYear = estimationService.getAssessmentYear();
		ArrayList<String> failedConnectionNos = new ArrayList<String>();

		Long startTimeForMdms= System.
				currentTimeMillis();
		Map<String, Object> masterMap = mDataService.loadMasterData(requestInfo,
				tenantId);

		log.info("connectionNos" + connectionNos.size());
		long startTimeForLoop= System.currentTimeMillis();
		for (String connectionNo : connectionNos) {
			long timeBeforePushToKafka = System.currentTimeMillis();
			CalculationCriteria calculationCriteria = CalculationCriteria.builder().tenantId(tenantId)
					.assessmentYear(assessmentYear).connectionNo(connectionNo).from(dayStartTime).to(dayEndTime).build();
			List<CalculationCriteria> calculationCriteriaList = new ArrayList<>();
			calculationCriteriaList.add(calculationCriteria);
			CalculationReq calculationReq = CalculationReq.builder().calculationCriteria(calculationCriteriaList)
					.requestInfo(requestInfo).isconnectionCalculation(true).isAdvanceCalculation(false).build();

			/*Set<String> consumerCodes = new LinkedHashSet<String>();
			consumerCodes.add(connectionNo);

			if (!waterCalculatorDao.isDemandExists(tenantId, previousFromDate.getTimeInMillis(),
					previousToDate.getTimeInMillis(), consumerCodes)
					&& !waterCalculatorDao.isConnectionExists(tenantId, previousFromDate.getTimeInMillis(),
							previousToDate.getTimeInMillis(), consumerCodes)) {
				log.warn("this connection doen't have the demand in previous billing cycle :" + connectionNo);
				failedConnectionNos.add(connectionNo);
				continue;
			}*/
			HashMap<Object, Object> genarateDemandData = new HashMap<Object, Object>();
			genarateDemandData.put("calculationReq", calculationReq);
			genarateDemandData.put("billingCycle",billingCycle);
			genarateDemandData.put("masterMap",masterMap);
			genarateDemandData.put("isSendMessage",isSendMessage);
			genarateDemandData.put("tenantId",tenantId);

			/*
			 * List<Demand> demands = demandService.searchDemand(tenantId, consumerCodes,
			 * previousFromDate.getTimeInMillis(), previousToDate.getTimeInMillis(),
			 * requestInfo); if (demands != null && demands.size() == 0) {
			 * log.warn("this connection doen't have the demand in previous billing cycle :"
			 * + connectionNo ); continue; }
			 */

			long timetakenToPush= System.currentTimeMillis();
			kafkaTemplate.send(config.getWsGenerateDemandBulktopic(),genarateDemandData);

		}
		log.info("Time taken for the for loop : "+(System.currentTimeMillis()-startTimeForLoop)/1000+ " Secondss");

		Long starttimeforNotification= System.currentTimeMillis();
		HashMap<String, String> demandMessage = util.getLocalizationMessage(requestInfo,
				WSCalculationConstant.mGram_Consumer_NewDemand, tenantId);
		HashMap<String, String> gpwscMap = util.getLocalizationMessage(requestInfo, tenantId, tenantId);
		UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo,
				Arrays.asList("COLLECTION_OPERATOR","REVENUE_COLLECTOR"), tenantId);
		Map<String, String> mobileNumberIdMap = new LinkedHashMap<>();
		String msgLink = config.getNotificationUrl() + config.getGpUserDemandLink();
		for (OwnerInfo userInfo : userDetailResponse.getUser()) {
			if (userInfo.getName() != null) {
				mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getName());
			} else {
				mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getUserName());
			}
		}
		mobileNumberIdMap.entrySet().stream().forEach(map -> {
			String msg = demandMessage.get(WSCalculationConstant.MSG_KEY);
			msg = msg.replace("{ownername}", map.getValue());
			msg = msg.replace("{villagename}",
					(gpwscMap != null && !StringUtils.isEmpty(gpwscMap.get(WSCalculationConstant.MSG_KEY)))
							? gpwscMap.get(WSCalculationConstant.MSG_KEY)
							: tenantId);
			msg = msg.replace("{billingcycle}", billingCycle);
			msg = msg.replace("{LINK}", msgLink);
			if(!map.getKey().equals(config.getPspclVendorNumber())) {
				SMSRequest smsRequest = SMSRequest.builder().mobileNumber(map.getKey()).message(msg)
						.tenantid(tenantId)
						.category(Category.TRANSACTION).build();
				if(config.isSmsForDemandEnable()) {
					producer.push(config.getSmsNotifTopic(), smsRequest);
				}
			}
			log.info("Time taken for notification : "+(System.currentTimeMillis()-starttimeforNotification)/1000+ " Secondss");
		});
	/*	if (isSendMessage && failedConnectionNos.size() > 0) {
			List<ActionItem> actionItems = new ArrayList<>();
			String actionLink = config.getBulkDemandFailedLink();
			ActionItem actionItem = ActionItem.builder().actionUrl(actionLink).build();
			actionItems.add(actionItem);
			Action actions = Action.builder().actionUrls(actionItems).build();
			System.out.println("Action Link::" + actionLink);

			List<Event> event = new ArrayList<>();
			HashMap<String, Object> additionals = new HashMap<String, Object>();

			HashMap<String, String> failedMessage = util.getLocalizationMessage(requestInfo,
					WSCalculationConstant.GENERATE_DEMAND_EVENT, tenantId);
			String messages = failedMessage.get(WSCalculationConstant.MSG_KEY);
			messages = messages.replace("{BILLING_CYCLE}", LocalDate.now().getMonth().toString());

			additionals.put("localizationCode", WSCalculationConstant.GENERATE_DEMAND_EVENT);
			HashMap<String, String> attributes = new HashMap<String, String>();
			attributes.put("{BILLING_CYCLE}", LocalDate.now().getMonth().toString());
			additionals.put("attributes", attributes);
			System.out.println("Demand Genaration Failed::" + failedMessage);
			event.add(Event.builder().tenantId(tenantId).description(messages)
					.eventType(WSCalculationConstant.USREVENTS_EVENT_TYPE)
					.name(WSCalculationConstant.MONTHLY_DEMAND_FAILED)
					.postedBy(WSCalculationConstant.USREVENTS_EVENT_POSTEDBY)
					.recepient(getRecepient(requestInfo, tenantId)).source(Source.WEBAPP).eventDetails(null)
					.actions(actions).additionalDetails(additionals).build());

			if (!CollectionUtils.isEmpty(event)) {
				EventRequest eventReq = EventRequest.builder().requestInfo(requestInfo).events(event).build();
				util.sendEventNotification(eventReq);
			}

		} else {
			System.out.println("Event Messages to the users");
			List<ActionItem> items = new ArrayList<>();
			String demandActionLink = config.getBulkDemandLink();
			ActionItem item = ActionItem.builder().actionUrl(demandActionLink).build();
			items.add(item);
			Action action = Action.builder().actionUrls(items).build();

			// Event notifications to the GP Users based on no of metered and non metered
			// connections
			List<Event> events = new ArrayList<>();

			HashMap<String, String> messageMap = new HashMap<String, String>();
			HashMap<String, Object> additionals = new HashMap<String, Object>();

			String message = null;
			if (connectionNos.size() > 0 && meteredConnectionNos.size() > 0) {
				messageMap = util.getLocalizationMessage(requestInfo, WSCalculationConstant.NEW_BULK_DEMAND_EVENT,
						tenantId);
				int size = connectionNos.size() + meteredConnectionNos.size();
				message = messageMap.get(WSCalculationConstant.MSG_KEY);
				message = message.replace("{billing cycle}", billingCycle);
				int nmSize = connectionNos.size() - failedConnectionNos.size();
				message = message.replace("{X}", String.valueOf(nmSize)); // this should be x- failed
																			// connections count
				message = message.replace("{X/X+Y}", String.valueOf(nmSize) + "/" + String.valueOf(size));
				message = message.replace("{Y}", String.valueOf(meteredConnectionNos.size()));
				additionals.put("localizationCode", WSCalculationConstant.NEW_BULK_DEMAND_EVENT);
				HashMap<String, String> attributes = new HashMap<String, String>();
				attributes.put("{billing cycle}", billingCycle);
				attributes.put("{X}", String.valueOf(nmSize));
				attributes.put("{X/X+Y}", String.valueOf(nmSize) + "/" + String.valueOf(size));
				attributes.put("{Y}", String.valueOf(meteredConnectionNos.size()));
				additionals.put("attributes", attributes);
			} else if (connectionNos.size() > 0 && meteredConnectionNos.isEmpty()) {
				messageMap = util.getLocalizationMessage(requestInfo, WSCalculationConstant.NEW_BULK_DEMAND_EVENT_NM,
						tenantId);
				int nmSize = connectionNos.size() - failedConnectionNos.size();
				message = messageMap.get(WSCalculationConstant.MSG_KEY);
				message = message.replace("{billing cycle}", billingCycle);
				message = message.replace("{X}", String.valueOf(nmSize));
				message = message.replace("{X/X}",
						String.valueOf(nmSize) + "/" + String.valueOf(connectionNos.size()));

				additionals.put("localizationCode", "NEW_BULK_DEMAND_EVENT_NM");
				HashMap<String, String> attributes = new HashMap<String, String>();
				attributes.put("{billing cycle}", billingCycle);
				attributes.put("{X}", String.valueOf(nmSize));
				attributes.put("{X/X}",
						String.valueOf(nmSize) + "/" + String.valueOf(connectionNos.size()));
				additionals.put("attributes", attributes);
			} else if (connectionNos.isEmpty() && meteredConnectionNos.size() > 0) {
				messageMap = util.getLocalizationMessage(requestInfo, WSCalculationConstant.NEW_BULK_DEMAND_EVENT_M,
						tenantId);
				message = messageMap.get(WSCalculationConstant.MSG_KEY);
				message = message.replace("{Y}", String.valueOf(meteredConnectionNos.size()));
				additionals.put("localizationCode", WSCalculationConstant.NEW_BULK_DEMAND_EVENT_M);
				HashMap<String, String> attributes = new HashMap<String, String>();
				attributes.put("{Y}", String.valueOf(meteredConnectionNos.size()));
				additionals.put("attributes", attributes);
			}

			System.out.println("Bulk Event msg1:: " + message);
			events.add(Event.builder().tenantId(tenantId).description(message)
					.eventType(WSCalculationConstant.USREVENTS_EVENT_TYPE)
					.name(WSCalculationConstant.MONTHLY_DEMAND_GENERATED)
					.postedBy(WSCalculationConstant.USREVENTS_EVENT_POSTEDBY)
					.recepient(getRecepient(requestInfo, tenantId)).source(Source.WEBAPP).eventDetails(null)
					.actions(action).additionalDetails(additionals).build());

			if (!CollectionUtils.isEmpty(events)) {
				EventRequest eventReq = EventRequest.builder().requestInfo(requestInfo).events(events).build();
				util.sendEventNotification(eventReq);
			}

			// GP User message

			HashMap<String, String> demandMessage = util.getLocalizationMessage(requestInfo,
					WSCalculationConstant.mGram_Consumer_NewDemand, tenantId);

			HashMap<String, String> gpwscMap = util.getLocalizationMessage(requestInfo, tenantId, tenantId);
			UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo,
					Arrays.asList("COLLECTION_OPERATOR","REVENUE_COLLECTOR"), tenantId);
			Map<String, String> mobileNumberIdMap = new LinkedHashMap<>();

			String msgLink = config.getNotificationUrl() + config.getGpUserDemandLink();

			for (OwnerInfo userInfo : userDetailResponse.getUser()) {
				if (userInfo.getName() != null) {
					mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getName());
				} else {
					mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getUserName());
				}
			}
			mobileNumberIdMap.entrySet().stream().forEach(map -> {
				String msg = demandMessage.get(WSCalculationConstant.MSG_KEY);
				msg = msg.replace("{ownername}", map.getValue());
				msg = msg.replace("{villagename}",
						(gpwscMap != null && !StringUtils.isEmpty(gpwscMap.get(WSCalculationConstant.MSG_KEY)))
								? gpwscMap.get(WSCalculationConstant.MSG_KEY)
								: tenantId);
				msg = msg.replace("{billingcycle}", billingCycle);
				msg = msg.replace("{LINK}", msgLink);

				System.out.println("Demand GP USER SMS1::" + msg);
				if(!map.getKey().equals(config.getPspclVendorNumber())) {
					SMSRequest smsRequest = SMSRequest.builder().mobileNumber(map.getKey()).message(msg)
							.tenantid(tenantId)
							.category(Category.TRANSACTION).build();
					if(config.isSmsForDemandEnable()) {
						producer.push(config.getSmsNotifTopic(), smsRequest);
					}
				}

			});
		}*/
	}

	public void generateDemandInBulk(CalculationReq calculationReq, String billingCycle, Map<String, Object> masterMap,
									 boolean isSendMessage,String tenantId) {
		try {
			if(!tenantId.equals(config.getSmsExcludeTenant())) {
				generateDemandInBatch(calculationReq, masterMap, billingCycle, isSendMessage);
			}

		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Got the exception while genating the demands:" + e);
			log.info("Errro in Apllication no :"+calculationReq.getCalculationCriteria().get(0).getConnectionNo());

		}

	}

	/**
	 * 
	 * @param billingFrequency Billing Frequency details
	 * @param dayOfMonth       Day of the given month
	 * @return true if current day is for generation of demand
	 */
	private boolean isCurrentDateIsMatching(String billingFrequency, long dayOfMonth) {
		if (billingFrequency.equalsIgnoreCase(WSCalculationConstant.Monthly_Billing_Period)
				&& (dayOfMonth == LocalDateTime.now().getDayOfMonth())) {
			return true;
		} else if (billingFrequency.equalsIgnoreCase(WSCalculationConstant.Quaterly_Billing_Period)) {
			return false;
		}
		return true;
	}

	private Recipient getRecepient(RequestInfo requestInfo, String tenantId) {
		Recipient recepient = null;
		UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo, Arrays.asList("GP_ADMIN","SARPANCH"),
				tenantId);
		if (userDetailResponse.getUser().isEmpty())
			log.error("Recepient is absent");
		else {
			List<String> toUsers = userDetailResponse.getUser().stream().map(OwnerInfo::getUuid)
					.collect(Collectors.toList());

			recepient = Recipient.builder().toUsers(toUsers).toRoles(null).build();
		}
		return recepient;
	}

	@SuppressWarnings("unchecked")
	@KafkaListener(topics = {
			"${egov.generate.bulk.demand.manually.topic}" }, containerFactory = "kafkaListenerContainerFactory")
	public void generateBulkDemandForULB(HashMap<Object, Object> messageData) {
		log.info("Billing master data values for non metered connection:: {}", messageData);
		Map<String, Object> billingMasterData;
		BulkDemand bulkDemand;
		boolean isSendMessage = false;
		boolean isManual = true;
		HashMap<Object, Object> demandData = (HashMap<Object, Object>) messageData;
		billingMasterData = (Map<String, Object>) demandData.get("billingMasterData");
		bulkDemand = mapper.convertValue(demandData.get("bulkDemand"), BulkDemand.class);

		String billingPeriod = bulkDemand.getBillingPeriod();
		if (StringUtils.isEmpty(billingPeriod))
			throw new CustomException("BILLING_PERIOD_PARSING_ISSUE", "Billing Period can not be empty!!");
		log.info("CALL FROM TOPIC egov.generate.bulk.demand.manually.topic for tenantid:"
				+bulkDemand.getTenantId()+" BillPeriod:"+billingPeriod+" Start Time:"+System.currentTimeMillis() );
		Long starTime = System.currentTimeMillis();
		log.info("CALL FROM TOPIC egov.generate.bulk.demand.manually.topic" );
		generateDemandAndSendnotification(bulkDemand.getRequestInfo(), bulkDemand.getTenantId(), billingPeriod, billingMasterData,
				isSendMessage, isManual);
		long endTime=System.currentTimeMillis();
		long diff = endTime-starTime;
		log.info("time takenn to generate demand for Tenantid:"+bulkDemand.getTenantId()+" BillPeriod:"+billingPeriod+" is : "+diff/1000 +" seconds");
	}
	@KafkaListener(topics = {
			"${egov.update.demand.add.penalty}" })
	public void updateAddPenalty(HashMap<Object, Object> messageData) {
		DemandRequest demandRequest = mapper.convertValue(messageData, DemandRequest.class);
		demandService.updateDemandAddPenalty(demandRequest.getRequestInfo(), demandRequest.getDemands());
	}

	@KafkaListener(topics = {
			"${ws.generate.demand.bulk}" })
	public void generateDemandInBulkListner(HashMap<Object, Object> messageData) {
		CalculationReq calculationReq= new CalculationReq();
		Map<String, Object> masterMap = new HashMap<>();
		String billingCycle ;
		boolean isSendMessage = true;
		String tenantId="";
		HashMap<Object, Object> genarateDemandData = (HashMap<Object, Object>) messageData;
		masterMap = (Map<String, Object>) genarateDemandData.get("masterMap");
		calculationReq = mapper.convertValue(genarateDemandData.get("calculationReq"), CalculationReq.class);
		billingCycle= (String) genarateDemandData.get("billingCycle");
		isSendMessage= (boolean) genarateDemandData.get("isSendMessage");
		tenantId=(String) genarateDemandData.get("tenantId");
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");


		LocalDate fromDate = LocalDate.parse(billingCycle.split("-")[0].trim(), formatter);
		LocalDate toDate = LocalDate.parse(billingCycle.split("-")[1].trim(), formatter);

		Long dayStartTime = LocalDateTime
				.of(fromDate.getYear(), fromDate.getMonth(), fromDate.getDayOfMonth(), 0, 0, 0)
				.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		Long dayEndTime = LocalDateTime
				.of(toDate.getYear(), toDate.getMonth(), toDate.getDayOfMonth(), 23, 59, 59, 999000000)
				.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		Calendar previousFromDate = Calendar.getInstance();
		Calendar previousToDate = Calendar.getInstance();

		previousFromDate.setTimeInMillis(dayStartTime);
		previousToDate.setTimeInMillis(dayEndTime);

		previousFromDate.add(Calendar.MONTH, -1); //assuming billing cycle will be first day of month
		previousToDate.add(Calendar.MONTH, -1);
		int max = previousToDate.getActualMaximum(Calendar.DAY_OF_MONTH);
		previousToDate.set(Calendar.DAY_OF_MONTH, max);
		//log.info("got generate demand call for :"+calculationReq.getCalculationCriteria().get(0).getConnectionNo());
		Set<String> consumerCodes = new LinkedHashSet<String>();
		consumerCodes.add(calculationReq.getCalculationCriteria().get(0).getConnectionNo());
		if (!waterCalculatorDao.isDemandExists(tenantId, previousFromDate.getTimeInMillis(),
				previousToDate.getTimeInMillis(), consumerCodes)
				&& !waterCalculatorDao.isConnectionExists(tenantId, previousFromDate.getTimeInMillis(),
				previousToDate.getTimeInMillis(), consumerCodes)) {
			log.warn("this connection doen't have the demand in previous billing cycle :" + calculationReq.getCalculationCriteria().get(0).getConnectionNo());
		} else {
			Long starttime = System.currentTimeMillis();
			generateDemandInBulk(calculationReq, billingCycle, masterMap, isSendMessage, tenantId);
			log.info("GOt call inn ws-gennerate-demand-bulk topic end time:" + System.currentTimeMillis());
			Long endtime = System.currentTimeMillis();
			long diff = endtime - starttime;
			log.info("Time taken to process request for :" + calculationReq.getCalculationCriteria().get(0).getConnectionNo() + " is :" + diff / 1000 + " secs");
		}
	}

}