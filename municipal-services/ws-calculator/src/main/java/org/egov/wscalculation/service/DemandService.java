package org.egov.wscalculation.service;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.Month;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.TextStyle;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.function.Function;
import java.util.stream.Collectors;

import javax.validation.Valid;

import org.apache.commons.lang3.ObjectUtils;
import org.apache.commons.lang3.StringUtils;
import org.egov.common.contract.request.RequestInfo;
import org.egov.common.contract.request.User;
import org.egov.mdms.model.MasterDetail;
import org.egov.mdms.model.MdmsCriteria;
import org.egov.mdms.model.MdmsCriteriaReq;
import org.egov.mdms.model.ModuleDetail;
import org.egov.tracer.model.CustomException;
import org.egov.wscalculation.config.WSCalculationConfiguration;
import org.egov.wscalculation.constants.WSCalculationConstant;
import org.egov.wscalculation.producer.WSCalculationProducer;
import org.egov.wscalculation.repository.DemandRepository;
import org.egov.wscalculation.repository.ServiceRequestRepository;
import org.egov.wscalculation.repository.WSCalculationDao;
import org.egov.wscalculation.util.CalculatorUtil;
import org.egov.wscalculation.util.NotificationUtil;
import org.egov.wscalculation.util.WSCalculationUtil;
import org.egov.wscalculation.validator.WSCalculationValidator;
import org.egov.wscalculation.validator.WSCalculationWorkflowValidator;
import org.egov.wscalculation.web.models.BulkDemand;
import org.egov.wscalculation.web.models.Calculation;
import org.egov.wscalculation.web.models.Category;
import org.egov.wscalculation.web.models.Demand;
import org.egov.wscalculation.web.models.Demand.StatusEnum;
import org.egov.wscalculation.web.models.DemandDetail;
import org.egov.wscalculation.web.models.DemandDetailAndCollection;
import org.egov.wscalculation.web.models.DemandPenaltyResponse;
import org.egov.wscalculation.web.models.DemandRequest;
import org.egov.wscalculation.web.models.DemandResponse;
import org.egov.wscalculation.web.models.GetBillCriteria;
import org.egov.wscalculation.web.models.OwnerInfo;
import org.egov.wscalculation.web.models.Property;
import org.egov.wscalculation.web.models.Recipient;
import org.egov.wscalculation.web.models.RequestInfoWrapper;
import org.egov.wscalculation.web.models.SMSRequest;
import org.egov.wscalculation.web.models.TaxHeadEstimate;
import org.egov.wscalculation.web.models.TaxPeriod;
import org.egov.wscalculation.web.models.WaterConnection;
import org.egov.wscalculation.web.models.WaterConnectionRequest;
import org.egov.wscalculation.web.models.users.UserDetailResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;

import lombok.extern.slf4j.Slf4j;
import net.minidev.json.JSONArray;

@Service
@Slf4j
public class DemandService {

	@Autowired
	private ServiceRequestRepository repository;

	@Autowired
	private ObjectMapper mapper;

	@Autowired
	private PayService payService;

	@Autowired
	private MasterDataService mstrDataService;

	@Autowired
	private WSCalculationUtil utils;

	@Autowired
	private WSCalculationConfiguration configs;

	@Autowired
	private ServiceRequestRepository serviceRequestRepository;

	@Autowired
	private DemandRepository demandRepository;

	@Autowired
	private WSCalculationDao waterCalculatorDao;

	@Autowired
	private CalculatorUtil calculatorUtils;

	@Autowired
	private WSCalculationProducer wsCalculationProducer;

	@Autowired
	private WSCalculationUtil wsCalculationUtil;

	@Autowired
	private WSCalculationWorkflowValidator wsCalulationWorkflowValidator;

	@Autowired
	private WSCalculationValidator wsCalculationValidator;

	@Autowired
	private NotificationUtil util;

	@Autowired
	private UserService userService;

	@Autowired
	private WSCalculationProducer producer;

	@Autowired
	private WSCalculationConfiguration config;

	@Autowired
	private RestTemplate restTemplate;
	
	@Autowired
	private EstimationService estimationService;

	/**
	 * Creates or updates Demand
	 * 
	 * @param requestInfo  The RequestInfo of the calculation request
	 * @param calculations The Calculation Objects for which demand has to be
	 *                     generated or updated
	 */
	public List<Demand> generateDemand(RequestInfo requestInfo, List<Calculation> calculations,
			Map<String, Object> masterMap, boolean isForConnectionNo, boolean isWSUpdateSMS, boolean isAdvance) {
		@SuppressWarnings("unchecked")
		Map<String, Object> financialYearMaster = (Map<String, Object>) masterMap
				.get(WSCalculationConstant.BILLING_PERIOD);
		Long fromDate = (Long) financialYearMaster.get(WSCalculationConstant.STARTING_DATE_APPLICABLES);
		Long toDate = (Long) financialYearMaster.get(WSCalculationConstant.ENDING_DATE_APPLICABLES);

		// List that will contain Calculation for new demands
		List<Calculation> createCalculations = new LinkedList<>();
		// List that will contain Calculation for old demands
		List<Calculation> updateCalculations = new LinkedList<>();
		if (!CollectionUtils.isEmpty(calculations)) {
			// Collect required parameters for demand search
			String tenantId = calculations.get(0).getTenantId();
			Long fromDateSearch = null;
			Long toDateSearch = null;
			Set<String> consumerCodes;
			fromDateSearch = fromDate;
			toDateSearch = toDate;
			consumerCodes = calculations.stream().map(calculation -> calculation.getConnectionNo())
					.collect(Collectors.toSet());

			List<Demand> demands = searchDemand(tenantId, consumerCodes, fromDateSearch, toDateSearch, requestInfo, "ACTIVE");
			Set<String> connectionNumbersFromDemands = new HashSet<>();
			if (!CollectionUtils.isEmpty(demands)) {
				connectionNumbersFromDemands = demands.stream()
						.filter(demand -> demand.getConsumerType()
								.equalsIgnoreCase(isForConnectionNo ? "waterConnection" : "waterConnection-arrears"))
						.map(Demand::getConsumerCode).collect(Collectors.toSet());
				if(isAdvance) {
					connectionNumbersFromDemands = demands.stream()
							.filter(demand -> demand.getConsumerType()
									.equalsIgnoreCase("waterConnection-advance"))
							.map(Demand::getConsumerCode).collect(Collectors.toSet());
				}
			}
			// If demand already exists add it updateCalculations else
			// createCalculations
			for (Calculation calculation : calculations) {
				if (!connectionNumbersFromDemands.contains(calculation.getConnectionNo()))
					createCalculations.add(calculation);
				else
					updateCalculations.add(calculation);
			}
		}
		List<Demand> createdDemands = new ArrayList<>();
		if (!CollectionUtils.isEmpty(createCalculations))
			createdDemands = createDemand(requestInfo, createCalculations, masterMap, isForConnectionNo, isWSUpdateSMS,isAdvance);

		if (!CollectionUtils.isEmpty(updateCalculations))
			createdDemands = updateDemandForCalculation(requestInfo, updateCalculations, fromDate, toDate,
					isForConnectionNo);
		return createdDemands;
	}

