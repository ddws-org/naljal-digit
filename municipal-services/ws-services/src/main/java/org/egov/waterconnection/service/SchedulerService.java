package org.egov.waterconnection.service;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Month;
import java.time.YearMonth;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.apache.commons.lang3.StringUtils;
import org.egov.common.contract.request.RequestInfo;
import org.egov.mdms.model.MasterDetail;
import org.egov.mdms.model.MdmsCriteria;
import org.egov.mdms.model.MdmsCriteriaReq;
import org.egov.mdms.model.ModuleDetail;
import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.config.WSConfiguration;
import org.egov.waterconnection.constants.WCConstants;
import org.egov.waterconnection.producer.WaterConnectionProducer;
import org.egov.waterconnection.repository.ServiceRequestRepository;
import org.egov.waterconnection.repository.WaterRepository;
import org.egov.waterconnection.util.NotificationUtil;
import org.egov.waterconnection.util.WaterServicesUtil;
import org.egov.waterconnection.web.models.Action;
import org.egov.waterconnection.web.models.ActionItem;
import org.egov.waterconnection.web.models.Event;
import org.egov.waterconnection.web.models.EventRequest;
import org.egov.waterconnection.web.models.OwnerInfo;
import org.egov.waterconnection.web.models.Recepient;
import org.egov.waterconnection.web.models.SMSRequest;
import org.egov.waterconnection.web.models.Source;
import org.egov.waterconnection.web.models.users.UserDetailResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import com.jayway.jsonpath.JsonPath;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class SchedulerService {

	@Autowired
	private WaterRepository repository;

	@Autowired
	private WSConfiguration config;

	@Autowired
	private EditNotificationService notificationService;

	@Autowired
	private NotificationUtil util;

	@Autowired
	private UserService userService;

	@Autowired
	private WaterConnectionProducer producer;

	@Autowired
	private RestTemplate restTemplate;

	@Autowired
	private WaterServicesUtil utils;

	@Autowired
	private ServiceRequestRepository serviceRequestRepository;

	public static final String USREVENTS_EVENT_TYPE = "SYSTEMGENERATED";
	
	public static final String MONTHLY_DEMAND_FAILED = "MONTHLY_DEMAND_FAILED";
	public static final String PENDING_COLLECTION_USEREVENT = "PENDING_COLLECTION_USEREVENT";
	public static final String TODAY_COLLECTION = "TODAY_COLLECTION";
	
	public static final String USREVENTS_EVENT_POSTEDBY = "SYSTEM-CHALLAN";

	private static final String PENDING_COLLECTION_EVENT = "PENDING_COLLECTION_EN_REMINDER";
	private static final String MONTHLY_SUMMARY_EVENT = "MONTHLY_SUMMARY_EN_REMINDER";
	private static final String GENERATE_DEMAND_EVENT = "GENERATE_DEMAND_EN_REMINDER";
	private static final String MONTHLY_SUMMARY_SMS = "mGram.GPUser.PreviousMonthSummary";
	private static final String PENDING_COLLECTION_SMS = "mGram.GPUser.CollectionReminder";

	private static final String TODAY_CASH_COLLECTION = "TODAY_COLLECTION_AS_CASH_SMS";
	private static final String TODAY_ONLINE_COLLECTION = "TODAY_COLLECTION_FROM_ONLINE_SMS";
	private static final String TODAY_CASH_COLLECTION_SMS = "TODAY_COLLECTION_FROM_CASH";
	private static final String TODAY_ONLINE_COLLECTION_SMS = "TODAY_COLLECTION_FROM_ONLINE";

	/**
	 * Send the pending collection notification every fortnight
	 * 
	 * @param requestInfo
	 */
	public void sendPendingCollectionEvent(RequestInfo requestInfo) {
		LocalDate dayofmonth = LocalDate.now().with(TemporalAdjusters.firstDayOfMonth());
		LocalDateTime scheduleTimeFirst = LocalDateTime.of(dayofmonth.getYear(), dayofmonth.getMonth(),
				dayofmonth.getDayOfMonth(), 10, 0, 0);
		LocalDateTime scheduleTimeSecond = LocalDateTime.of(dayofmonth.getYear(), dayofmonth.getMonth(), 15, 10, 0, 0);
		DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
		LocalDateTime currentTime = LocalDateTime.parse(LocalDateTime.now().format(dateTimeFormatter),
				dateTimeFormatter);

		List<String> tenantIds = repository.getTenantId();
		tenantIds.forEach(tenantId -> {
			if (tenantId.split("\\.").length >= 2) {
				if (null != config.getIsUserEventsNotificationEnabled()) {
					if (config.getIsUserEventsNotificationEnabled()) {
						EventRequest eventRequest = sendPendingCollectionNotification(requestInfo, tenantId);
						if (null != eventRequest)
							notificationService.sendEventNotification(eventRequest);
					}
				}

				if (null != config.getIsSMSEnabled()) {
					if (config.getIsSMSEnabled()) {
						HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo,
								PENDING_COLLECTION_SMS, tenantId);
						HashMap<String, String> gpwscMap = util.getLocalizationMessage(requestInfo, tenantId, tenantId);

						UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo, tenantId,
								Arrays.asList("GP_ADMIN","SARPANCH"));

						String penColLink = config.getUiPath() + config.getMonthRevenueDashboardLink();
						Map<String, String> mobileNumberIdMap = new LinkedHashMap<>();

						for (OwnerInfo userInfo : userDetailResponse.getUser())
							if (userInfo.getName() != null) {
								mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getName());
							} else {
								mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getUserName());
							}
						mobileNumberIdMap.entrySet().stream().forEach(map -> {
							if (messageMap != null && !StringUtils.isEmpty(messageMap.get(NotificationUtil.MSG_KEY))) {

								String uuidUsername = map.getValue();
								String message = formatPendingCollectionMessage(requestInfo, tenantId,
										messageMap.get(NotificationUtil.MSG_KEY), new HashMap<>());
								message = message.replace("{PENDING_COL_LINK}", getShortenedUrl(penColLink));
								message = message.replace("{GPWSC}",
										(gpwscMap != null
												&& !StringUtils.isEmpty(gpwscMap.get(NotificationUtil.MSG_KEY)))
														? gpwscMap.get(NotificationUtil.MSG_KEY)
														: tenantId);
								message = message.replace("{ownername}", uuidUsername);
								DateFormat format = new SimpleDateFormat("dd/MM/yyyy");
								Date today = new Date();
								String formattedDate = format.format(today);
								message = message.replace("{Date}", formattedDate);

								message = message.replace("{Date}", LocalDate.now().toString());
								System.out.println("PENDING Coll SMS::" + message);
								SMSRequest smsRequest = SMSRequest.builder().mobileNumber(map.getKey()).message(message)
										.templateId(messageMap.get(NotificationUtil.TEMPLATE_KEY)).tenantId(tenantId)
										.users(new String[] { uuidUsername }).build();
								if(config.isSMSForPendingCollectionEnabled()) {
									producer.push(config.getSmsNotifTopic(), smsRequest);
								}

							}
						});
					}
				}
			}
		});
	}

	private CharSequence getShortenedUrl(String url) {
		String res = null;
		HashMap<String, String> body = new HashMap<>();
		body.put("url", url);
		StringBuilder builder = new StringBuilder(config.getUrlShortnerHost());
		builder.append(config.getUrlShortnerEndpoint());
		try {
			res = restTemplate.postForObject(builder.toString(), body, String.class);

		} catch (Exception e) {
			log.error("Error while shortening the url: " + url, e);

		}
		if (StringUtils.isEmpty(res)) {
			log.error("URL_SHORTENING_ERROR", "Unable to shorten url: " + url);
			;
			return url;
		} else
			return res;
	}

	public String formatPendingCollectionMessage(RequestInfo requestInfo, String tenantId, String message, Map<String, Object> additionalDetailsMap) {
		
		Map<String, String> attributes = new HashMap<String, String>();
		
		Map<String, Object> financialYear = getFinancialYear(requestInfo, tenantId);
		List<String> pendingCollection = repository.getPendingCollection(tenantId,
				financialYear.get("startingDate").toString(), financialYear.get("endingDate").toString());
		if (null != pendingCollection && pendingCollection.size() > 0)
			if (message.contains("{PENDING_COLLECTION}")) {
				if (pendingCollection.get(0) != null) {
					message = message.replace(" {PENDING_COLLECTION} ", pendingCollection.get(0));
					attributes.put("{PENDING_COLLECTION}", pendingCollection.get(0));
				}
				else {
					message = message.replace(" {PENDING_COLLECTION} ", "0");
					attributes.put("{PENDING_COLLECTION}", "0");
				}
				System.out.println("Final EVENT MEssage is :" + message);
			} else if (message.contains("{amount}")) {
				if (pendingCollection.get(0) != null) {
					message = message.replace("{amount}", pendingCollection.get(0));
					attributes.put("{amount}", pendingCollection.get(0));
				}
				else {
					message = message.replace("{amount}", "0");
					attributes.put("{amount}", "0");
				}
				System.out.println("Final SMS MEssage is :" + message);
			}
		if (message.contains("{TODAY_DATE}")) {
			DateFormat format = new SimpleDateFormat("dd/MM/yyyy");
			Date today = new Date();
			String formattedDate = format.format(today);
			message = message.replace("{TODAY_DATE}", formattedDate);
			attributes.put("{TODAY_DATE}", formattedDate);
		}
		System.out.println("Final message is :" + message);
		
		additionalDetailsMap.put("attributes", attributes);

		
		return message;
	}

	public Map<String, Object> getFinancialYear(RequestInfo requestInfo, String tenantId) {
		Set<String> financeYears = new HashSet<>(1);
		String financeYear = prepareFinanceYear();
		MdmsCriteriaReq mdmsCriteriaReq = getFinancialYearRequest(requestInfo, financeYear, tenantId);
		StringBuilder url = utils.getMdmsSearchUrl();
		Object res = serviceRequestRepository.fetchResult(url, mdmsCriteriaReq);
		Map<String, Object> financialYearProperties;
		String jsonPath = WCConstants.MDMS_EGFFINACIALYEAR_PATH.replace("{}", financeYear);
		try {
			List<Map<String, Object>> jsonOutput = JsonPath.read(res, jsonPath);
			financialYearProperties = jsonOutput.get(0);

		} catch (IndexOutOfBoundsException e) {
			throw new CustomException("EXP_FIN_NOT_FOUND", "Financial year not found: " + financeYears);
		}

		return financialYearProperties;
	}

	public String prepareFinanceYear() {
		LocalDateTime localDateTime = LocalDateTime.now();
		int currentMonth = localDateTime.getMonthValue();
		String financialYear;
		if (currentMonth >= Month.APRIL.getValue()) {
			financialYear = YearMonth.now().getYear() + "-";
			financialYear = financialYear
					+ (Integer.toString(YearMonth.now().getYear() + 1).substring(2, financialYear.length() - 1));
		} else {
			financialYear = YearMonth.now().getYear() - 1 + "-";
			financialYear = financialYear
					+ (Integer.toString(YearMonth.now().getYear()).substring(2, financialYear.length() - 1));

		}
		return financialYear;
	}

	public MdmsCriteriaReq getFinancialYearRequest(RequestInfo requestInfo, String financeYearsStr, String tenantId) {
		MasterDetail masterDetail = MasterDetail.builder().name("FinancialYear")
				.filter("[?(@." + "finYearRange" + " IN [" + financeYearsStr + "]" + " && @.module== '" + "WS" + "')]")
				.build();
		ModuleDetail moduleDetail = ModuleDetail.builder().moduleName("egf-master")
				.masterDetails(Arrays.asList(masterDetail)).build();
		MdmsCriteria mdmsCriteria = MdmsCriteria.builder().moduleDetails(Arrays.asList(moduleDetail)).tenantId(tenantId)
				.build();
		return MdmsCriteriaReq.builder().requestInfo(requestInfo).mdmsCriteria(mdmsCriteria).build();
	}

	public EventRequest sendPendingCollectionNotification(RequestInfo requestInfo, String tenantId) {
		List<ActionItem> items = new ArrayList<>();
		String actionLink = config.getPendingCollectionLink();
		ActionItem item = ActionItem.builder().actionUrl(actionLink).build();
		items.add(item);
		Action action = Action.builder().actionUrls(items).build();
		List<Event> events = new ArrayList<>();
		System.out.println("Action Link::" + actionLink);
		
		Map<String, Object> additionalDetailsMap = new HashMap<String, Object>();
		additionalDetailsMap.put("localizationCode", PENDING_COLLECTION_EVENT);
		
		HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo, PENDING_COLLECTION_EVENT,
				tenantId);
		Map<String, Object> financialYear = getFinancialYear(requestInfo, tenantId);
		List<String> pendingCollection = repository.getPendingCollection(tenantId,
				financialYear.get("startingDate").toString(), financialYear.get("endingDate").toString());
		if(null != pendingCollection && pendingCollection.size() > 0 && pendingCollection.get(0) !=null && Double.parseDouble(pendingCollection.get(0)) > 0 ) {
			events.add(Event.builder().tenantId(tenantId)
					.description(
							formatPendingCollectionMessage(requestInfo, tenantId, messageMap.get(NotificationUtil.MSG_KEY), additionalDetailsMap))
					.eventType(USREVENTS_EVENT_TYPE).name(PENDING_COLLECTION_USEREVENT).postedBy(USREVENTS_EVENT_POSTEDBY)
					.recepient(getRecepient(requestInfo, tenantId)).source(Source.WEBAPP)
					.recepient(getRecepient(requestInfo, tenantId)).eventDetails(null).actions(action).additionalDetails(additionalDetailsMap).build());
		}
			if (!CollectionUtils.isEmpty(events)) {
				return EventRequest.builder().requestInfo(requestInfo).events(events).build();
			} else {
				return null;
		}

	}

	private Recepient getRecepient(RequestInfo requestInfo, String tenantId) {
		Recepient recepient = null;
		UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo, tenantId,
				Arrays.asList("GP_ADMIN","SARPANCH"));
		if (userDetailResponse.getUser().isEmpty())
			log.error("Recepient is absent");
		else {
			List<String> toUsers = userDetailResponse.getUser().stream().map(OwnerInfo::getUuid)
					.collect(Collectors.toList());

			recepient = Recepient.builder().toUsers(toUsers).toRoles(null).build();
		}
		return recepient;
	}

	public void sendGenerateDemandEvent(RequestInfo requestInfo) {
		LocalDate dayofmonth = LocalDate.now().with(TemporalAdjusters.firstDayOfMonth());
		LocalDateTime scheduleTime = LocalDateTime.of(dayofmonth.getYear(), dayofmonth.getMonth(),
				dayofmonth.getDayOfMonth(), 10, 0, 0);
		DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
		LocalDateTime currentTime = LocalDateTime.parse(LocalDateTime.now().format(dateTimeFormatter),
				dateTimeFormatter);

		List<String> tenantIds = repository.getTenantId();
		tenantIds.forEach(tenantId -> {
			if (tenantId.split("\\.").length >= 2) {
				if (null != config.getIsUserEventsNotificationEnabled()) {
					if (config.getIsUserEventsNotificationEnabled()) {
						EventRequest eventRequest = sendGenerateDemandNotification(requestInfo, tenantId);
						if (null != eventRequest)
							notificationService.sendEventNotification(eventRequest);
					}
				}
			}
		});
	}

	public EventRequest sendGenerateDemandNotification(RequestInfo requestInfo, String tenantId) {

		List<ActionItem> items = new ArrayList<>();
		String actionLink = config.getBulkDemandFailedLink();
		ActionItem item = ActionItem.builder().actionUrl(actionLink).build();
		items.add(item);
		Action action = Action.builder().actionUrls(items).build();
		System.out.println("Action Link::" + actionLink);

		List<Event> events = new ArrayList<>();
		
		Map<String, Object> additionalDetailsMap = new HashMap<String, Object>();
		Map<String, String> attributes = new HashMap<>();
		additionalDetailsMap.put("localizationCode", GENERATE_DEMAND_EVENT);
		
		HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo, GENERATE_DEMAND_EVENT, tenantId);
		String message = messageMap.get(NotificationUtil.MSG_KEY);
		message = message.replace("{BILLING_CYCLE}", LocalDate.now().getMonth().toString());
		attributes.put("{BILLING_CYCLE}", LocalDate.now().getMonth().toString());
		additionalDetailsMap.put("attributes", attributes);
		
		System.out.println("Demand Genaration Failed::" + messageMap);
		events.add(Event.builder().tenantId(tenantId).description(message).eventType(USREVENTS_EVENT_TYPE)
				.name(MONTHLY_DEMAND_FAILED).postedBy(USREVENTS_EVENT_POSTEDBY)
				.recepient(getRecepient(requestInfo, tenantId)).source(Source.WEBAPP).eventDetails(null).actions(action)
				.additionalDetails(additionalDetailsMap)
				.build());

		if (!CollectionUtils.isEmpty(events)) {
			return EventRequest.builder().requestInfo(requestInfo).events(events).build();
		} else {
			return null;
		}

	}

	public void sendTodaysCollection(RequestInfo requestInfo) {

		LocalDate date = LocalDate.now();
		LocalDateTime scheduleTime = LocalDateTime.of(date.getYear(), date.getMonth(), date.getDayOfMonth(), 11, 59,
				59);

		DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
		LocalDateTime currentTime = LocalDateTime.parse(LocalDateTime.now().format(dateTimeFormatter),
				dateTimeFormatter);
		List<String> tenantIds = repository.getTenantId();

		tenantIds.forEach(tenantId -> {
			if (tenantId.split("\\.").length >= 2) {
				if (null != config.getIsUserEventsNotificationEnabled()) {
					if (config.getIsUserEventsNotificationEnabled()) {
						EventRequest eventRequest = sendDayCollectionNotification(requestInfo, tenantId);
						if (null != eventRequest)
							notificationService.sendEventNotification(eventRequest);
					}
				}

				if (null != config.getIsSMSEnabled()) {
					if (config.getIsSMSEnabled()) {
						List<String> messages = new ArrayList<String>();
						HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo,
								TODAY_CASH_COLLECTION_SMS, tenantId);
						HashMap<String, String> gpwscMap = util.getLocalizationMessage(requestInfo, tenantId, tenantId);

						String mode = "cash";
						String message = formatTodayCollectionMessage(requestInfo, tenantId,
								messageMap.get(NotificationUtil.MSG_KEY), mode, new HashMap<>());
						HashMap<String, String> onlineMessageMap = util.getLocalizationMessage(requestInfo,
								TODAY_ONLINE_COLLECTION_SMS, tenantId);
						if (message != null) {

							messages.add(message);
							mode = "online";
//							String onlineMessage = formatTodayCollectionMessage(requestInfo, tenantId,
//									onlineMessageMap.get(NotificationUtil.MSG_KEY), mode);
//							messages.add(onlineMessage);
							UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo,
									tenantId, Arrays.asList("COLLECTION_OPERATOR","REVENUE_COLLECTOR"));
							Map<String, String> mobileNumberIdMap = new LinkedHashMap<>();

							for (OwnerInfo userInfo : userDetailResponse.getUser()) {
								System.out.println("TODAY Coll User Info::" + userInfo);
								if (userInfo.getName() != null) {
									mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getName());
								} else {
									mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getUserName());
								}
							}
							mobileNumberIdMap.entrySet().stream().forEach(map -> {
								if (!messages.isEmpty()) {
									String uuidUsername = map.getValue();

									messages.forEach(msg -> {
										msg = msg.replace("{ownername}", uuidUsername);
										msg = msg.replace("{GPWSC}",
												(gpwscMap != null
														&& !StringUtils.isEmpty(gpwscMap.get(NotificationUtil.MSG_KEY)))
																? gpwscMap.get(NotificationUtil.MSG_KEY)
																: tenantId);
										DateFormat format = new SimpleDateFormat("dd/MM/yyyy");
										Date today = new Date();
										String formattedDate = format.format(today);
										msg = msg.replace("{date}", formattedDate);
										System.out.println("TODAY Coll SMS::" + msg);
										SMSRequest smsRequest = SMSRequest.builder().mobileNumber(map.getKey())
												.message(msg).templateId(messageMap.get(NotificationUtil.TEMPLATE_KEY)).tenantId(tenantId)
												.users(new String[] { uuidUsername }).build();
										if(config.isSMSForTodaysCollectionEnabled()) {
											producer.push(config.getSmsNotifTopic(), smsRequest);
										}
									});
								}
							});
						}

					}
				}
			}
			return;
		});
	}

	@SuppressWarnings("null")
	private EventRequest sendDayCollectionNotification(RequestInfo requestInfo, String tenantId) {
		// TODO Auto-generated method stub

		List<ActionItem> items = new ArrayList<>();
		String actionLink = config.getTodayCollectionLink();
		ActionItem item = ActionItem.builder().actionUrl(actionLink).build();
		items.add(item);
		Action action = Action.builder().actionUrls(items).build();
		System.out.println("Action Link::" + actionLink);
		
		Map<String, Object> additionalDetailsMap = new HashMap<String, Object>();
		additionalDetailsMap.put("localizationCode", TODAY_CASH_COLLECTION);
		
		List<Event> events = new ArrayList<>();
		List<String> messages = new ArrayList<String>();
		HashMap<String, String> cashMessageMap = util.getLocalizationMessage(requestInfo, TODAY_CASH_COLLECTION,
				tenantId);
		String mode = "cash";
		String message = formatTodayCollectionMessage(requestInfo, tenantId,
				cashMessageMap.get(NotificationUtil.MSG_KEY), mode, additionalDetailsMap);
		HashMap<String, String> onlineMessageMap = util.getLocalizationMessage(requestInfo, TODAY_ONLINE_COLLECTION,
				tenantId);
		if(message!=null) {
			messages.add(message);
			for (String msg : messages) {
				events.add(Event.builder().tenantId(tenantId).description(msg).eventType(USREVENTS_EVENT_TYPE)
						.name(TODAY_COLLECTION).postedBy(USREVENTS_EVENT_POSTEDBY)
						.recepient(getRecepient(requestInfo, tenantId)).source(Source.WEBAPP).eventDetails(null)
						.additionalDetails(additionalDetailsMap).actions(action).build());
			}
		}
//		mode = "online";
//		String onlineMessage = formatTodayCollectionMessage(requestInfo, tenantId,
//				onlineMessageMap.get(NotificationUtil.MSG_KEY), mode);
//		messages.add(onlineMessage);

		if (!CollectionUtils.isEmpty(events)) {
			return EventRequest.builder().requestInfo(requestInfo).events(events).build();
		} else {
			return null;
		}

	}

	private String formatTodayCollectionMessage(RequestInfo requestInfo, String tenantId, String message, String mode, Map<String,Object> additionalDetailsMap) {
		// TODO Auto-generated method stub
		Map<String, String> attributes = new HashMap<>();
		LocalDate today = LocalDate.now();
		LocalDateTime todayStartDateTime = LocalDateTime.of(today.getYear(), today.getMonth(), today.getDayOfMonth(), 0,
				0, 0);
		LocalDateTime todayEndDateTime = LocalDateTime.of(today.getYear(), today.getMonth(), today.getDayOfMonth(), 23,
				59, 59);
		List<Map<String, Object>> todayCollection = repository.getTodayCollection(tenantId,
				((Long) todayStartDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()).toString(),
				((Long) todayEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()).toString(), mode);

		if (null != todayCollection && todayCollection.size() > 0) {
			for (Map<String, Object> map : todayCollection) {
				for (Map.Entry<String, Object> entry : map.entrySet()) {
					String key = entry.getKey();
					Object value = entry.getValue();
					if (key.equalsIgnoreCase("sum")) {
						if (value != null) {
							message = message.replace("{amount}", value.toString());
							attributes.put("{amount}", value.toString());
						}
						else {
							message = null;
							return message;
						}
					}
					if (key.equalsIgnoreCase("count")) {
						if (message.contains("{no}")) {
							if (value != null) {
								message = message.replace("{no}", value.toString());
								attributes.put("{no}", value.toString());
							}
							else {
								message = message.replace("{no}", "0");
								attributes.put("{no}", "0");
							}
						} else if (message.contains("{number}")) {
							if (value != null) {
								message = message.replace("{number}", value.toString());
								attributes.put("{number}", value.toString());
							}else {
								message = message.replace("{number}", "0");
								attributes.put("{number}", "0");
							}
								
						}
					}
				}
				System.out.println("Final message is :" + message);
			}
			additionalDetailsMap.put("attributes", attributes);
		}
		return message;
	}

}
