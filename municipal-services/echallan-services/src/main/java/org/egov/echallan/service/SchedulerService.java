package org.egov.echallan.service;

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
import org.egov.echallan.config.ChallanConfiguration;
import org.egov.echallan.model.SMSRequest;
import org.egov.echallan.model.UserInfo;
import org.egov.echallan.producer.Producer;
import org.egov.echallan.repository.ChallanRepository;
import org.egov.echallan.repository.ServiceRequestRepository;
import org.egov.echallan.util.ChallanConstants;
import org.egov.echallan.util.CommonUtils;
import org.egov.echallan.util.NotificationUtil;
import org.egov.echallan.web.models.user.UserDetailResponse;
import org.egov.echallan.web.models.uservevents.Action;
import org.egov.echallan.web.models.uservevents.ActionItem;
import org.egov.echallan.web.models.uservevents.Event;
import org.egov.echallan.web.models.uservevents.EventRequest;
import org.egov.echallan.web.models.uservevents.Recepient;
import org.egov.echallan.web.models.uservevents.Source;
import org.egov.mdms.model.MasterDetail;
import org.egov.mdms.model.MdmsCriteria;
import org.egov.mdms.model.MdmsCriteriaReq;
import org.egov.mdms.model.ModuleDetail;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import com.jayway.jsonpath.JsonPath;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class SchedulerService {

	private ChallanRepository repository;

	private CommonUtils utils;

	private ServiceRequestRepository serviceRequestRepository;

	@Autowired
	private NotificationUtil util;

	@Autowired
	private ChallanConfiguration config;

	@Autowired
	private NotificationService notificationService;
	@Autowired
	private UserService userService;

	@Autowired
	private Producer producer;

	@Autowired
	private RestTemplate restTemplate;

	public static final String USREVENTS_EVENT_TYPE = "SYSTEMGENERATED";
	public static final String USREVENTS_EVENT_NAME = "Challan";
	public static final String USREVENTS_EVENT_POSTEDBY = "SYSTEM-CHALLAN";

	private static final String PENDING_COLLECTION_EVENT = "PENDING_COLLECTION_EN_REMINDER";
	private static final String MONTHLY_SUMMARY_EVENT = "MONTHLY_SUMMARY_EN_REMINDER";
	private static final String NEW_EXPENDITURE_EVENT = "NEW_ENPENDITURE_EN_REMINDER";
	private static final String MARK_PAID_BILL_EVENT = "MARK_PAID_BILL_EN_REMINDER";
	private static final String GENERATE_DEMAND_EVENT = "GENERATE_DEMAND_EN_REMINDER";
	private static final String NEW_EXPENDITURE_SMS = "mGram.GPUser.EnterExpense";
	private static final String MONTHLY_SUMMARY_SMS = "mGram.GPUser.PreviousMonthSummary";
	private static final String MARK_PAID_BILL_SMS = "mGram.GPUser.MarkExpense";
	private static final String PENDING_COLLECTION_SMS = "mGram.GPUser.CollectionReminder";

	private static final String TODAY_CASH_COLLECTION = "TODAY_COLLECTION_AS_CASH_SMS";
	private static final String TODAY_ONLINE_COLLECTION = "TODAY_COLLECTION_FROM_ONLINE_SMS";
	private static final String TODAY_CASH_COLLECTION_SMS = "TODAY_COLLECTION_FROM_CASH";
	private static final String TODAY_ONLINE_COLLECTION_SMS = "TODAY_COLLECTION_FROM_ONLINE";



	private static final String EXPENSE_PAYMENT = "EXPENSE_PAYMENT";

	private static final String MONTHLY_SUMMARY = "MONTHLY_SUMMARY";

	private static final String NEW_EXPENSE_ENTRY = "NEW_EXPENSE_ENTRY";
	
	
	@Autowired
	public SchedulerService(ChallanRepository repository, CommonUtils utils,
			ServiceRequestRepository serviceRequestRepository) {
		this.repository = repository;
		this.utils = utils;
		this.serviceRequestRepository = serviceRequestRepository;
	}

	public Map<String, Object> getFinancialYear(RequestInfo requestInfo, String tenantId) {
		Set<String> financeYears = new HashSet<>(1);
		String financeYear = prepareFinanceYear();
		MdmsCriteriaReq mdmsCriteriaReq = getFinancialYearRequest(requestInfo, financeYear, tenantId);
		StringBuilder url = utils.getMdmsSearchUrl();
		Object res = serviceRequestRepository.fetchResult(url, mdmsCriteriaReq);
		Map<String, Object> financialYearProperties;
		String jsonPath = ChallanConstants.MDMS_EGFFINACIALYEAR_PATH.replace("{}", financeYear);
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

	public EventRequest sendNewExpenditureNotification(RequestInfo requestInfo, String tenantId) {

		List<ActionItem> items = new ArrayList<>();
		String actionLink = config.getNewExpenditureLink();
		ActionItem item = ActionItem.builder().actionUrl(actionLink).build();
		items.add(item);
		Action action = Action.builder().actionUrls(items).build();
		Map<String, Object> additionalDetailsMap = new HashMap<String, Object>();
		List<Event> events = new ArrayList<>();
		additionalDetailsMap.put("localizationCode", NEW_EXPENDITURE_EVENT);
		System.out.println("Action Link::" + actionLink);
		if (tenantId.split("\\.").length >= 2) {
			HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo, NEW_EXPENDITURE_EVENT,
					tenantId);
			System.out.println("Final Message ::" + messageMap.get(NotificationUtil.MSG_KEY));
			events.add(Event.builder().tenantId(tenantId).description(messageMap.get(NotificationUtil.MSG_KEY))
					.eventType(USREVENTS_EVENT_TYPE).name(NEW_EXPENSE_ENTRY).postedBy(USREVENTS_EVENT_POSTEDBY)
					.recepient(getRecepient(requestInfo, tenantId)).source(Source.WEBAPP).eventDetails(null)
					.actions(action)
					.additionalDetails(additionalDetailsMap)
					.build());
		}

		if (!CollectionUtils.isEmpty(events))

		{
			return EventRequest.builder().requestInfo(requestInfo).events(events).build();
		} else {
			return null;
		}

	}

	/**
	 * Send the new expenditure notification every fortnight
	 * 
	 * @param requestInfo
	 */

	public void sendNewExpenditureEvent(RequestInfo requestInfo) {

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

				if (null != config.getIsUserEventEnabled()) {
					if (config.getIsUserEventEnabled()) {
						EventRequest eventRequest = sendNewExpenditureNotification(requestInfo, tenantId);
						if (null != eventRequest)
							notificationService.sendEventNotification(eventRequest);
					}
				}

				if (null != config.getIsSMSEnabled()) {
					if (config.getIsSMSEnabled()) {

						UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo, tenantId,
								Arrays.asList("EXPENSE_PROCESSING","SECRETARY"));
						Map<String, String> mobileNumberIdMap = new LinkedHashMap<>();

						HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo,
								NEW_EXPENDITURE_SMS, tenantId);

						HashMap<String, String> gpwscMap = util.getLocalizationMessage(requestInfo,
								tenantId, tenantId);

						String addExpense = config.getUiAppHost() + config.getExpenditureLink();
						System.out.println("ADD Expense Link :: " + addExpense);
						for (UserInfo userInfo : userDetailResponse.getUser())
							if (userInfo.getName() != null) {
								mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getName());
							} else {
								mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getUserName());
							}
						mobileNumberIdMap.entrySet().stream().forEach(map -> {
							if (messageMap != null && !StringUtils.isEmpty(messageMap.get(NotificationUtil.MSG_KEY))) {
								String message = messageMap.get(NotificationUtil.MSG_KEY);

								message = message.replace("{NEW_EXP_LINK}", getShortenedUrl(addExpense));
								message = message.replace("{GPWSC}",  (gpwscMap != null
										&& !StringUtils.isEmpty(gpwscMap.get(NotificationUtil.MSG_KEY)))
										? gpwscMap.get(NotificationUtil.MSG_KEY)
										: tenantId);
								System.out.println("New Expenditure SMS :: " + message);

								SMSRequest smsRequest = SMSRequest.builder().mobileNumber(map.getKey()).message(message)
										.tenantid(tenantId)
										.templateId(messageMap.get(NotificationUtil.TEMPLATE_KEY))
										.users(new String[] { map.getValue() }).build();
								if(config.isSmsForExpenditureEnabled()) {
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

	public EventRequest sendGenerateDemandNotification(RequestInfo requestInfo, String tenantId) {

		List<ActionItem> items = new ArrayList<>();
		String actionLink = config.getBulkDemandFailedLink();
		ActionItem item = ActionItem.builder().actionUrl(actionLink).build();
		items.add(item);
		Action action = Action.builder().actionUrls(items).build();
		System.out.println("Action Link::" + actionLink);

		Map<String, Object> additionalDetailsMap = new HashMap<String, Object>();
		Map<String, String> attributes = new HashMap<>();
		additionalDetailsMap.put("localizationCode", GENERATE_DEMAND_EVENT);
		
		List<Event> events = new ArrayList<>();
		HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo, GENERATE_DEMAND_EVENT, tenantId);
		String message = messageMap.get(NotificationUtil.MSG_KEY);
		message = message.replace("{BILLING_CYCLE}", LocalDate.now().getMonth().toString());
		attributes.put("{BILLING_CYCLE}", LocalDate.now().getMonth().toString());
		additionalDetailsMap.put("attributes", attributes);
		System.out.println("Demand Genaration Failed::" + messageMap);
		events.add(Event.builder().tenantId(tenantId).description(message).eventType(USREVENTS_EVENT_TYPE)
				.name(USREVENTS_EVENT_NAME).postedBy(USREVENTS_EVENT_POSTEDBY)
				.recepient(getRecepient(requestInfo, tenantId)).source(Source.WEBAPP).eventDetails(null).actions(action)
				.additionalDetails(additionalDetailsMap)
				.build());

		if (!CollectionUtils.isEmpty(events)) {
			return EventRequest.builder().requestInfo(requestInfo).events(events).build();
		} else {
			return null;
		}

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
				if (null != config.getIsUserEventEnabled()) {
					if (config.getIsUserEventEnabled()) {
						EventRequest eventRequest = sendGenerateDemandNotification(requestInfo, tenantId);
						if (null != eventRequest)
							notificationService.sendEventNotification(eventRequest);
					}
				}
			}
		});
	}

	public EventRequest sendMarkExpensebillNotification(RequestInfo requestInfo, String tenantId) {

		List<ActionItem> items = new ArrayList<>();
		String actionLink = config.getMarkPaidExpenditureLink();
		ActionItem item = ActionItem.builder().actionUrl(actionLink).build();
		items.add(item);
		Action action = Action.builder().actionUrls(items).build();
		System.out.println("ActionLink::" + actionLink);
		Map<String, Object> additionalDetailsMap = new HashMap<String, Object>();
		additionalDetailsMap.put("localizationCode", MARK_PAID_BILL_EVENT);
		List<Event> events = new ArrayList<>();
		List<String> activeExpenseCount = repository.getActiveExpenses(tenantId);
		if (null != activeExpenseCount && activeExpenseCount.size() > 0 && activeExpenseCount.get(0)!=null
				 && Integer.parseInt(activeExpenseCount.get(0)) > 0) {
			log.info("Active expense bill Count"+activeExpenseCount.get(0));
			HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo, MARK_PAID_BILL_EVENT, tenantId);
			events.add(Event.builder().tenantId(tenantId)
					.description(formatMarkExpenseMessage(tenantId, messageMap.get(NotificationUtil.MSG_KEY), additionalDetailsMap))
					.eventType(USREVENTS_EVENT_TYPE).name(EXPENSE_PAYMENT).postedBy(USREVENTS_EVENT_POSTEDBY)
					.recepient(getRecepient(requestInfo, tenantId)).source(Source.WEBAPP).eventDetails(null).actions(action)
					.additionalDetails(additionalDetailsMap)
					.build());
		}		

		if (!CollectionUtils.isEmpty(events)) {
			return EventRequest.builder().requestInfo(requestInfo).events(events).build();
		} else {
			return null;
		}

	}

	public String formatMarkExpenseMessage(String tenantId, String message, Map<String, Object> additionalDetailsMap) {
		Map<String, String> attributes = new HashMap<>();
		List<String> activeExpenseCount = repository.getActiveExpenses(tenantId);
		if (null != activeExpenseCount && activeExpenseCount.size() > 0) {
			message = message.replace("{BILL_COUNT_AWAIT}", activeExpenseCount.get(0));
			attributes.put("{BILL_COUNT_AWAIT}", activeExpenseCount.get(0));
			additionalDetailsMap.put("attributes", attributes);
		}
		System.out.println("Final message for Mark Expense::" + message);
		return message;
	}

	/**
	 * Send mark expense bill notification on 7th and 21st of each month
	 * 
	 * @param requestInfo
	 */

	public void sendMarkExpensebillEvent(RequestInfo requestInfo) {
		LocalDate dayofmonth = LocalDate.now().with(TemporalAdjusters.firstDayOfMonth());
		LocalDateTime scheduleTimeFirst = LocalDateTime.of(dayofmonth.getYear(), dayofmonth.getMonth(), 7, 10, 0, 0);
		LocalDateTime scheduleTimeSecond = LocalDateTime.of(dayofmonth.getYear(), dayofmonth.getMonth(), 21, 10, 0, 0);
		DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
		LocalDateTime currentTime = LocalDateTime.parse(LocalDateTime.now().format(dateTimeFormatter),
				dateTimeFormatter);

		List<String> tenantIds = repository.getTenantId();

		tenantIds.forEach(tenantId -> {
			if (tenantId.split("\\.").length >= 2) {
				if (null != config.getIsUserEventEnabled()) {
					if (config.getIsUserEventEnabled()) {
						EventRequest eventRequest = sendMarkExpensebillNotification(requestInfo, tenantId);
						if (null != eventRequest)
							notificationService.sendEventNotification(eventRequest);
					}
				}

				if (null != config.getIsSMSEnabled()) {
					if (config.getIsSMSEnabled()) {

						UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo, tenantId,
								Arrays.asList("EXPENSE_PROCESSING","SECRETARY"));
						Map<String, String> mobileNumberIdMap = new LinkedHashMap<>();

						for (UserInfo userInfo : userDetailResponse.getUser())
							if (userInfo.getName() != null) {
								mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getName());
							} else {
								mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getUserName());
							}

						String addExpense = config.getUiAppHost() + config.getExpenseBillMarkPaidLink();
						System.out.println("ADD Expense Link :: " + addExpense);

						HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo,
								MARK_PAID_BILL_SMS, tenantId);

						HashMap<String, String> gpwscMap = util.getLocalizationMessage(requestInfo,
								tenantId, tenantId);

						mobileNumberIdMap.entrySet().stream().forEach(map -> {
							if (messageMap != null && !StringUtils.isEmpty(messageMap.get(NotificationUtil.MSG_KEY))) {
								String message = messageMap.get(NotificationUtil.MSG_KEY);
								message = message.replace("{EXP_MRK_LINK}", getShortenedUrl(addExpense));

								message = message.replace("{GPWSC}", (gpwscMap != null
										&& !StringUtils.isEmpty(gpwscMap.get(NotificationUtil.MSG_KEY)))
										? gpwscMap.get(NotificationUtil.MSG_KEY)
										: tenantId); // TODO Replace
								// <GPWSC> with
								// value.
								System.out.println("Mark expense bills SMS::" + message);
								SMSRequest smsRequest = SMSRequest.builder().mobileNumber(map.getKey()).message(message)
										.tenantid(tenantId)
										.templateId(messageMap.get(NotificationUtil.TEMPLATE_KEY))
										.users(new String[] { map.getValue() }).build();
								if(config.isSmsForMarkBillEnabled()) {
									producer.push(config.getSmsNotifTopic(), smsRequest);
								}
							}
						});
					}
				}
			}
		});
	}

	public EventRequest sendMonthSummaryNotification(RequestInfo requestInfo, String tenantId) {

		List<ActionItem> items = new ArrayList<>();
		String actionLink = config.getMonthlySummary();
		ActionItem item = ActionItem.builder().actionUrl(actionLink).build();
		items.add(item);
		Action action = Action.builder().actionUrls(items).build();
		System.out.println("ActionLink::" + actionLink);

		Map<String, Object> additionalDetailsMap = new HashMap<String, Object>();
		additionalDetailsMap.put("localizationCode", MONTHLY_SUMMARY_EVENT);
		
		List<Event> events = new ArrayList<>();
		HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo, MONTHLY_SUMMARY_EVENT, tenantId);
		events.add(Event.builder().tenantId(tenantId)
				.description(formatMonthSummaryMessage(requestInfo, tenantId, messageMap.get(NotificationUtil.MSG_KEY), additionalDetailsMap))
				.eventType(USREVENTS_EVENT_TYPE).name(MONTHLY_SUMMARY).postedBy(USREVENTS_EVENT_POSTEDBY)
				.recepient(getRecepient(requestInfo, tenantId)).source(Source.WEBAPP).eventDetails(null).actions(action)
				.additionalDetails(additionalDetailsMap)
				.build());

		if (!CollectionUtils.isEmpty(events)) {
			return EventRequest.builder().requestInfo(requestInfo).events(events).build();
		} else {
			return null;
		}
	}

	public String formatMonthSummaryMessage(RequestInfo requestInfo, String tenantId, String message, Map<String, Object> additionalDetailsMap) {
		Map<String, String> attributes = new HashMap<>();
		LocalDate prviousMonthStart = LocalDate.now().minusMonths(1).with(TemporalAdjusters.firstDayOfMonth());
		LocalDate prviousMonthEnd = LocalDate.now().minusMonths(1).with(TemporalAdjusters.lastDayOfMonth());
		LocalDateTime previousMonthStartDateTime = LocalDateTime.of(prviousMonthStart.getYear(),
				prviousMonthStart.getMonth(), prviousMonthStart.getDayOfMonth(), 0, 0, 0);
		LocalDateTime previousMonthEndDateTime = LocalDateTime.of(prviousMonthEnd.getYear(), prviousMonthEnd.getMonth(),
				prviousMonthEnd.getDayOfMonth(), 23, 59, 59, 999000000);

		List<String> previousMonthCollection = repository.getPreviousMonthExpensePayments(tenantId,
				((Long) previousMonthStartDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()),
				((Long) previousMonthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()));
		if (null != previousMonthCollection && previousMonthCollection.size() > 0) {
			message = message.replace("{PREVIOUS_MONTH_COLLECTION}", previousMonthCollection.get(0));
			attributes.put("{PREVIOUS_MONTH_COLLECTION}", previousMonthCollection.get(0));
		}
		message = message.replace("{PREVIOUS_MONTH}", LocalDate.now().minusMonths(1).getMonth().toString());
		attributes.put("{PREVIOUS_MONTH}", LocalDate.now().minusMonths(1).getMonth().toString());
		List<String> previousMonthExpense = repository.getPreviousMonthExpenseExpenses(tenantId,
				((Long) previousMonthStartDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli())
						.toString(),
				((Long) previousMonthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()).toString());
		if (null != previousMonthExpense && previousMonthExpense.size() > 0) {
			message = message.replace("{PREVIOUS_MONTH_EXPENSE}", previousMonthExpense.get(0));
			attributes.put("{PREVIOUS_MONTH_EXPENSE}", previousMonthExpense.get(0));
		}
		System.out.println("Final message::" + message);
		additionalDetailsMap.put("attributes", attributes);
		return message;
	}

	/**
	 * Send the month summary notification new calendar month
	 * 
	 * @param requestInfo
	 */

	public void sendMonthSummaryEvent(RequestInfo requestInfo) {
		LocalDate dayofmonth = LocalDate.now().with(TemporalAdjusters.firstDayOfMonth());
		LocalDateTime scheduleTime = LocalDateTime.of(dayofmonth.getYear(), dayofmonth.getMonth(),
				dayofmonth.getDayOfMonth(), 10, 0, 0);

		DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
		LocalDateTime currentTime = LocalDateTime.parse(LocalDateTime.now().format(dateTimeFormatter),
				dateTimeFormatter);

		List<String> tenantIds = repository.getTenantId();
		tenantIds.forEach(tenantId -> {
			if (tenantId.split("\\.").length >= 2) {
				if (null != config.getIsUserEventEnabled()) {
					if (config.getIsUserEventEnabled()) {
						EventRequest eventRequest = sendMonthSummaryNotification(requestInfo, tenantId);
						if (null != eventRequest)
							notificationService.sendEventNotification(eventRequest);
					}
				}

				if (null != config.getIsSMSEnabled()) {
					if (config.getIsSMSEnabled()) {
						HashMap<String, String> messageMap = util.getLocalizationMessage(requestInfo,
								MONTHLY_SUMMARY_SMS, tenantId);
						HashMap<String, String> gpwscMap = util.getLocalizationMessage(requestInfo, tenantId, tenantId);

						UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo, tenantId,
								Arrays.asList("EXPENSE_PROCESSING","SECRETARY"));

						String revenueLink = config.getUiAppHost() + config.getMonthRevenueDashboardLink();

						Map<String, String> mobileNumberIdMap = new LinkedHashMap<>();
						for (UserInfo userInfo : userDetailResponse.getUser())
							if (userInfo.getName() != null) {
								mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getName());
							} else {
								mobileNumberIdMap.put(userInfo.getMobileNumber(), userInfo.getUserName());
							}
						mobileNumberIdMap.entrySet().stream().forEach(map -> {
							if (messageMap != null && !StringUtils.isEmpty(messageMap.get(NotificationUtil.MSG_KEY))) {
								String uuidUsername = (String) map.getValue();
								String message = formatMonthSummaryMessage(requestInfo, tenantId,
										messageMap.get(NotificationUtil.MSG_KEY), new HashMap<>());
								message = message.replace("{LINK}", getShortenedUrl(revenueLink));
								message = message.replace("{GPWSC}", (gpwscMap != null
										&& !StringUtils.isEmpty(gpwscMap.get(NotificationUtil.MSG_KEY)))
										? gpwscMap.get(NotificationUtil.MSG_KEY)
										: tenantId); // TODO Replace
								// <GPWSC> with
								// value
								message = message.replace("{user}", uuidUsername);
								System.out.println("SMS Notification::" + message);
								SMSRequest smsRequest = SMSRequest.builder().mobileNumber(map.getKey()).message(message)
										.tenantid(tenantId)
										.templateId(messageMap.get(NotificationUtil.TEMPLATE_KEY))
										.users(new String[] { uuidUsername }).build();
								if(config.isSmsForMonthlySummaryEnabled()) {
									producer.push(config.getSmsNotifTopic(), smsRequest);
								}
							}
						});
					}
				}
			}
		});
	}


	private Recepient getRecepient(RequestInfo requestInfo, String tenantId) {
		Recepient recepient = null;
		UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo, tenantId,
				Arrays.asList("GP_ADMIN","SARPANCH"));
		if (userDetailResponse.getUser().isEmpty())
			log.error("Recepient is absent");
		else {
			List<String> toUsers = userDetailResponse.getUser().stream().map(UserInfo::getUuid)
					.collect(Collectors.toList());

			recepient = Recepient.builder().toUsers(toUsers).toRoles(null).build();
		}
		return recepient;
	}

}