	/**
	 * 
	 * @param requestInfo  RequestInfo
	 * @param calculations List of Calculation
	 * @param masterMap    Master MDMS Data
	 * @return Returns list of demands
	 */
	private List<Demand> createDemand(RequestInfo requestInfo, List<Calculation> calculations,
			Map<String, Object> masterMap, boolean isForConnectionNO, boolean isWSUpdateSMS, boolean isAdvance) {
		List<Demand> demands = new LinkedList<>();
		List<SMSRequest> smsRequests = new LinkedList<>();
		DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("d/MM/uuuu");

		String billCycle = "";
		String consumerCode = null;

		List<Demand> finalDemandRes = new ArrayList<>();
		for (Calculation calculation : calculations) {
			List<Demand> demandRes = null;
			WaterConnection connection = calculation.getWaterConnection();
			if (connection == null) {
				throw new CustomException("INVALID_WATER_CONNECTION",
						"Demand cannot be generated for "
								+ (isForConnectionNO ? calculation.getConnectionNo() : calculation.getApplicationNO())
								+ " Water Connection with this number does not exist ");
			}
			WaterConnectionRequest waterConnectionRequest = WaterConnectionRequest.builder().waterConnection(connection)
					.requestInfo(requestInfo).build();
			Property property = wsCalculationUtil.getProperty(waterConnectionRequest);
			String tenantId = calculation.getTenantId();
			consumerCode = calculation.getConnectionNo();
			User owner = property.getOwners().get(0).toCommonUser();
			if (!CollectionUtils.isEmpty(waterConnectionRequest.getWaterConnection().getConnectionHolders())) {
				owner = waterConnectionRequest.getWaterConnection().getConnectionHolders().get(0).toCommonUser();
			}
			List<DemandDetail> demandDetails = new LinkedList<>();
			calculation.getTaxHeadEstimates().forEach(taxHeadEstimate -> {
				demandDetails.add(DemandDetail.builder().taxAmount(taxHeadEstimate.getEstimateAmount())
						.taxHeadMasterCode(taxHeadEstimate.getTaxHeadCode()).collectionAmount(BigDecimal.ZERO)
						.tenantId(tenantId).build());
			});
			@SuppressWarnings("unchecked")
			Map<String, Object> financialYearMaster = (Map<String, Object>) masterMap
					.get(WSCalculationConstant.BILLING_PERIOD);

			Long fromDate = (Long) financialYearMaster.get(WSCalculationConstant.STARTING_DATE_APPLICABLES);
			Long toDate = (Long) financialYearMaster.get(WSCalculationConstant.ENDING_DATE_APPLICABLES);
			Long expiryDate = (Long) financialYearMaster.get(WSCalculationConstant.Demand_Expiry_Date_String);
			BigDecimal minimumPayableAmount = configs.getMinimumPayableAmount();
			String businessService = configs.getBusinessService();

			LocalDate firstDate = Instant.ofEpochMilli(fromDate).atZone(ZoneId.systemDefault()).toLocalDate();
			LocalDate lastDate = Instant.ofEpochMilli(toDate).atZone(ZoneId.systemDefault()).toLocalDate();

			String lastDateTime = lastDate.toString();
			if (firstDate.isEqual(lastDate) && lastDateTime.contains("-04-01")) {
				toDate = toDate + 60000;
			}

			billCycle = firstDate.format(dateTimeFormatter) + " - " + lastDate.format(dateTimeFormatter);
			addRoundOffTaxHead(calculation.getTenantId(), demandDetails);

			if(isAdvance) {
				demands.add(Demand.builder().consumerCode(consumerCode).demandDetails(demandDetails).payer(owner)
						.minimumAmountPayable(minimumPayableAmount).tenantId(tenantId).taxPeriodFrom(fromDate)
						.taxPeriodTo(toDate).consumerType("waterConnection-advance")
						.businessService(businessService).status(StatusEnum.valueOf("ACTIVE")).billExpiryTime(expiryDate)
						.build());
			}else {
				demands.add(Demand.builder().consumerCode(consumerCode).demandDetails(demandDetails).payer(owner)
						.minimumAmountPayable(minimumPayableAmount).tenantId(tenantId).taxPeriodFrom(fromDate)
						.taxPeriodTo(toDate).consumerType(isForConnectionNO ? "waterConnection" : "waterConnection-arrears")
						.businessService(businessService).status(StatusEnum.valueOf("ACTIVE")).billExpiryTime(expiryDate)
						.build());
			}
			demandRes = demandRepository.saveDemand(requestInfo, demands);
			finalDemandRes.addAll(demandRes);



			if (!isWSUpdateSMS) {
				List<String> billNumbers = fetchBill(demands, waterConnectionRequest.getRequestInfo());
				Long billDate = fetchBillDate(demands,waterConnectionRequest.getRequestInfo());
				billDate =billDate + 1296000000l;
				LocalDate billDateLocal = Instant.ofEpochMilli(billDate).atZone(ZoneId.systemDefault()).toLocalDate();
				String paymentDueDate = billDateLocal.format(dateTimeFormatter);
				if(isOnlinePaymentAllowed(requestInfo,tenantId)) {
					if(fetchTotalBillAmount(demands,requestInfo).signum()> 0) {
						sendPaymentSMSNotification(requestInfo,tenantId,owner,waterConnectionRequest,property,demandDetails,consumerCode,demands,isForConnectionNO,businessService,billCycle,billNumbers,paymentDueDate);
						//sendPaymentAndBillSMSNotification(requestInfo,tenantId,owner,waterConnectionRequest,property,demandDetails,consumerCode,demands,isForConnectionNO,businessService,billCycle,billNumbers,paymentDueDate);
					}
				}
				sendDownloadBillSMSNotification(requestInfo,tenantId,owner,waterConnectionRequest,property,demandDetails,consumerCode,demands,isForConnectionNO,businessService,billCycle,billNumbers,paymentDueDate);
			}
		}
		log.info("Demand Object" + demands.toString());


		return finalDemandRes;
	}

	private void sendPaymentSMSNotification(RequestInfo requestInfo, String tenantId, User owner, WaterConnectionRequest waterConnectionRequest, Property property, List<DemandDetail> demandDetails, String consumerCode, List<Demand> demands, Boolean isForConnectionNO, String businessService, String billCycle, List<String> billNumbers, String paymentDueDate ) {
		HashMap<String, String> localizationMessage = util.getLocalizationMessage(requestInfo,
				WSCalculationConstant.mGram_Consumer_Payment, tenantId);
		String connectionType = null;
        if(ObjectUtils.isEmpty(waterConnectionRequest.getWaterConnection().getMeterId()) || waterConnectionRequest.getWaterConnection().getMeterId() ==  null)
			connectionType = "non-metered";
		else
			connectionType = "metered";
		String actionLinkPayment = config.getNotificationUrl()
				+ config.getBillPaymentSMSLink().replace("$mobileNumber", owner.getMobileNumber())
				.replace("$consumerCode", waterConnectionRequest.getWaterConnection().getConnectionNo())
				.replace("$tenantId", property.getTenantId())
				.replace("$businessService", businessService)
				.replace("$connectionType", connectionType);
		log.info("Payment Link ::: " + actionLinkPayment);

		String messageString = localizationMessage.get(WSCalculationConstant.MSG_KEY);
		BigDecimal totalAmount = fetchTotalBillAmount(demands,requestInfo);

		System.out.println("Localization message::" + messageString);
		if (!StringUtils.isEmpty(messageString) && isForConnectionNO) {
			log.info("Demand Object" + demands.toString());
			messageString = messageString.replace("{ownername}", owner.getName());
			messageString = messageString.replace("{billamount}",totalAmount.toString());
			messageString = messageString.replace("{Date}", paymentDueDate);
			messageString = messageString.replace("{connectionno}", consumerCode);
			messageString = messageString.replace("{PAY_LINK}", getShortenedUrl(actionLinkPayment));

			System.out.println("payment genaration Message1::" + messageString);

			SMSRequest sms = SMSRequest.builder().mobileNumber(owner.getMobileNumber()).message(messageString).tenantid(tenantId)
					.category(Category.TRANSACTION).build();
			if(config.isSmsForPaymentLinkEnable()) {
				producer.push(config.getSmsNotifTopic(), sms);
			}
		}
	}
	private void sendDownloadBillSMSNotification(RequestInfo requestInfo, String tenantId, User owner, WaterConnectionRequest waterConnectionRequest, Property property, List<DemandDetail> demandDetails, String consumerCode, List<Demand> demands, Boolean isForConnectionNO, String businessService, String billCycle,List<String> billNumbers, String paymentDueDate) {
		log.info("RequestInfo is ->"+requestInfo);
		log.info("tenantId is ->"+tenantId);
		log.info("Owner details ->"+owner.toString());
		log.info("waterConnectionRequest is ->"+waterConnectionRequest.toString());
		log.info("property is ->"+property.toString());
		log.info("demandDetails is ->"+demandDetails.toString());
		log.info("isForConnectionNO is ->"+isForConnectionNO);
		log.info("billCycle is ->"+billCycle);
		log.info("billNumbers is ->"+billNumbers.toString());
		HashMap<String, String> localizationMessage = util.getLocalizationMessage(requestInfo,
				WSCalculationConstant.mGram_Consumer_NewBill, tenantId);
		String actionLink = config.getNotificationUrl()
				+ config.getBillDownloadSMSLink().replace("$mobile", owner.getMobileNumber())
				.replace("$consumerCode", waterConnectionRequest.getWaterConnection().getConnectionNo())
				.replace("$tenantId", property.getTenantId());

		if (waterConnectionRequest.getWaterConnection().getConnectionType()
				.equalsIgnoreCase(WSCalculationConstant.meteredConnectionType)) {
			actionLink = actionLink.replace("$key", "ws-bill");
		} else {
			actionLink = actionLink.replace("$key", "ws-bill-nm");
		}
		String messageString = localizationMessage.get(WSCalculationConstant.MSG_KEY);

		System.out.println("Localization message get bill::" + messageString);
		System.out.println("isForConnectionNO:" + isForConnectionNO);
		if (!StringUtils.isEmpty(messageString) && isForConnectionNO) {
			log.info("Demand Object get bill" + demands.toString());
			log.info("requestInfo get Bill" + requestInfo);
			log.info("bill number get bill size :" + billNumbers.size());
			if (billNumbers.size() > 0) {
				actionLink = actionLink.replace("$billNumber", billNumbers.get(0));
				messageString = messageString.replace("{ownername}", owner.getName());
				messageString = messageString.replace("{Period}", billCycle);
				messageString = messageString.replace("{consumerno}", consumerCode);
				messageString = messageString.replace("{billamount}", demandDetails.stream()
						.map(DemandDetail::getTaxAmount).reduce(BigDecimal.ZERO, BigDecimal::add).toString());
				messageString = messageString.replace("{BILL_LINK}", getShortenedUrl(actionLink));

				System.out.println("Demand genaration Message get bill::" + messageString);

				SMSRequest sms = SMSRequest.builder().mobileNumber(owner.getMobileNumber()).message(messageString).tenantid(tenantId)
						.category(Category.TRANSACTION).build();
				if(config.isSmsForBillDownloadEnabled()) {
					producer.push(config.getSmsNotifTopic(), sms);
				}
			}

		}
	}

	private void sendPaymentAndBillSMSNotification(RequestInfo requestInfo, String tenantId, User owner, WaterConnectionRequest waterConnectionRequest, Property property, List<DemandDetail> demandDetails, String consumerCode, List<Demand> demands, Boolean isForConnectionNO, String businessService, String billCycle,List<String> billNumbers, String paymentDueDate) {
		HashMap<String, String> localizationMessage = util.getLocalizationMessage(requestInfo,
				WSCalculationConstant.mGram_Consumer_Bill_Payment_combine, tenantId);

		String actionLinkPayment = config.getNotificationUrl()
				+ config.getBillPaymentSMSLink().replace("$mobileNumber", owner.getMobileNumber())
				.replace("$consumerCode", waterConnectionRequest.getWaterConnection().getConnectionNo())
				.replace("$tenantId", property.getTenantId())
				.replace("$businessService", businessService);
		String actionBillLink = config.getNotificationUrl()
				+ config.getBillDownloadSMSLink().replace("$mobile", owner.getMobileNumber())
				.replace("$consumerCode", waterConnectionRequest.getWaterConnection().getConnectionNo())
				.replace("$tenantId", property.getTenantId());

		if (waterConnectionRequest.getWaterConnection().getConnectionType()
				.equalsIgnoreCase(WSCalculationConstant.meteredConnectionType)) {
			actionBillLink = actionBillLink.replace("$key", "ws-bill");
		} else {
			actionBillLink = actionBillLink.replace("$key", "ws-bill-nm");
		}
        BigDecimal totalAmount =  fetchTotalBillAmount(demands, requestInfo);
		String messageString = localizationMessage.get(WSCalculationConstant.MSG_KEY);

		System.out.println("Localization message get payment and bill::" + messageString);
		if (!StringUtils.isEmpty(messageString) && isForConnectionNO) {
			log.info("Demand Object get payment and bill" + demands.toString());
			log.info("requestInfo get Bill and Payment::" +requestInfo);
			log.info("Bill Number get payment and bill:: " + billNumbers.toString());
			if (billNumbers.size() > 0) {
				actionBillLink = actionBillLink.replace("$billNumber", billNumbers.get(0));
			}
			messageString = messageString.replace("{ownername}", owner.getName());
			//messageString = messageString.replace("{billmaount}", fetchTotalBillAmount(demands,waterConnectionRequest.getRequestInfo()).toString());
			messageString = messageString.replace("{billmaount}",totalAmount.toString() );
			messageString = messageString.replace("{consumerno}", consumerCode);
			messageString = messageString.replace("{PAY_LINK}", getShortenedUrl(actionLinkPayment));
			messageString = messageString.replace("{BILL_LINK}", getShortenedUrl(actionBillLink));

			System.out.println("Denmand and Payment genaration Message::" + messageString);

			SMSRequest sms = SMSRequest.builder().mobileNumber(owner.getMobileNumber()).message(messageString)
					.category(Category.TRANSACTION).tenantid(tenantId).build();
			if(config.isSmsForBillDownloadEnabled() && config.isSmsForPaymentLinkEnable()) {
				producer.push(config.getSmsNotifTopic(), sms);
			}
		}
	}

	public BigDecimal fetchTotalBillAmount(List<Demand> demandResponse, RequestInfo requestInfo) {
		boolean notificationSent = false;
		BigDecimal totalAmount = BigDecimal.ZERO;
		for (Demand demand : demandResponse) {
			try {
				Object result = serviceRequestRepository.fetchResult(
						calculatorUtils.getFetchBillURL(demand.getTenantId(), demand.getConsumerCode()),
						RequestInfoWrapper.builder().requestInfo(requestInfo).build());
				log.debug("response from fetch bill total bill: " + mapper.writeValueAsString(result));
				List<Map<String, Object>> jsonOutput = JsonPath.read(result, "$.Bill");
				log.info("Bill Response totalAMount fetch:: " + result);
                log.info(mapper.writeValueAsString(jsonOutput));
				totalAmount=new BigDecimal(jsonOutput.get(0).get("totalAmount").toString());
				//totalAmount = new BigDecimal(JsonPath.read(result, "$.Bill[0].totalAmount").toString());
				log.info("Bill Response totalAMount:: " + result);

				HashMap<String, Object> billResponse = new HashMap<>();

				billResponse.put("requestInfo", requestInfo);
				billResponse.put("billResponse", result);
				wsCalculationProducer.push(configs.getPayTriggers(), billResponse);
				notificationSent = true;
			} catch (Exception ex) {
				log.error("Fetch Bill Error", ex);
			}
		}
		return totalAmount;
	}
	private String getShortenedUrl(String url) {
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

	private void sendSMSNotification(RequestInfo requestInfo, List<SMSRequest> smsRequests, String billCycle,
			String consumerCode, List<DemandDetail> demandDetails) {
		UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo, Arrays.asList("GP_ADMIN"),
				requestInfo.getUserInfo().getTenantId().substring(0,2));
		for (OwnerInfo ownerInfo : userDetailResponse.getUser()) {
			String localizationMessage = util.getLocalizationMessages(ownerInfo.getTenantId(), requestInfo);
			String messageString = util.getMessageTemplate(WSCalculationConstant.mGram_Consumer_NewBill,
					localizationMessage);
			if (messageString != null && !StringUtils.isEmpty(messageString)) {
				messageString = messageString.replace("{BILL_LINK}", configs.getDownLoadBillLink());
				messageString = messageString.replace("{ULB_Name}", ownerInfo.getTenantId());
				messageString = messageString.replace("{ownername}", ownerInfo.getUserName());
				messageString = messageString.replace("{billingcycle}", billCycle);
				messageString = messageString.replace("{consumerno}", consumerCode);
				SMSRequest sms = SMSRequest.builder().mobileNumber(ownerInfo.getMobileNumber()).message(messageString)
						.category(Category.TRANSACTION).build();
				producer.push(config.getSmsNotifTopic(), sms);
			}
		}
	}

	/**
	 * Returns the list of new DemandDetail to be added for updating the demand
	 * 
	 * @param calculation   The calculation object for the update request
	 * @param demandDetails The list of demandDetails from the existing demand
	 * @return The list of new DemandDetails
	 */
	private List<DemandDetail> getUpdatedDemandDetails(Calculation calculation, List<DemandDetail> demandDetails) {

		List<DemandDetail> newDemandDetails = new ArrayList<>();
		Map<String, List<DemandDetail>> taxHeadToDemandDetail = new HashMap<>();

		demandDetails.forEach(demandDetail -> {
			if (!taxHeadToDemandDetail.containsKey(demandDetail.getTaxHeadMasterCode())) {
				List<DemandDetail> demandDetailList = new LinkedList<>();
				demandDetailList.add(demandDetail);
				taxHeadToDemandDetail.put(demandDetail.getTaxHeadMasterCode(), demandDetailList);
			} else
				taxHeadToDemandDetail.get(demandDetail.getTaxHeadMasterCode()).add(demandDetail);
		});

		BigDecimal diffInTaxAmount;
		List<DemandDetail> demandDetailList;
		BigDecimal total;

		for (TaxHeadEstimate taxHeadEstimate : calculation.getTaxHeadEstimates()) {
			if (!taxHeadToDemandDetail.containsKey(taxHeadEstimate.getTaxHeadCode()))
				newDemandDetails.add(DemandDetail.builder().taxAmount(taxHeadEstimate.getEstimateAmount())
						.taxHeadMasterCode(taxHeadEstimate.getTaxHeadCode()).tenantId(calculation.getTenantId())
						.collectionAmount(BigDecimal.ZERO).build());
			else {
				demandDetailList = taxHeadToDemandDetail.get(taxHeadEstimate.getTaxHeadCode());
				total = demandDetailList.stream().map(DemandDetail::getTaxAmount).reduce(BigDecimal.ZERO,
						BigDecimal::add);
				diffInTaxAmount = taxHeadEstimate.getEstimateAmount().subtract(total);
				if (diffInTaxAmount.compareTo(BigDecimal.ZERO) != 0) {
					newDemandDetails.add(DemandDetail.builder().taxAmount(diffInTaxAmount)
							.taxHeadMasterCode(taxHeadEstimate.getTaxHeadCode()).tenantId(calculation.getTenantId())
							.collectionAmount(BigDecimal.ZERO).build());
				}
			}
		}
		List<DemandDetail> combinedBillDetails = new LinkedList<>(demandDetails);
		combinedBillDetails.addAll(newDemandDetails);
		addRoundOffTaxHead(calculation.getTenantId(), combinedBillDetails);
		return combinedBillDetails;
	}

	/**
	 * Adds roundOff taxHead if decimal values exists
	 * 
	 * @param tenantId      The tenantId of the demand
	 * @param demandDetails The list of demandDetail
	 */
	private void addRoundOffTaxHead(String tenantId, List<DemandDetail> demandDetails) {
		BigDecimal totalTax = BigDecimal.ZERO;

		BigDecimal previousRoundOff = BigDecimal.ZERO;

		/*
		 * Sum all taxHeads except RoundOff as new roundOff will be calculated
		 */
		for (DemandDetail demandDetail : demandDetails) {
			if (!demandDetail.getTaxHeadMasterCode().equalsIgnoreCase(WSCalculationConstant.WS_Round_Off))
				totalTax = totalTax.add(demandDetail.getTaxAmount());
			else
				previousRoundOff = previousRoundOff.add(demandDetail.getTaxAmount());
		}

		BigDecimal decimalValue = totalTax.remainder(BigDecimal.ONE);
		BigDecimal midVal = BigDecimal.valueOf(0.5);
		BigDecimal roundOff = BigDecimal.ZERO;

		/*
		 * If the decimal amount is greater than 0.5 we subtract it from 1 and put it as
		 * roundOff taxHead so as to nullify the decimal eg: If the tax is 12.64 we will
		 * add extra tax roundOff taxHead of 0.36 so that the total becomes 13
		 */
		if (decimalValue.compareTo(midVal) >= 0)
			roundOff = BigDecimal.ONE.subtract(decimalValue);

		/*
		 * If the decimal amount is less than 0.5 we put negative of it as roundOff
		 * taxHead so as to nullify the decimal eg: If the tax is 12.36 we will add
		 * extra tax roundOff taxHead of -0.36 so that the total becomes 12
		 */
		if (decimalValue.compareTo(midVal) < 0)
			roundOff = decimalValue.negate();

		/*
		 * If roundOff already exists in previous demand create a new roundOff taxHead
		 * with roundOff amount equal to difference between them so that it will be
		 * balanced when bill is generated. eg: If the previous roundOff amount was of
		 * -0.36 and the new roundOff excluding the previous roundOff is 0.2 then the
		 * new roundOff will be created with 0.2 so that the net roundOff will be 0.2
		 * -(-0.36)
		 */
		if (previousRoundOff.compareTo(BigDecimal.ZERO) != 0) {
			roundOff = roundOff.subtract(previousRoundOff);
		}

		if (roundOff.compareTo(BigDecimal.ZERO) != 0) {
			DemandDetail roundOffDemandDetail = DemandDetail.builder().taxAmount(roundOff)
					.taxHeadMasterCode(WSCalculationConstant.WS_Round_Off).tenantId(tenantId)
					.collectionAmount(BigDecimal.ZERO).build();
			demandDetails.add(roundOffDemandDetail);
		}
	}

	/**
	 * Searches demand for the given consumerCode and tenantIDd
	 * 
	 * @param tenantId      The tenantId of the tradeLicense
	 * @param consumerCodes The set of consumerCode of the demands
	 * @param requestInfo   The RequestInfo of the incoming request
	 * @return Lis to demands for the given consumerCode
	 */
	public List<Demand> searchDemand(String tenantId, Set<String> consumerCodes, Long taxPeriodFrom, Long taxPeriodTo,
			RequestInfo requestInfo, String status) {
		Object result = serviceRequestRepository.fetchResult(
				getDemandSearchURL(tenantId, consumerCodes, taxPeriodFrom, taxPeriodTo, status),
				RequestInfoWrapper.builder().requestInfo(requestInfo).build());
		try {
			return mapper.convertValue(result, DemandResponse.class).getDemands();
		} catch (IllegalArgumentException e) {
			throw new CustomException("PARSING_ERROR", "Failed to parse response from Demand Search");
		}

	}

	/**
	 * Creates demand Search url based on tenantId,businessService, and
	 * 
	 * @return demand search url
	 */
	public StringBuilder getDemandSearchURLForDemandId() {
		StringBuilder url = new StringBuilder(configs.getBillingServiceHost());
		url.append(configs.getDemandSearchEndPoint());
		url.append("?");
		url.append("tenantId=");
		url.append("{1}");
		url.append("&");
		url.append("businessService=");
		url.append("{2}");
		url.append("&");
		url.append("consumerCode=");
		url.append("{3}");
		url.append("&");
		url.append("isPaymentCompleted=false");
		return url;
	}

	/**
	 * 
	 * @param tenantId     TenantId
	 * @param consumerCode Connection number
	 * @param requestInfo  - RequestInfo
	 * @return List of Demand
	 */
	public List<Demand> searchDemandBasedOnConsumerCode(String tenantId, String consumerCode, RequestInfo requestInfo) {
		String uri = getDemandSearchURLForDemandId().toString();
		uri = uri.replace("{1}", tenantId);
		uri = uri.replace("{2}", configs.getBusinessService());
		uri = uri.replace("{3}", consumerCode);
		Object result = serviceRequestRepository.fetchResult(new StringBuilder(uri),
				RequestInfoWrapper.builder().requestInfo(requestInfo).build());
		try {
			return mapper.convertValue(result, DemandResponse.class).getDemands();
		} catch (IllegalArgumentException e) {
			throw new CustomException("PARSING_ERROR", "Failed to parse response from Demand Search");
		}
	}

	/**
	 * Creates demand Search url based on tenantId,businessService, period from,
	 * period to and ConsumerCode
	 * 
	 * @return demand search url
	 */
	public StringBuilder getDemandSearchURL(String tenantId, Set<String> consumerCodes, Long taxPeriodFrom,
			Long taxPeriodTo, String status) {
		StringBuilder url = new StringBuilder(configs.getBillingServiceHost());
		String businessService = taxPeriodFrom == null ? WSCalculationConstant.ONE_TIME_FEE_SERVICE_FIELD
				: configs.getBusinessService();
		url.append(configs.getDemandSearchEndPoint());
		url.append("?");
		url.append("tenantId=");
		url.append(tenantId);
		url.append("&");
		url.append("businessService=");
		url.append(businessService);
		url.append("&");
		url.append("consumerCode=");
		url.append(StringUtils.join(consumerCodes, ','));
		if (taxPeriodFrom != null) {
			url.append("&");
			url.append("periodFrom=");
			url.append(taxPeriodFrom.toString());
		}
		if (taxPeriodTo != null) {
			url.append("&");
			url.append("periodTo=");
			url.append(taxPeriodTo.toString());
		}
		if(status !=null) {
			url.append("&");
			url.append("status=");
			url.append(status);
		}
		return url;
	}

	/**
	 * 
	 * @param getBillCriteria    Bill Criteria
	 * @param requestInfoWrapper contains request info wrapper
	 * @return updated demand response
	 */
	public List<Demand> updateDemands(GetBillCriteria getBillCriteria, RequestInfoWrapper requestInfoWrapper) {
		Boolean isGetPenaltyEstimate = Boolean.valueOf(getBillCriteria.getIsGetPenaltyEstimate());
		if (getBillCriteria.getAmountExpected() == null)
			getBillCriteria.setAmountExpected(BigDecimal.ZERO);
		RequestInfo requestInfo = requestInfoWrapper.getRequestInfo();
		Map<String, JSONArray> billingSlabMaster = new HashMap<>();

		Map<String, JSONArray> timeBasedExemptionMasterMap = new HashMap<>();
		mstrDataService.setWaterConnectionMasterValues(requestInfo, getBillCriteria.getTenantId(), billingSlabMaster,
				timeBasedExemptionMasterMap);
		
		if (CollectionUtils.isEmpty(getBillCriteria.getConsumerCodes()))
			getBillCriteria.setConsumerCodes(Collections.singletonList(getBillCriteria.getConnectionNumber()));

		DemandResponse res = mapper.convertValue(
				repository.fetchResult(utils.getDemandSearchUrl(getBillCriteria), requestInfoWrapper),
				DemandResponse.class);
//		if (CollectionUtils.isEmpty(res.getDemands())) {
//			Map<String, String> map = new HashMap<>();
//			map.put(WSCalculationConstant.EMPTY_DEMAND_ERROR_CODE, WSCalculationConstant.EMPTY_DEMAND_ERROR_MESSAGE);
//			throw new CustomException(map);
//		}
		List<Demand> demandsToBeUpdated = new LinkedList<>();
		List<Demand> demandResponse = new LinkedList<>();

		// Loop through the consumerCodes and re-calculate the time base applicable
		if (!CollectionUtils.isEmpty(res.getDemands())) {
			List<Demand> demResponse = res.getDemands();

			
			CopyOnWriteArrayList<Demand> demList = new CopyOnWriteArrayList<>(demResponse);

			for(Demand demand: demList) {
				if(WSCalculationConstant.DEMAND_CANCELLED_STATUS.equalsIgnoreCase(demand.getStatus().toString())){
					demList.remove(demand);
				}
			}
			if(demList.isEmpty()) {
				return res.getDemands();
			}
			
			Map<String, Demand> consumerCodeToDemandMap = res.getDemands().stream()
					.collect(Collectors.toMap(Demand::getId, Function.identity()));

			String tenantId = getBillCriteria.getTenantId();

			List<TaxPeriod> taxPeriods = mstrDataService.getTaxPeriodList(requestInfoWrapper.getRequestInfo(), tenantId,
					WSCalculationConstant.SERVICE_FIELD_VALUE_WS);
			
			if(timeBasedExemptionMasterMap.get(WSCalculationConstant.WC_PENANLTY_MASTER) == null) {
				mstrDataService.setWaterConnectionMasterValues(requestInfo, getBillCriteria.getTenantId().substring(0,2), billingSlabMaster,
						timeBasedExemptionMasterMap);
			}
			
			Map<String, Object> penaltyMaster = mstrDataService.getApplicableMaster(estimationService.getAssessmentYear(), timeBasedExemptionMasterMap.get(WSCalculationConstant.WC_PENANLTY_MASTER));
	
	
			if(null != penaltyMaster) {
				String type = (String) penaltyMaster.get(WSCalculationConstant.TYPE_FIELD_NAME);
				String subType = (String) penaltyMaster.get(WSCalculationConstant.SUBTYPE_FIELD_NAME);
				
				int demandListSize = demList.size();
				int demandDetailListSize = 0;

				Demand latestDemand = demList.get(demandListSize - 1);
				
				if(isGetPenaltyEstimate && latestDemand.getDemandDetails().stream().filter(i->i.getTaxHeadMasterCode().equalsIgnoreCase(WSCalculationConstant.WS_TIME_PENALTY)).count() > 0) {
					return res.getDemands();
				}
				if (latestDemand.getStatus() != null
						&& WSCalculationConstant.DEMAND_CANCELLED_STATUS.equalsIgnoreCase(latestDemand.getStatus().toString()))
					throw new CustomException(WSCalculationConstant.EG_WS_INVALID_DEMAND_ERROR,
							WSCalculationConstant.EG_WS_INVALID_DEMAND_ERROR_MSG);
				if(type.equalsIgnoreCase("Flat") && subType.equalsIgnoreCase(WSCalculationConstant.PENALTY_OUTSTANDING)) {
					List<Demand> demandLst = new ArrayList<>(demList);

					for(Demand demand : demandLst) {
						for(DemandDetail demandDetail : demand.getDemandDetails()) {
							if(demandDetail.getTaxAmount().compareTo(demandDetail.getCollectionAmount()) != 0) {
								demandDetailListSize = demandDetailListSize + 1;						}
						}
						
					}
					applyTimeBasedApplicables(latestDemand, requestInfoWrapper, timeBasedExemptionMasterMap, taxPeriods, isGetPenaltyEstimate,BigDecimal.ZERO,penaltyMaster,demandDetailListSize);
					demandsToBeUpdated.add(latestDemand);

				}
				if((type.equalsIgnoreCase("Flat") && subType.equalsIgnoreCase(WSCalculationConstant.PENALTY_CURRENT_MONTH))
						|| (type.equalsIgnoreCase("Fixed") && subType.equalsIgnoreCase(WSCalculationConstant.PENALTY_CURRENT_MONTH))) {
					if(latestDemand.getDemandDetails().stream().filter(i->i.getTaxHeadMasterCode().equalsIgnoreCase(WSCalculationConstant.WS_CHARGE)).count() > 0){
						applyTimeBasedApplicables(latestDemand, requestInfoWrapper, timeBasedExemptionMasterMap, taxPeriods, isGetPenaltyEstimate,BigDecimal.ZERO,penaltyMaster,demandDetailListSize);
						demandsToBeUpdated.add(latestDemand);
					}
				}
				
				
				if(type.equalsIgnoreCase("Fixed") && (subType.equalsIgnoreCase(WSCalculationConstant.PENALTY_OUTSTANDING)
						|| subType.equalsIgnoreCase(WSCalculationConstant.OUTSTANDING))) {
					List<Demand> demandList = new ArrayList<>(demList);
					BigDecimal waterChargeApplicable = BigDecimal.ZERO;
					BigDecimal oldPenalty = BigDecimal.ZERO;
					demandList.remove(demandListSize - 1);
					if(demandListSize > 1) {
						for(Demand demand : demandList) {
							for(DemandDetail demandDetail : demand.getDemandDetails()) {
								if (WSCalculationConstant.TAX_APPLICABLE.contains(demandDetail.getTaxHeadMasterCode())) {
									waterChargeApplicable = waterChargeApplicable.add(demandDetail.getTaxAmount()).subtract(demandDetail.getCollectionAmount());
								}
								if(subType.equalsIgnoreCase(WSCalculationConstant.PENALTY_OUTSTANDING)) {
									if (demandDetail.getTaxHeadMasterCode().equalsIgnoreCase(WSCalculationConstant.WS_TIME_PENALTY)) {
										oldPenalty = oldPenalty.add(demandDetail.getTaxAmount()).subtract(demandDetail.getCollectionAmount());
										waterChargeApplicable = waterChargeApplicable.add(oldPenalty);
									}
								}
								
							}
						}
					}
					
					applyTimeBasedApplicables(latestDemand, requestInfoWrapper, timeBasedExemptionMasterMap, taxPeriods, isGetPenaltyEstimate,waterChargeApplicable,penaltyMaster,demandDetailListSize);
					demandsToBeUpdated.add(latestDemand);
					
				}
				demandResponse.addAll(res.getDemands());
			}
			
			else {
				

				if(consumerCodeToDemandMap.size() == 1) {
					if (consumerCodeToDemandMap.entrySet().iterator().next().getValue().getStatus() != null
							&& WSCalculationConstant.DEMAND_CANCELLED_STATUS.equalsIgnoreCase(consumerCodeToDemandMap.entrySet().iterator().next().getValue().getStatus().toString()))
						throw new CustomException(WSCalculationConstant.EG_WS_INVALID_DEMAND_ERROR,
								WSCalculationConstant.EG_WS_INVALID_DEMAND_ERROR_MSG);
				}
				consumerCodeToDemandMap.forEach((id, demand) -> {
					if (demand.getStatus() != null
							&& !WSCalculationConstant.DEMAND_CANCELLED_STATUS.equalsIgnoreCase(demand.getStatus().toString()))
					applyTimeBasedApplicables(demand, requestInfoWrapper, timeBasedExemptionMasterMap, taxPeriods, isGetPenaltyEstimate, BigDecimal.ZERO, penaltyMaster,0);
//					addRoundOffTaxHead(tenantId, demand.getDemandDetails());
					demandsToBeUpdated.add(demand);
				});
			}
			
		
			// Call demand update in bulk to update the interest or penalty
			if(!isGetPenaltyEstimate) {
				if(demandsToBeUpdated.size() > 0) {
					DemandRequest request = DemandRequest.builder().demands(demandsToBeUpdated).requestInfo(requestInfo).build();
					repository.fetchResult(utils.getUpdateDemandUrl(), request);
					return res.getDemands();
				}
				
			}
		}
		return demandResponse;

	}

	/**
	 * Updates demand for the given list of calculations
	 * 
	 * @param requestInfo  The RequestInfo of the calculation request
	 * @param calculations List of calculation object
	 * @return Demands that are updated
	 */
	private List<Demand> updateDemandForCalculation(RequestInfo requestInfo, List<Calculation> calculations,
			Long fromDate, Long toDate, boolean isForConnectionNo) {
		List<Demand> demands = new LinkedList<>();

		List<Demand> finalDemandRes = new ArrayList<>();
		DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("d/MM/uuuu");
		LocalDate firstDate = Instant.ofEpochMilli(fromDate).atZone(ZoneId.systemDefault()).toLocalDate();
		LocalDate lastDate = Instant.ofEpochMilli(toDate).atZone(ZoneId.systemDefault()).toLocalDate();

		String billCycle = firstDate.format(dateTimeFormatter) + " - " +lastDate.format(dateTimeFormatter);
		
		
		Long fromDateSearch = fromDate; // isForConnectionNo ? fromDate : null;
		Long toDateSearch = toDate; // isForConnectionNo ? toDate : null;
		for (Calculation calculation : calculations) {
			List<Demand> demandRes = null;
			Set<String> consumerCodes = Collections.singleton(calculation.getWaterConnection().getConnectionNo());
			List<Demand> searchResult = searchDemand(calculation.getTenantId(), consumerCodes, fromDateSearch,
					toDateSearch, requestInfo, "ACTIVE");
			if (CollectionUtils.isEmpty(searchResult))
				throw new CustomException("INVALID_DEMAND_UPDATE",
						"No demand exists for Number: " + consumerCodes.toString());
			Demand demand = searchResult.get(0);
			demand.setDemandDetails(getUpdatedDemandDetails(calculation, demand.getDemandDetails()));
			String businessService = configs.getBusinessService();
			WaterConnectionRequest waterConnectionRequest = WaterConnectionRequest.builder()
					.waterConnection(calculation.getWaterConnection()).requestInfo(requestInfo).build();
			Property property = wsCalculationUtil.getProperty(waterConnectionRequest);
			String tenantId = calculation.getTenantId();
			User owner = property.getOwners().get(0).toCommonUser();
			if (!CollectionUtils.isEmpty(waterConnectionRequest.getWaterConnection().getConnectionHolders())) {
				owner = waterConnectionRequest.getWaterConnection().getConnectionHolders().get(0).toCommonUser();
			}

			List<DemandDetail> demandDetails = new LinkedList<>();
			calculation.getTaxHeadEstimates().forEach(taxHeadEstimate -> {
				demandDetails.add(DemandDetail.builder().taxAmount(taxHeadEstimate.getEstimateAmount())
						.taxHeadMasterCode(taxHeadEstimate.getTaxHeadCode()).collectionAmount(BigDecimal.ZERO)
						.tenantId(calculation.getTenantId()).build());
			});
			demands.add(demand);
			demandRes = demandRepository.updateDemand(requestInfo, demands);
			finalDemandRes.addAll(demandRes);
			List<String> billNumbers = fetchBill(demands, waterConnectionRequest.getRequestInfo());
			Long billDate = fetchBillDate(demands,waterConnectionRequest.getRequestInfo());
			billDate =billDate + 1296000000l;
			LocalDate billDateLocal = Instant.ofEpochMilli(billDate).atZone(ZoneId.systemDefault()).toLocalDate();
			String paymentDueDate = billDateLocal.format(dateTimeFormatter);
			/*if(isOnlinePaymentAllowed(requestInfo,tenantId)) {
				if(fetchTotalBillAmount(demands,requestInfo).signum()> 0) {
					sendPaymentSMSNotification(requestInfo,tenantId,owner,waterConnectionRequest,property,demandDetails,calculation.getConnectionNo(),demands,true,businessService,billCycle,billNumbers,paymentDueDate);
					//sendPaymentAndBillSMSNotification(requestInfo,tenantId,owner,waterConnectionRequest,property,demandDetails,consumerCode,demands,true,businessService,billCycle,billNumbers,paymentDueDate);
				}
			}*/
			//sendDownloadBillSMSNotification(requestInfo,tenantId,owner,waterConnectionRequest,property,demandDetails,calculation.getConnectionNo(),demands,true,businessService,billCycle,billNumbers,paymentDueDate);

//			Commenting to avoid sending message as new bill while updating
			
			/*HashMap<String, String> localizationMessage = util.getLocalizationMessage(requestInfo,
					WSCalculationConstant.mGram_Consumer_NewBill, calculation.getTenantId());

			String actionLink = config.getNotificationUrl()
					+ config.getBillDownloadSMSLink().replace("$mobile", owner.getMobileNumber())
							.replace("$consumerCode", waterConnectionRequest.getWaterConnection().getConnectionNo())
							.replace("$tenantId", property.getTenantId());

			if (waterConnectionRequest.getWaterConnection().getConnectionType()
					.equalsIgnoreCase(WSCalculationConstant.meteredConnectionType)) {
				actionLink = actionLink.replace("$key", "ws-bill");
			} else {
				actionLink = actionLink.replace("$key", "ws-bill-nm");
			}

			log.info("Demand Object" + demands.toString());
			List<String> billNumber = fetchBill(demands, requestInfo);
			log.info("Bill Number :: " + billNumber.toString());

			if (billNumber.size() > 0) {
				actionLink = actionLink.replace("$billNumber", billNumber.get(0));
			}
			actionLink = getShortenedUrl(actionLink);
			String messageString = localizationMessage.get(WSCalculationConstant.MSG_KEY);

			System.out.println("Localization message::" + messageString + demand);

			if (!StringUtils.isEmpty(messageString)) {
				messageString = messageString.replace("{ownername}", owner.getName());
				messageString = messageString.replace("{Period}", billCycle);
				messageString = messageString.replace("{consumerno}", calculation.getConnectionNo());
				messageString = messageString.replace("{billamount}", demandDetails.stream()
						.map(DemandDetail::getTaxAmount).reduce(BigDecimal.ZERO, BigDecimal::add).toString());
				messageString = messageString.replace("{BILL_LINK}", getShortenedUrl(actionLink));

				System.out.println("Demand genaration Message2::" + messageString);

				SMSRequest sms = SMSRequest.builder().mobileNumber(owner.getMobileNumber()).message(messageString)
						.category(Category.TRANSACTION).build();
				producer.push(config.getSmsNotifTopic(), sms);

			}*/
			 

			if (isForConnectionNo) {
				WaterConnection connection = calculation.getWaterConnection();
				if (connection == null) {
					List<WaterConnection> waterConnectionList = calculatorUtils.getWaterConnection(requestInfo,
							calculation.getConnectionNo(), calculation.getTenantId());
					int size = waterConnectionList.size();
					connection = waterConnectionList.get(size - 1);

				}

//				if(connection.getApplicationType().equalsIgnoreCase("MODIFY_WATER_CONNECTION")){
//					WaterConnectionRequest waterConnectionRequest = WaterConnectionRequest.builder().waterConnection(connection)
//							.requestInfo(requestInfo).build();
//					Property property = wsCalculationUtil.getProperty(waterConnectionRequest);
//					User owner = property.getOwners().get(0).toCommonUser();
//					if (!CollectionUtils.isEmpty(waterConnectionRequest.getWaterConnection().getConnectionHolders())) {
//						owner = waterConnectionRequest.getWaterConnection().getConnectionHolders().get(0).toCommonUser();
//					}
//					if(!(demand.getPayer().getUuid().equalsIgnoreCase(owner.getUuid())))
//						demand.setPayer(owner);
//				}

			}

		}

		log.info("Updated Demand Details " + demands.toString());
		//return demandRepository.updateDemand(requestInfo, demands);
		return finalDemandRes;
	}

	/**
	 * Applies Penalty/Rebate/Interest to the incoming demands
	 * 
	 * If applied already then the demand details will be updated
	 * 
	 * @param demand                      - Demand Object
	 * @param requestInfoWrapper          RequestInfoWrapper Object
	 * @param timeBasedExemptionMasterMap - List of TimeBasedExemption details
	 * @param taxPeriods                  - List of tax periods
	 * @return Returns TRUE if successful, FALSE otherwise
	 */

	private boolean applyTimeBasedApplicables(Demand demand, RequestInfoWrapper requestInfoWrapper,
			Map<String, JSONArray> timeBasedExemptionMasterMap, List<TaxPeriod> taxPeriods,
			boolean isGetPenaltyEstimate, BigDecimal previousDemandTaxAmounts,Map<String, Object> penaltyMaster, int demandListSize) {

		String tenantId = demand.getTenantId();
		String demandId = demand.getId();
		Long expiryDate = demand.getBillExpiryTime();
		TaxPeriod taxPeriod = taxPeriods.stream().filter(t -> demand.getTaxPeriodFrom().compareTo(t.getFromDate()) >= 0
				&& demand.getTaxPeriodTo().compareTo(t.getToDate()) <= 0).findAny().orElse(null);

		if (taxPeriod == null) {
			log.info("Demand Expired!! ->> Consumer Code " + demand.getConsumerCode() + " Demand Id -->> "
					+ demand.getId());
			return false;
		}
		boolean isCurrentDemand = false;
		if (!(taxPeriod.getFromDate() <= System.currentTimeMillis()
				&& taxPeriod.getToDate() >= System.currentTimeMillis()))
			isCurrentDemand = true;

		if (expiryDate < System.currentTimeMillis() || isGetPenaltyEstimate) {
			BigDecimal waterChargeApplicable = BigDecimal.ZERO;
			BigDecimal oldPenalty = BigDecimal.ZERO;

//			BigDecimal oldInterest = BigDecimal.ZERO;

			
			for (DemandDetail detail : demand.getDemandDetails()) {
				if (WSCalculationConstant.TAX_APPLICABLE.contains(detail.getTaxHeadMasterCode())) {
					waterChargeApplicable = waterChargeApplicable.add(detail.getTaxAmount()).subtract(detail.getCollectionAmount());
				}
				if (detail.getTaxHeadMasterCode().equalsIgnoreCase(WSCalculationConstant.WS_TIME_PENALTY)) {
					oldPenalty = oldPenalty.add(detail.getTaxAmount()).subtract(detail.getCollectionAmount());
					waterChargeApplicable = waterChargeApplicable.add(oldPenalty);
				}
//				if (detail.getTaxHeadMasterCode().equalsIgnoreCase(WSCalculationConstant.WS_TIME_INTEREST)) {
//					oldInterest = oldInterest.add(detail.getTaxAmount());
//				}
			}
			waterChargeApplicable = waterChargeApplicable.add(previousDemandTaxAmounts);
			DemandDetailAndCollection latestPenaltyDemandDetail, latestInterestDemandDetail;

			boolean isPenaltyUpdated = false;
//			boolean isInterestUpdated = false;

			List<DemandDetail> details = demand.getDemandDetails();
			
			

			Map<String, BigDecimal> interestPenaltyEstimates = payService.applyPenaltyRebateAndInterest(
					waterChargeApplicable, taxPeriod.getFinancialYear(), penaltyMaster, expiryDate,isGetPenaltyEstimate,demandListSize);
			if (null == interestPenaltyEstimates)
				return isCurrentDemand;
			
			BigDecimal penalty = interestPenaltyEstimates.get(WSCalculationConstant.WS_TIME_PENALTY);

//			BigDecimal interest = interestPenaltyEstimates.get(WSCalculationConstant.WS_TIME_INTEREST);
			if (penalty == null)
				penalty = BigDecimal.ZERO;
//			if (interest == null)
//				interest = BigDecimal.ZERO;

			
//			if (interest.compareTo(BigDecimal.ZERO) != 0) {
//				latestInterestDemandDetail = utils
//						.getLatestDemandDetailByTaxHead(WSCalculationConstant.WS_TIME_INTEREST, details);
//				if (latestInterestDemandDetail != null) {
//					updateTaxAmount(interest, latestInterestDemandDetail);
//					isInterestUpdated = true;
//				}
//			}

			if (penalty.compareTo(BigDecimal.ZERO) != 0 ) {
				latestPenaltyDemandDetail = utils.getLatestDemandDetailByTaxHead(WSCalculationConstant.WS_TIME_PENALTY,
						details);
				if(latestPenaltyDemandDetail !=null) {
					updateTaxAmount(penalty, latestPenaltyDemandDetail);
					isPenaltyUpdated = true;
				}
					
			}

			if (!isPenaltyUpdated && penalty.compareTo(BigDecimal.ZERO) > 0)
				details.add(DemandDetail.builder().taxAmount(penalty.setScale(2, 2).setScale(0, RoundingMode.HALF_UP))
						.taxHeadMasterCode(WSCalculationConstant.WS_TIME_PENALTY).demandId(demandId).tenantId(tenantId)
						.build());
//			if (!isInterestUpdated && interest.compareTo(BigDecimal.ZERO) > 0)
//				details.add(DemandDetail.builder().taxAmount(interest.setScale(2, 2))
//						.taxHeadMasterCode(WSCalculationConstant.WS_TIME_INTEREST).demandId(demandId).tenantId(tenantId)
//						.build());
		}

		return isCurrentDemand;
	}

	/**
	 * Updates the amount in the latest demandDetail by adding the diff between new
	 * and old amounts to it
	 * 
	 * @param newAmount        The new tax amount for the taxHead
	 * @param latestDetailInfo The latest demandDetail for the particular taxHead
	 */
	private void updateTaxAmount(BigDecimal newAmount, DemandDetailAndCollection latestDetailInfo) {
//		BigDecimal diff = newAmount.subtract(latestDetailInfo.getTaxAmountForTaxHead());
		BigDecimal newTaxAmountForLatestDemandDetail = BigDecimal.ZERO;
		newTaxAmountForLatestDemandDetail = newAmount;
		latestDetailInfo.getLatestDemandDetail().setTaxAmount(newTaxAmountForLatestDemandDetail);
	}

	/**
	 * 
	 * @param tenantId TenantId for getting master data.
	 *//*
		 * public void generateDemandForTenantId(String tenantId, RequestInfo
		 * requestInfo) { requestInfo.getUserInfo().setTenantId(tenantId); Map<String,
		 * Object> billingMasterData =
		 * calculatorUtils.loadBillingFrequencyMasterData(requestInfo, tenantId);
		 * generateDemandForULB(billingMasterData, requestInfo, tenantId); }
		 */
	/**
	 * 
	 * @param tenantId TenantId for getting master data.
	 */
	public void generateBulkDemandForTenantId(BulkDemand bulkDemand) {
		RequestInfo requestInfo = bulkDemand.getRequestInfo();
		String tenantId = bulkDemand.getTenantId();
		requestInfo.getUserInfo().setTenantId(tenantId);
		Map<String, Object> billingMasterData = calculatorUtils.loadBillingFrequencyMasterData(requestInfo, tenantId);

		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("d/MM/yyyy");

		LocalDate fromDate = LocalDate.parse(bulkDemand.getBillingPeriod().split("-")[0].trim(), formatter);
		LocalDate toDate = LocalDate.parse(bulkDemand.getBillingPeriod().split("-")[1].trim(), formatter);
		if(fromDate.isAfter(LocalDate.now().minusMonths(1))) {
			throw new CustomException("INVALID_BILLING_CYCLE",
					"Cannot generate demands for future months");
		}
			
		Long dayStartTime = LocalDateTime.of(fromDate.getYear(), fromDate.getMonth(), fromDate.getDayOfMonth(), 0, 0, 0)
				.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		Long dayEndTime = LocalDateTime.of(toDate.getYear(), toDate.getMonth(), toDate.getDayOfMonth(), 23, 59, 59, 999000000)
				.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();

		List<String> connectionNos = waterCalculatorDao.getNonMeterConnectionsList(tenantId, dayStartTime, dayEndTime);;
		Set<String> connectionSet = connectionNos.stream().collect(Collectors.toSet());

		
		if( connectionNos.size() == 0) {
			List<String> allConnections = waterCalculatorDao.searchConnectionNos(WSCalculationConstant.nonMeterdConnection, tenantId);
			throw new CustomException("NO_CONNECTIONS_TO_GENERATE_DEMANDS",
					"Zero Demands Generated Successfully, "+ allConnections.size() +" connections already have demands in this billing cycle!");
		}

		wsCalculationValidator.validateBulkDemandBillingPeriod(dayStartTime, dayEndTime, connectionSet,
				bulkDemand.getTenantId(), (String) billingMasterData.get(WSCalculationConstant.Billing_Cycle_String));

		HashMap<Object, Object> demandData = new HashMap<Object, Object>();
		demandData.put("billingMasterData", billingMasterData);
		demandData.put("bulkDemand", bulkDemand);
		producer.push(config.getGenerateBulkDemandTopic(), demandData);
//		generateBulkDemandForULB(billingMasterData, bulkDemand);
	}

	private String formatDemandMessage(RequestInfo requestInfo, String tenantId, String string) {
		// TODO Auto-generated method stub
		return null;
	}

	private Recipient getRecepient(RequestInfo requestInfo, String tenantId) {
		Recipient recepient = null;
		UserDetailResponse userDetailResponse = userService.getUserByRoleCodes(requestInfo, Arrays.asList("GP_ADMIN"),
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

	private int getBillingCycleMiddleDay(String billingFrequency) {
		if (billingFrequency.equalsIgnoreCase(WSCalculationConstant.Monthly_Billing_Period)) {
			return 15;
		} else if (billingFrequency.equalsIgnoreCase(WSCalculationConstant.Quaterly_Billing_Period)) {
			return 80;
		}
		return 0;
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

	public List<String> fetchBill(List<Demand> demandResponse, RequestInfo requestInfo) {
		boolean notificationSent = false;
		List<String> billNumber = new ArrayList<>();
		for (Demand demand : demandResponse) {
			try {
				Object result = serviceRequestRepository.fetchResult(
						calculatorUtils.getFetchBillURL(demand.getTenantId(), demand.getConsumerCode()),
						RequestInfoWrapper.builder().requestInfo(requestInfo).build());
				billNumber = JsonPath.read(result, "$.Bill.*.billNumber");
				HashMap<String, Object> billResponse = new HashMap<>();

				billResponse.put("requestInfo", requestInfo);
				billResponse.put("billResponse", result);
				wsCalculationProducer.push(configs.getPayTriggers(), billResponse);
				notificationSent = true;
			} catch (Exception ex) {
				log.error("Fetch Bill Error", ex);
			}
		}
		return billNumber;
	}

	public Long fetchBillDate(List<Demand> demandResponse, RequestInfo requestInfo) {
		List<Long> billDate = null;
		for (Demand demand : demandResponse) {
			try {
				Object result = serviceRequestRepository.fetchResult(
						calculatorUtils.getFetchBillURL(demand.getTenantId(), demand.getConsumerCode()),
						RequestInfoWrapper.builder().requestInfo(requestInfo).build());
				billDate = JsonPath.read(result, "$.Bill.*.billDate");


			} catch (Exception ex) {
				log.error("Fetch Bill Error", ex);
			}
		}
		return billDate.get(0);
	}

	/**
	 * compare and update the demand details
	 * 
	 * @param calculation   - Calculation object
	 * @param demandDetails - List Of Demand Details
	 * @return combined demand details list
	 */
	private List<DemandDetail> getUpdatedAdhocTax(Calculation calculation, List<DemandDetail> demandDetails) {

		List<DemandDetail> newDemandDetails = new ArrayList<>();
		Map<String, List<DemandDetail>> taxHeadToDemandDetail = new HashMap<>();

		demandDetails.forEach(demandDetail -> {
			if (!taxHeadToDemandDetail.containsKey(demandDetail.getTaxHeadMasterCode())) {
				List<DemandDetail> demandDetailList = new LinkedList<>();
				demandDetailList.add(demandDetail);
				taxHeadToDemandDetail.put(demandDetail.getTaxHeadMasterCode(), demandDetailList);
			} else
				taxHeadToDemandDetail.get(demandDetail.getTaxHeadMasterCode()).add(demandDetail);
		});

		BigDecimal diffInTaxAmount;
		List<DemandDetail> demandDetailList;
		BigDecimal total;

		for (TaxHeadEstimate taxHeadEstimate : calculation.getTaxHeadEstimates()) {
			if (!taxHeadToDemandDetail.containsKey(taxHeadEstimate.getTaxHeadCode()))
				newDemandDetails.add(DemandDetail.builder().taxAmount(taxHeadEstimate.getEstimateAmount())
						.taxHeadMasterCode(taxHeadEstimate.getTaxHeadCode()).tenantId(calculation.getTenantId())
						.collectionAmount(BigDecimal.ZERO).build());
			else {
				demandDetailList = taxHeadToDemandDetail.get(taxHeadEstimate.getTaxHeadCode());
				total = demandDetailList.stream().map(DemandDetail::getTaxAmount).reduce(BigDecimal.ZERO,
						BigDecimal::add);
				diffInTaxAmount = taxHeadEstimate.getEstimateAmount().subtract(total);
				if (diffInTaxAmount.compareTo(BigDecimal.ZERO) != 0) {
					newDemandDetails.add(DemandDetail.builder().taxAmount(diffInTaxAmount)
							.taxHeadMasterCode(taxHeadEstimate.getTaxHeadCode()).tenantId(calculation.getTenantId())
							.collectionAmount(BigDecimal.ZERO).build());
				}
			}
		}
		List<DemandDetail> combinedBillDetails = new LinkedList<>(demandDetails);
		combinedBillDetails.addAll(newDemandDetails);
		addRoundOffTaxHead(calculation.getTenantId(), combinedBillDetails);
		return combinedBillDetails;
	}

	/**
	 * Search demand based on demand id and updated the tax heads with new adhoc tax
	 * heads
	 * 
	 * @param requestInfo  - Request Info Object
	 * @param calculations - List of Calculation to update the Demand
	 * @return List of calculation
	 */
	public List<Calculation> updateDemandForAdhocTax(RequestInfo requestInfo, List<Calculation> calculations) {
		List<Demand> demands = new LinkedList<>();
		for (Calculation calculation : calculations) {
			String consumerCode = calculation.getConnectionNo();
			List<Demand> searchResult = searchDemandBasedOnConsumerCode(calculation.getTenantId(), consumerCode,
					requestInfo);
			if (CollectionUtils.isEmpty(searchResult))
				throw new CustomException("INVALID_DEMAND_UPDATE", "No demand exists for Number: " + consumerCode);

			Collections.sort(searchResult, new Comparator<Demand>() {
				@Override
				public int compare(Demand d1, Demand d2) {
					return d1.getTaxPeriodFrom().compareTo(d2.getTaxPeriodFrom());
				}
			});

			Demand demand = searchResult.get(0);
			demand.setDemandDetails(getUpdatedAdhocTax(calculation, demand.getDemandDetails()));
			demands.add(demand);
		}

		log.info("Updated Demand Details " + demands.toString());
		demandRepository.updateDemand(requestInfo, demands);
		return calculations;
	}

	public DemandPenaltyResponse getPenaltyDetails(@Valid GetBillCriteria getBillCriteria,
			@Valid RequestInfoWrapper requestInfoWrapper) {
		List<Demand> demands = updateDemands(getBillCriteria, requestInfoWrapper);
		BigDecimal totalApplicablePenalty = BigDecimal.ZERO;
		for(Demand demand: demands) {
			for(DemandDetail demanddetail: demand.getDemandDetails()) {
				if(demanddetail.getTaxHeadMasterCode().equalsIgnoreCase(WSCalculationConstant.WS_TIME_PENALTY)) {
					totalApplicablePenalty = totalApplicablePenalty.add(demanddetail.getTaxAmount()).subtract(demanddetail.getCollectionAmount());
					}
			}
		}
		demands.stream().filter(i->i.getStatus().equals(Demand.StatusEnum.ACTIVE));
		DemandPenaltyResponse response = DemandPenaltyResponse.builder().totalApplicablePenalty(totalApplicablePenalty).
				demands(demands).build();
		return response;
	}
	public boolean isOnlinePaymentAllowed(RequestInfo requestInfo, String tenantId)
	{
		log.info("inside online payment allowed method");
		List<MasterDetail> masterDetails = new ArrayList<>();
		MasterDetail masterDetail =new MasterDetail("BusinessService",WSCalculationConstant.FILTER_PAYMENT_METHOD_SEARCH);
		masterDetails.add(masterDetail);
		ModuleDetail moduleDetail = ModuleDetail.builder().moduleName("BillingService").masterDetails(masterDetails).build();
		List<ModuleDetail> moduleDetails = new ArrayList<>();
		moduleDetails.add(moduleDetail);
        MdmsCriteria mdmsCriteria = MdmsCriteria.builder().tenantId(tenantId)
				.moduleDetails(moduleDetails)
				.build();
		log.info("mdmscrtiteria:::"+mdmsCriteria.getTenantId());
		log.info("mdmscrtiteria::::::"+mdmsCriteria.getModuleDetails().get(0).getModuleName());
		log.info("mdmscrtiteria:::::::::"+mdmsCriteria.getModuleDetails().get(0));
		Map<String, Object> paymentMasterData = calculatorUtils.getAllowedPaymentForTenantId(tenantId,mdmsCriteria,requestInfo);
		List<String> paymentModesNotAllowed = (List<String>) paymentMasterData.get(WSCalculationConstant.Payment_Modes_Not_Allowed);
		log.info("size::" +paymentModesNotAllowed.size());
		if(paymentModesNotAllowed.contains("ONLINE"))
			return false;
		else
			return true;
	}

}
