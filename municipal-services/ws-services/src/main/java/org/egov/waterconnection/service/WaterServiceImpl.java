package org.egov.waterconnection.service;

import static org.egov.waterconnection.constants.WCConstants.APPROVE_CONNECTION;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import jakarta.validation.Valid;

import org.egov.common.contract.request.RequestInfo;
import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.config.WSConfiguration;
import org.egov.waterconnection.constants.WCConstants;
import org.egov.waterconnection.producer.WaterConnectionProducer;
import org.egov.waterconnection.repository.ElasticSearchRepository;
import org.egov.waterconnection.repository.WaterDaoImpl;
import org.egov.waterconnection.repository.WaterRepository;
import org.egov.waterconnection.util.WaterServicesUtil;
import org.egov.waterconnection.validator.ActionValidator;
import org.egov.waterconnection.validator.MDMSValidator;
import org.egov.waterconnection.validator.ValidateProperty;
import org.egov.waterconnection.validator.WaterConnectionValidator;
import org.egov.waterconnection.web.models.*;
import org.egov.waterconnection.web.models.Connection.StatusEnum;
import org.egov.waterconnection.web.models.workflow.BusinessService;
import org.egov.waterconnection.workflow.WorkflowIntegrator;
import org.egov.waterconnection.workflow.WorkflowService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonMappingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.jayway.jsonpath.JsonPath;

@Component
public class WaterServiceImpl implements WaterService {


	/*@Autowired
	@Lazy
	private WaterDao waterDao;*/

	@Autowired
	@Lazy
	private WaterDaoImpl waterDaoImpl;

	@Autowired
	private WaterConnectionValidator waterConnectionValidator;

	@Autowired
	private ValidateProperty validateProperty;

	@Autowired
	private MDMSValidator mDMSValidator;

	@Autowired
	private EnrichmentService enrichmentService;

	@Autowired
	private WorkflowIntegrator wfIntegrator;

	@Autowired
	private WSConfiguration config;

	@Autowired
	private WorkflowService workflowService;

	@Autowired
	private ActionValidator actionValidator;

	@Autowired
	private WaterServicesUtil waterServiceUtil;

	@Autowired
	private CalculationService calculationService;


	@Autowired
	private UserService userService;

	@Autowired
	private WaterServicesUtil wsUtil;

	@Autowired
	private WaterConnectionProducer waterConnectionProducer;

	@Autowired
	@Lazy
	private WaterRepository repository;

	@Autowired
	private ElasticSearchRepository elasticSearchRepository;

	/**
	 *
	 * @param waterConnectionRequest WaterConnectionRequest contains water
	 *                               connection to be created
	 * @return List of WaterConnection after create
	 */
	@Override
	public List<WaterConnection> createWaterConnection(WaterConnectionRequest waterConnectionRequest) {
		waterConnectionRequest.getWaterConnection().getConnectionHolders().get(0).setName(waterConnectionRequest.getWaterConnection().getConnectionHolders().get(0).getName().trim());
		int reqType = WCConstants.CREATE_APPLICATION;
		if (wsUtil.isModifyConnectionRequest(waterConnectionRequest)) {
			List<WaterConnection> previousConnectionsList = getAllWaterApplications(waterConnectionRequest);

			// Validate any process Instance exists with WF
//			if (!CollectionUtils.isEmpty(previousConnectionsList)) {
//				workflowService.validateInProgressWF(previousConnectionsList, waterConnectionRequest.getRequestInfo(),
//						waterConnectionRequest.getWaterConnection().getTenantId());
//			}
			reqType = WCConstants.MODIFY_CONNECTION;
		}
		mDMSValidator.validateMISFields(waterConnectionRequest);
		waterConnectionValidator.validateWaterConnection(waterConnectionRequest, reqType);
		List<WaterConnection> waterConnection = getWaterConnectionForOldConnectionNo(waterConnectionRequest);
		if(waterConnection != null && waterConnection.size() > 0) {
			throw new CustomException("DUPLICATE_OLD_CONNECTION_NUMBER",
					"Duplicate Old connection number");
		}
		Property property = validateProperty.getOrValidateProperty(waterConnectionRequest);
		validateProperty.validatePropertyFields(property, waterConnectionRequest.getRequestInfo());
		mDMSValidator.validateMasterForCreateRequest(waterConnectionRequest);
		enrichmentService.enrichWaterConnection(waterConnectionRequest, reqType);
		System.out.println("creating user");
		userService.createUser(waterConnectionRequest);
		System.out.println("created user   " + config.getIsExternalWorkFlowEnabled());
		// call work-flow
		if (config.getIsExternalWorkFlowEnabled() != null && config.getIsExternalWorkFlowEnabled())
			wfIntegrator.callWorkFlow(waterConnectionRequest, property);
		System.out.println("calling save user   ");

		enrichmentService.postStatusEnrichment(waterConnectionRequest);
		waterDaoImpl.saveWaterConnection(waterConnectionRequest);

		if (null != waterConnectionRequest.getWaterConnection() && null != waterConnectionRequest.getWaterConnection().getPaymentType()
				&& WCConstants.PAYMENT_TYPE_ARREARS.equalsIgnoreCase(waterConnectionRequest.getWaterConnection().getPaymentType())) {
			if ((waterConnectionRequest.getWaterConnection().getArrears() != null
					&& waterConnectionRequest.getWaterConnection().getArrears().intValue() > 0)
					|| (waterConnectionRequest.getWaterConnection().getPenalty() != null
					&& waterConnectionRequest.getWaterConnection().getPenalty().intValue() > 0)) {
				calculationService.calculateFeeAndGenerateDemand(waterConnectionRequest, property, false);
			}

		} else if (null != waterConnectionRequest.getWaterConnection() && null != waterConnectionRequest.getWaterConnection().getPaymentType()
				&& WCConstants.PAYMENT_TYPE_ADVANCE.equalsIgnoreCase(waterConnectionRequest.getWaterConnection().getPaymentType())) {
			if (waterConnectionRequest.getWaterConnection().getAdvance() != null) {
				calculationService.calculateFeeAndGenerateDemand(waterConnectionRequest, property, true);
			}
		}



		return Arrays.asList(waterConnectionRequest.getWaterConnection());
	}

	/**
	 *
	 * @param criteria    WaterConnectionSearchCriteria contains search criteria on
	 *                    water connection
	 * @param requestInfo
	 * @return List of matching water connection
	 */
	public WaterConnectionResponse search(SearchCriteria criteria, RequestInfo requestInfo) {
		WaterConnectionResponse waterConnection = getWaterConnectionsList(criteria, requestInfo);
		if (!StringUtils.isEmpty(criteria.getSearchType())
				&& criteria.getSearchType().equals(WCConstants.SEARCH_TYPE_CONNECTION)) {
			waterConnection
					.setWaterConnection(enrichmentService.filterConnections(waterConnection.getWaterConnection()));
			if (criteria.getIsPropertyDetailsRequired()) {
				waterConnection.setWaterConnection(enrichmentService
						.enrichPropertyDetails(waterConnection.getWaterConnection(), criteria, requestInfo));

			}
		}
		waterConnectionValidator.validatePropertyForConnection(waterConnection.getWaterConnection());
		enrichmentService.enrichConnectionHolderDeatils(waterConnection.getWaterConnection(), criteria, requestInfo);
		return waterConnection;
	}

	/**
	 *
	 * @param criteria    WaterConnectionSearchCriteria contains search criteria on
	 *                    water connection
	 * @param requestInfo
	 * @return List of matching water connection
	 */
	public WaterConnectionResponse getWaterConnectionsList(SearchCriteria criteria, RequestInfo requestInfo) {
		return waterDaoImpl.getWaterConnectionList(criteria, requestInfo);
	}

	/**
	 *
	 * @param waterConnectionRequest WaterConnectionRequest contains water
	 *                               connection to be updated
	 * @return List of WaterConnection after update
	 */
	@Override
	public List<WaterConnection> updateWaterConnection(WaterConnectionRequest waterConnectionRequest) {
		waterConnectionRequest.getWaterConnection().getConnectionHolders().get(0).setName(waterConnectionRequest.getWaterConnection().getConnectionHolders().get(0).getName().trim());
		if (wsUtil.isModifyConnectionRequest(waterConnectionRequest)) {
			// Received request to update the connection for modifyConnection WF
			return updateWaterConnectionForModifyFlow(waterConnectionRequest);
		}
		mDMSValidator.validateMISFields(waterConnectionRequest);
		waterConnectionValidator.validateWaterConnection(waterConnectionRequest, WCConstants.UPDATE_APPLICATION);
		List<WaterConnection> waterConnection = getWaterConnectionForOldConnectionNo(waterConnectionRequest);
		if(waterConnection != null && waterConnection.size() > 0) {
			throw new CustomException("DUPLICATE_OLD_CONNECTION_NUMBER",
					"Duplicate Old connection number");
		}

		mDMSValidator.validateMasterData(waterConnectionRequest, WCConstants.UPDATE_APPLICATION);
		Property property = validateProperty.getOrValidateProperty(waterConnectionRequest);
		validateProperty.validatePropertyFields(property, waterConnectionRequest.getRequestInfo());
		BusinessService businessService = workflowService.getBusinessService(
				waterConnectionRequest.getWaterConnection().getTenantId(), waterConnectionRequest.getRequestInfo(),
				config.getBusinessServiceValue());
		WaterConnection searchResult = getConnectionForUpdateRequest(
				waterConnectionRequest.getWaterConnection().getId(), waterConnectionRequest.getRequestInfo());
		String previousApplicationStatus = workflowService.getApplicationStatus(waterConnectionRequest.getRequestInfo(),
				waterConnectionRequest.getWaterConnection().getApplicationNo(),
				waterConnectionRequest.getWaterConnection().getTenantId(), config.getBusinessServiceValue());
		enrichmentService.enrichUpdateWaterConnection(waterConnectionRequest);
		actionValidator.validateUpdateRequest(waterConnectionRequest, businessService, previousApplicationStatus);
		waterConnectionValidator.validateUpdate(waterConnectionRequest, searchResult, WCConstants.UPDATE_APPLICATION);
		userService.updateUser(waterConnectionRequest, searchResult);
		// Call workflow
//		wfIntegrator.callWorkFlow(waterConnectionRequest, property);
		// call calculator service to generate the demand for one time fee
		if (null != waterConnectionRequest.getWaterConnection() &&
				null != waterConnectionRequest.getWaterConnection().getPaymentType() &&
				WCConstants.PAYMENT_TYPE_ARREARS.equalsIgnoreCase(waterConnectionRequest.getWaterConnection().getPaymentType())) {
			if ((waterConnectionRequest.getWaterConnection().getArrears() != null
					&& waterConnectionRequest.getWaterConnection().getArrears().intValue() > 0)
					|| (waterConnectionRequest.getWaterConnection().getPenalty() != null
					&& waterConnectionRequest.getWaterConnection().getPenalty().intValue() > 0)) {
				calculationService.calculateFeeAndGenerateDemand(waterConnectionRequest, property, false);
			}
		} else if (null != waterConnectionRequest.getWaterConnection() && null != waterConnectionRequest.getWaterConnection().getPaymentType() && WCConstants.PAYMENT_TYPE_ADVANCE.
				equalsIgnoreCase(waterConnectionRequest.getWaterConnection().getPaymentType())) {
			if (waterConnectionRequest.getWaterConnection().getAdvance() != null) {
				calculationService.calculateFeeAndGenerateDemand(waterConnectionRequest, property, true);
			}
		}

		// check for edit and send edit notification
		waterDaoImpl.pushForEditNotification(waterConnectionRequest);
		// Enrich file store Id After payment
		waterDaoImpl.enrichFileStoreIds(waterConnectionRequest);
		userService.createUser(waterConnectionRequest);
		enrichmentService.postStatusEnrichment(waterConnectionRequest);
		boolean isStateUpdatable = waterServiceUtil.getStatusForUpdate(businessService, previousApplicationStatus);
		waterDaoImpl.updateWaterConnection(waterConnectionRequest, isStateUpdatable);
		postForMeterReading(waterConnectionRequest, WCConstants.UPDATE_APPLICATION);
		return Arrays.asList(waterConnectionRequest.getWaterConnection());
	}

	/**
	 * Search Water connection to be update
	 *
	 * @param id
	 * @param requestInfo
	 * @return water connection
	 */
	public WaterConnection getConnectionForUpdateRequest(String id, RequestInfo requestInfo) {
		Set<String> ids = new HashSet<>(Arrays.asList(id));
		SearchCriteria criteria = new SearchCriteria();
		criteria.setIds(ids);
		WaterConnectionResponse waterConnection = getWaterConnectionsList(criteria, requestInfo);

		if (CollectionUtils.isEmpty(waterConnection.getWaterConnection())) {
			StringBuilder builder = new StringBuilder();
			builder.append("WATER CONNECTION NOT FOUND FOR: ").append(id).append(" :ID");
			throw new CustomException("INVALID_WATERCONNECTION_SEARCH", builder.toString());
		}

		return waterConnection.getWaterConnection().get(0);
	}

	private List<WaterConnection> getAllWaterApplications(WaterConnectionRequest waterConnectionRequest) {
		SearchCriteria criteria = SearchCriteria.builder()
				.connectionNumber(waterConnectionRequest.getWaterConnection().getConnectionNo()).build();
		WaterConnectionResponse waterConnection = search(criteria, waterConnectionRequest.getRequestInfo());
		return waterConnection.getWaterConnection();
	}

	private List<WaterConnection> getWaterConnectionForOldConnectionNo(WaterConnectionRequest waterConnectionRequest) {
		SearchCriteria criteria = SearchCriteria.builder().tenantId(waterConnectionRequest.getWaterConnection().getTenantId())
				.oldConnectionNumber(waterConnectionRequest.getWaterConnection().getOldConnectionNo()).build();
		WaterConnectionResponse waterConnection = search(criteria, waterConnectionRequest.getRequestInfo());
		return waterConnection.getWaterConnection();
	}

	private List<WaterConnection> updateWaterConnectionForModifyFlow(WaterConnectionRequest waterConnectionRequest) {
		waterConnectionValidator.validateWaterConnection(waterConnectionRequest, WCConstants.MODIFY_CONNECTION);
		List<WaterConnection> waterConnection = getWaterConnectionForOldConnectionNo(waterConnectionRequest);
		if(waterConnection != null && waterConnection.size() > 0 && !waterConnectionRequest.getWaterConnection().getConnectionNo()
				.equalsIgnoreCase(waterConnection.get(0).getConnectionNo())) {
			throw new CustomException("DUPLICATE_OLD_CONNECTION_NUMBER",
					"Duplicate Old connection number");
		}
		mDMSValidator.validateMasterData(waterConnectionRequest, WCConstants.MODIFY_CONNECTION);
		BusinessService businessService = workflowService.getBusinessService(
				waterConnectionRequest.getWaterConnection().getTenantId(), waterConnectionRequest.getRequestInfo(),
				config.getModifyWSBusinessServiceName());
		WaterConnection searchResult = getConnectionForUpdateRequest(
				waterConnectionRequest.getWaterConnection().getId(), waterConnectionRequest.getRequestInfo());
		Property property = validateProperty.getOrValidateProperty(waterConnectionRequest);
		validateProperty.validatePropertyFields(property, waterConnectionRequest.getRequestInfo());
		String previousApplicationStatus = workflowService.getApplicationStatus(waterConnectionRequest.getRequestInfo(),
				waterConnectionRequest.getWaterConnection().getApplicationNo(),
				waterConnectionRequest.getWaterConnection().getTenantId(), config.getModifyWSBusinessServiceName());
		enrichmentService.enrichUpdateWaterConnection(waterConnectionRequest);
		actionValidator.validateUpdateRequest(waterConnectionRequest, businessService, previousApplicationStatus);
		userService.updateUser(waterConnectionRequest, searchResult);
		waterConnectionValidator.validateUpdate(waterConnectionRequest, searchResult, WCConstants.MODIFY_CONNECTION);
		// call calculator service to generate the demand for one time fee
		if (waterConnectionRequest.getWaterConnection().getPaymentType()!=null && waterConnectionRequest.getWaterConnection().getPaymentType()
				.equalsIgnoreCase(WCConstants.PAYMENT_TYPE_ARREARS)) {
			if ((waterConnectionRequest.getWaterConnection().getArrears() != null
					&& waterConnectionRequest.getWaterConnection().getArrears().intValue() > 0)
					|| (waterConnectionRequest.getWaterConnection().getPenalty() != null
					&& waterConnectionRequest.getWaterConnection().getPenalty().intValue() > 0)) {
				calculationService.calculateFeeAndGenerateDemand(waterConnectionRequest, property,false);
			}

		} else if (waterConnectionRequest.getWaterConnection().getPaymentType()!=null && waterConnectionRequest.getWaterConnection().getPaymentType()
				.equalsIgnoreCase(WCConstants.PAYMENT_TYPE_ADVANCE)) {
			if (waterConnectionRequest.getWaterConnection().getAdvance() != null) {
				calculationService.calculateFeeAndGenerateDemand(waterConnectionRequest, property,true);
			}
		}

//		wfIntegrator.callWorkFlow(waterConnectionRequest, property);
		boolean isStateUpdatable = waterServiceUtil.getStatusForUpdate(businessService, previousApplicationStatus);
		waterDaoImpl.updateWaterConnection(waterConnectionRequest, isStateUpdatable);

		if(waterConnectionRequest.getWaterConnection().getStatus().equals(StatusEnum.INACTIVE)) {
			waterConnectionRequest.getWaterConnection().setApplicationStatus("INACTIVE");
		}
		// setting oldApplication Flag
		markOldApplication(waterConnectionRequest);
		// check for edit and send edit notification
		waterDaoImpl.pushForEditNotification(waterConnectionRequest);
		postForMeterReading(waterConnectionRequest, WCConstants.MODIFY_CONNECTION);
		return Arrays.asList(waterConnectionRequest.getWaterConnection());
	}

	public void markOldApplication(WaterConnectionRequest waterConnectionRequest) {
		if (waterConnectionRequest.getWaterConnection().getProcessInstance().getAction()
				.equalsIgnoreCase(APPROVE_CONNECTION)) {
			String currentModifiedApplicationNo = waterConnectionRequest.getWaterConnection().getApplicationNo();
			List<WaterConnection> previousConnectionsList = getAllWaterApplications(waterConnectionRequest);

			for (WaterConnection waterConnection : previousConnectionsList) {
				if (!waterConnection.getOldApplication()
						&& !(waterConnection.getApplicationNo().equalsIgnoreCase(currentModifiedApplicationNo))) {
					waterConnection.setOldApplication(Boolean.TRUE);
					WaterConnectionRequest previousWaterConnectionRequest = WaterConnectionRequest.builder()
							.requestInfo(waterConnectionRequest.getRequestInfo()).waterConnection(waterConnection)
							.build();
					waterDaoImpl.updateWaterConnection(previousWaterConnectionRequest, Boolean.TRUE);
				}
			}
		}
	}

	@Override
	public void submitFeedback(FeedbackRequest feedbackrequest) {
		// TODO Auto-generated method stub
		mDMSValidator.validateQuestion(feedbackrequest);
		BillingCycle billingCycle = waterDaoImpl.getBillingCycle(feedbackrequest.getFeedback().getPaymentId());
		Date fromdate = new Date(billingCycle.getFromperiod());
		Date toDate = new Date(billingCycle.getToperiod());
		SimpleDateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");
		String formattedFromDate = formatter.format(fromdate);
		String formattedToDate = formatter.format(toDate);
		feedbackrequest.getFeedback().setId(UUID.randomUUID().toString());
		feedbackrequest.getFeedback().setBillingCycle(formattedFromDate + "-" + formattedToDate);

		if (feedbackrequest.getFeedback().getAuditDetails() == null) {
			AuditDetails auditDetails = new AuditDetails();
//			auditDetails.setCreatedBy(feedbackrequest.getRequestInfo().getUserInfo().getId().toString());
			auditDetails.setCreatedTime(new Date().getTime());
			auditDetails.setLastModifiedTime(new Date().getTime());
			feedbackrequest.getFeedback().setAuditDetails(auditDetails);
		}

		waterConnectionProducer.push(config.getSaveFeedback(), feedbackrequest);
	}

	@Override
	public Object getFeedback(FeedbackSearchCriteria feedbackSearchCriteria)
			throws JsonMappingException, JsonProcessingException {
		// TODO Auto-generated method stub
		List<Feedback> feedbackList = waterDaoImpl.getFeebback(feedbackSearchCriteria);

		Object data = getFeedBackRatingsAvarage(feedbackList);
		return data;
	}

	private Map<String, Integer> getFeedBackRatingsAvarage(List<Feedback> feedbackList)
			throws JsonMappingException, JsonProcessingException {

		Map<Object, Double> feedbackGroupByCode = null;
		Map<String, Integer> returnMap = new HashMap<String, Integer>();
		// TODO Auto-generated method stub
		List<CheckList> checkList = new ArrayList<CheckList>();
		ObjectMapper mapper = new ObjectMapper();
		for (Feedback feedback : feedbackList) {

			if (feedback.getAdditionalDetails() != null) {

				ObjectNode additionalDetails = (ObjectNode) feedback.getAdditionalDetails();
				if (additionalDetails.get("CheckList") != null) {
					List<CheckList> data = mapper.readValue(additionalDetails.get("CheckList").toString(),
							new TypeReference<List<CheckList>>() {
							});
					checkList.addAll(data);

				}
			}

		}

		if (checkList.size() > 0) {

			feedbackGroupByCode = checkList.stream()
					.collect(Collectors.groupingBy(e -> e.getCode(), Collectors.averagingInt(CheckList::getValue)));
		}
		if (!CollectionUtils.isEmpty(feedbackGroupByCode)) {
			for (Map.Entry<Object, Double> entry : feedbackGroupByCode.entrySet()) {
				returnMap.put(entry.getKey().toString(), entry.getValue().intValue());
			}
			returnMap.put("count", feedbackList.size());
		}

		return returnMap;
	}

	public LastMonthSummary getLastMonthSummary(SearchCriteria criteria, RequestInfo requestInfo) {

		LastMonthSummary lastMonthSummary = new LastMonthSummary();
		String tenantId = criteria.getTenantId();
		LocalDate currentMonthDate = LocalDate.now();
		if (criteria.getCurrentDate() != null) {
			Calendar currentDate = Calendar.getInstance();
			currentDate.setTimeInMillis(criteria.getCurrentDate());
			currentMonthDate = LocalDate.of(currentDate.get(Calendar.YEAR), currentDate.get(Calendar.MONTH)+1,
					currentDate.get(Calendar.DAY_OF_MONTH));
		}
		LocalDate prviousMonthStart = currentMonthDate.minusMonths(1).with(TemporalAdjusters.firstDayOfMonth());
		LocalDate prviousMonthEnd = currentMonthDate.minusMonths(1).with(TemporalAdjusters.lastDayOfMonth());

		LocalDateTime previousMonthStartDateTime = LocalDateTime.of(prviousMonthStart.getYear(),
				prviousMonthStart.getMonth(), prviousMonthStart.getDayOfMonth(), 0, 0, 0);
		LocalDateTime previousMonthEndDateTime = LocalDateTime.of(prviousMonthEnd.getYear(), prviousMonthEnd.getMonth(),
				prviousMonthEnd.getDayOfMonth(), 23, 59, 59, 999000000);

		// pending ws collectioni
		Integer cumulativePendingCollection = repository.getTotalPendingCollection(tenantId,
				((Long) previousMonthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()));
		if (null != cumulativePendingCollection)
			lastMonthSummary.setCumulativePendingCollection(cumulativePendingCollection.toString());

		// ws demands in period
		Integer newDemand = repository.getNewDemand(tenantId,
				((Long) previousMonthStartDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()),
				((Long) previousMonthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()));
		if (null != newDemand)
			lastMonthSummary.setNewDemand(newDemand.toString());

		// actuall ws collection
		Integer actualCollection = repository.getActualCollection(tenantId,
				((Long) previousMonthStartDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()),
				((Long) previousMonthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()));
		if (null != actualCollection)
			lastMonthSummary.setActualCollection(actualCollection.toString());

		lastMonthSummary.setPreviousMonthYear(getMonthYear());

		return lastMonthSummary;

	}

	public String getMonthYear() {
		LocalDateTime localDateTime = LocalDateTime.now();
		int currentMonth = localDateTime.getMonthValue();
		String monthYear;
		if (currentMonth >= Month.APRIL.getValue()) {
			monthYear = YearMonth.now().getYear() + "-";
			monthYear = monthYear
					+ (Integer.toString(YearMonth.now().getYear() + 1).substring(2, monthYear.length() - 1));
		} else {
			monthYear = YearMonth.now().getYear() - 1 + "-";
			monthYear = monthYear + (Integer.toString(YearMonth.now().getYear()).substring(2, monthYear.length() - 1));

		}
		StringBuilder monthYearBuilder = new StringBuilder(localDateTime.minusMonths(1).getMonth().toString()).append(" ")
				.append(monthYear);

		return monthYearBuilder.toString();
	}

	@Override
	public RevenueDashboard getRevenueDashboardData(@Valid SearchCriteria criteria, RequestInfo requestInfo) {
		RevenueDashboard dashboardData = new RevenueDashboard();
		String tenantId = criteria.getTenantId();
		BigDecimal demand = waterDaoImpl.getTotalDemandAmount(criteria);
		if (null != demand) {
			dashboardData.setDemand(demand.setScale(0, RoundingMode.HALF_UP).toString());
		}
		BigDecimal paidAmount = waterDaoImpl.getActualCollectionAmount(criteria);
		if (null != paidAmount) {
			dashboardData.setActualCollection(paidAmount.setScale(0, RoundingMode.HALF_UP).toString());
		}
		BigDecimal unpaidAmount = waterDaoImpl.getPendingCollectionAmount(criteria);
		if (null != unpaidAmount) {
			dashboardData.setPendingCollection(unpaidAmount.setScale(0, RoundingMode.HALF_UP).toString());
		}
		Integer residentialCollection = waterDaoImpl.getResidentialCollectionAmount(criteria);
		if (null != residentialCollection) {
			dashboardData.setResidetialColllection(residentialCollection.toString());
		}
		Integer commeritialCollection = waterDaoImpl.getCommercialCollectionAmount(criteria);
		if (null != commeritialCollection) {
			dashboardData.setComercialCollection(commeritialCollection.toString());
		}
		Integer othersCollection = waterDaoImpl.getOthersCollectionAmount(criteria);
		if (null != othersCollection) {
			dashboardData.setOthersCollection(othersCollection.toString());
		}
		Map<String, Object> residentialsPaid = waterDaoImpl.getResidentialPaid(criteria);
		if (null != residentialsPaid) {
			dashboardData.setResidentialsCount(residentialsPaid);
		}
		Map<String, Object> comercialsPaid = waterDaoImpl.getCommercialPaid(criteria);
		if (null != comercialsPaid) {
			dashboardData.setComercialsCount(comercialsPaid);
		}
		Map<String, Object> totalApplicationsPaid = waterDaoImpl.getAllPaid(criteria);
		if (null != totalApplicationsPaid) {
			dashboardData.setTotalApplicationsCount(totalApplicationsPaid);
		}
		BigDecimal advanceAdjusted = waterDaoImpl.getTotalAdvanceAdjustedAmount(criteria);
		if (null != advanceAdjusted) {
			dashboardData.setAdvanceAdjusted(advanceAdjusted.setScale(0, RoundingMode.HALF_UP).toString());
		}
		BigDecimal pendingPenalty = waterDaoImpl.getTotalPendingPenaltyAmount(criteria);
		if (null != pendingPenalty) {
			dashboardData.setPendingPenalty(pendingPenalty.setScale(0, RoundingMode.HALF_UP).toString());
		}
		BigDecimal advanceCollection = waterDaoImpl.getAdvanceCollectionAmount(criteria);
		if (null != advanceCollection) {
			dashboardData.setAdvanceCollection(advanceCollection.setScale(0, RoundingMode.HALF_UP).toString());
		}
		BigDecimal penaltyCollection = waterDaoImpl.getPenaltyCollectionAmount(criteria);
		if (null != penaltyCollection) {
			dashboardData.setPenaltyCollection(penaltyCollection.setScale(0, RoundingMode.HALF_UP).toString());
		}

		return dashboardData;

	}

	@Override
	public WaterConnectionResponse getWCListFuzzySearch(SearchCriteria criteria, RequestInfo requestInfo) {

		if(criteria!=null && criteria.getTextSearch()!=null){
			criteria.setTextSearch(criteria.getTextSearch().trim());
		}
		if(criteria!=null && criteria.getName()!=null){
			criteria.setName(criteria.getName().trim());
		}

		List<String> idsfromDB = waterDaoImpl.getWCListFuzzySearch(criteria);

		if (CollectionUtils.isEmpty(idsfromDB))
			WaterConnectionResponse.builder().waterConnection(new LinkedList<>());

		validateFuzzySearchCriteria(criteria);

		Object esResponse = elasticSearchRepository.fuzzySearchProperties(criteria, idsfromDB);

		List<Map<String, Object>> data;

		if (!StringUtils.isEmpty(criteria.getTextSearch())) {
			data = waterConnectionSearch(criteria, esResponse);
		} else {
			data = waterConnectionFuzzySearch(criteria, esResponse);
		}

		return WaterConnectionResponse.builder().waterConnectionData(data).totalCount(data.size()).build();
	}

	private List<Map<String, Object>> waterConnectionSearch(SearchCriteria criteria, Object esResponse) {
		List<Map<String, Object>> data;
		try {
			data = wsDataResponse(esResponse);
		} catch (Exception e) {
			throw new CustomException("INVALID_SEARCH_USER_PROP_NOT_FOUND",
					"Could not find user or water connection details !");
		}
		return data;
	}

	private List<Map<String, Object>> waterConnectionFuzzySearch(SearchCriteria criteria, Object esResponse) {
		List<Map<String, Object>> data;
		try {
			data = wsDataResponse(esResponse);
			if (data.isEmpty()) {
				throw new CustomException("INVALID_SEARCH_USER_PROP_NOT_FOUND",
						"Could not find user or water connection details !");

			}
		} catch (Exception e) {
			throw new CustomException("INVALID_SEARCH_USER_PROP_NOT_FOUND",
					"Could not find user or water connection details !");
		}
		return data;
	}

	private void validateFuzzySearchCriteria(SearchCriteria criteria) {
		if (org.apache.commons.lang3.StringUtils.isBlank(criteria.getTextSearch())
				&& org.apache.commons.lang3.StringUtils.isBlank(criteria.getName())
				&& org.apache.commons.lang3.StringUtils.isBlank(criteria.getMobileNumber()))
			throw new CustomException("EG_WC_SEARCH_ERROR", " No criteria given for the water connection search");
	}


	private List<Map<String, Object>> wsDataResponse(Object esResponse) {

		List<Map<String, Object>> data;
		try {
			data = JsonPath.read(esResponse, WCConstants.ES_DATA_PATH);
		} catch (Exception e) {
			throw new CustomException("PARSING_ERROR", "Failed to extract data from es response");
		}

		return data;
	}

	public WaterConnectionResponse planeSearch(SearchCriteria criteria, RequestInfo requestInfo) {
		WaterConnectionResponse waterConnection = getWaterConnectionsListForPlaneSearch(criteria, requestInfo);
		waterConnectionValidator.validatePropertyForConnection(waterConnection.getWaterConnection());
		enrichmentService.enrichConnectionHolderDeatils(waterConnection.getWaterConnection(), criteria, requestInfo);
		return waterConnection;
	}

	public WaterConnectionResponse getWaterConnectionsListForPlaneSearch(SearchCriteria criteria,
																		 RequestInfo requestInfo) {
		return waterDaoImpl.getWaterConnectionListForPlaneSearch(criteria, requestInfo);
	}

	@Override
	public List<RevenueCollectionData> getRevenueCollectionData(@Valid SearchCriteria criteria,
																RequestInfo requestInfo) {

		long endDate = criteria.getToDate();
		DateFormat formatter = new SimpleDateFormat("dd/MM/yyyy");

		LocalDate currentMonthDate = LocalDate.now();

		Calendar currentDate = Calendar.getInstance();
		int currentYear = currentDate.get(Calendar.YEAR);
		int actualMonthnum = currentDate.get(Calendar.MONTH);

		currentDate.setTimeInMillis(criteria.getFromDate());
		int actualYear = currentDate.get(Calendar.YEAR);

		int currentMonthNumber = currentDate.get(Calendar.MONTH);

		int totalMonthsTillDate;
		LocalDate finYearStarting;

		if (currentYear != actualYear && actualYear < currentYear) {
			totalMonthsTillDate = 11;
			currentMonthDate = LocalDate.of(currentDate.get(Calendar.YEAR), currentDate.get(Calendar.MONTH) + 1,
					currentDate.get(Calendar.DAY_OF_MONTH));
			finYearStarting = currentMonthDate;
		} else {
			totalMonthsTillDate = actualMonthnum - currentMonthNumber;
			currentMonthDate = LocalDate.of(currentDate.get(Calendar.YEAR), currentDate.get(Calendar.MONTH) + 1,
					currentDate.get(Calendar.DAY_OF_MONTH));
			finYearStarting = currentMonthDate;

		}
		ArrayList<RevenueCollectionData> data = new ArrayList<RevenueCollectionData>();
		for (int i = 0; i <= totalMonthsTillDate; i++) {
			LocalDate monthStart = currentMonthDate.minusMonths(0).with(TemporalAdjusters.firstDayOfMonth());
			LocalDate monthEnd = currentMonthDate.minusMonths(0).with(TemporalAdjusters.lastDayOfMonth());

			LocalDateTime monthStartDateTime = LocalDateTime.of(monthStart.getYear(), monthStart.getMonth(),
					monthStart.getDayOfMonth(), 0, 0, 0);
			LocalDateTime monthEndDateTime = LocalDateTime.of(monthEnd.getYear(), monthEnd.getMonth(),
					monthEnd.getDayOfMonth(), 23, 59, 59, 999000000);
			criteria.setFromDate((Long) monthStartDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());
			criteria.setToDate((Long) monthEndDateTime.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli());

			String tenantId = criteria.getTenantId();
			BigDecimal demand = waterDaoImpl.getTotalDemandAmount(criteria);
			RevenueCollectionData collectionData = new RevenueCollectionData();

			if (null != demand) {
				collectionData.setDemand(demand.setScale(0, RoundingMode.HALF_UP).toString());
			}
			BigDecimal paidAmount = waterDaoImpl.getActualCollectionAmount(criteria);
			if (null != paidAmount) {
				collectionData.setActualCollection(paidAmount.setScale(0, RoundingMode.HALF_UP).toString());
			}
			BigDecimal unpaidAmount = waterDaoImpl.getPendingCollectionAmount(criteria);
			if (null != unpaidAmount) {
				collectionData.setPendingCollection(unpaidAmount.setScale(0, RoundingMode.HALF_UP).toString());
			}
			BigDecimal arrears = waterDaoImpl.getArrearsAmount(criteria);
			if (null != arrears) {
				collectionData.setArrears(arrears.setScale(0, RoundingMode.HALF_UP).toString());
			}
			BigDecimal advanceAdjusted = waterDaoImpl.getTotalAdvanceAdjustedAmount(criteria);
			if (null != advanceAdjusted) {
				collectionData.setAdvanceAdjusted(advanceAdjusted.setScale(0, RoundingMode.HALF_UP).toString());
			}
			BigDecimal pendingPenalty = waterDaoImpl.getTotalPendingPenaltyAmount(criteria);
			if (null != pendingPenalty) {
				collectionData.setPendingPenalty(pendingPenalty.setScale(0, RoundingMode.HALF_UP).toString());
			}
			BigDecimal advanceCollection = waterDaoImpl.getAdvanceCollectionAmount(criteria);
			if (null != advanceCollection) {
				collectionData.setAdvanceCollection(advanceCollection.setScale(0, RoundingMode.HALF_UP).toString());
			}
			BigDecimal penaltyCollection = waterDaoImpl.getPenaltyCollectionAmount(criteria);
			if (null != penaltyCollection) {
				collectionData.setPenaltyCollection(penaltyCollection.setScale(0, RoundingMode.HALF_UP).toString());
			}

			collectionData.setMonth(criteria.getFromDate());
			data.add(i, collectionData);
			System.out.println("Month:: " + criteria.getFromDate());

			currentMonthDate = currentMonthDate.plusMonths(1);
		}
		System.out.println("datadatadatadata" + data);
		return data;
	}

	/**
	 * Create meter reading for meter connection
	 *
	 * @param waterConnectionrequest
	 */
	public void postForMeterReading(WaterConnectionRequest waterConnectionrequest, int reqType) {
		if (!StringUtils.isEmpty(waterConnectionrequest.getWaterConnection().getConnectionType())
				&& WCConstants.METERED_CONNECTION
				.equalsIgnoreCase(waterConnectionrequest.getWaterConnection().getConnectionType())) {
			if (reqType == WCConstants.UPDATE_APPLICATION && WCConstants.ACTIVATE_CONNECTION
					.equalsIgnoreCase(waterConnectionrequest.getWaterConnection().getProcessInstance().getAction())) {
				waterDaoImpl.postForMeterReading(waterConnectionrequest);
			} else if (WCConstants.MODIFY_CONNECTION == reqType && WCConstants.APPROVE_CONNECTION.
					equals(waterConnectionrequest.getWaterConnection().getProcessInstance().getAction())) {
				SearchCriteria criteria = SearchCriteria.builder()
						.tenantId(waterConnectionrequest.getWaterConnection().getTenantId())
						.connectionNumber(waterConnectionrequest.getWaterConnection().getConnectionNo()).build();
				List<WaterConnection> connections;
				WaterConnectionResponse waterConnection = search(criteria, waterConnectionrequest.getRequestInfo());
				connections = waterConnection.getWaterConnection();
				if (!CollectionUtils.isEmpty(connections)) {
					WaterConnection connection = connections.get(connections.size() - 1);
					if (!connection.getConnectionType().equals(WCConstants.METERED_CONNECTION)) {
						waterDaoImpl.postForMeterReading(waterConnectionrequest);
					}
				}
			}
		}
	}

	@Override
	public List<BillReportData> billReport(@Valid String demandStartDate, @Valid String demandEndDate, String tenantId, @Valid Integer offset, @Valid Integer limit, @Valid String sortOrder, RequestInfo requestInfo) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
		LocalDate demStartDate = LocalDate.parse(demandStartDate, formatter);
		LocalDate demEndDate = LocalDate.parse(demandEndDate, formatter);

		Long demStartDateTime = LocalDateTime.of(demStartDate.getYear(), demStartDate.getMonth(), demStartDate.getDayOfMonth(), 0, 0, 0)
				.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		Long demEndDateTime = LocalDateTime.of(demEndDate, LocalTime.MAX).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		List<BillReportData> billReportData = waterDaoImpl.getBillReportData(demStartDateTime,demEndDateTime,tenantId,offset,limit,sortOrder);
		return billReportData;
	}

	@Override
	public List<CollectionReportData> collectionReport(String paymentStartDate, String paymentEndDate, String tenantId,@Valid Integer offset, @Valid Integer limit, @Valid String sortOrder,
													   RequestInfo requestInfo) {
		DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
		LocalDate payStartDate = LocalDate.parse(paymentStartDate, formatter);
		LocalDate payEndDate = LocalDate.parse(paymentEndDate, formatter);

		Long payStartDateTime = LocalDateTime.of(payStartDate.getYear(), payStartDate.getMonth(), payStartDate.getDayOfMonth(), 0, 0, 0)
				.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		Long payEndDateTime = LocalDateTime.of(payEndDate,LocalTime.MAX).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		List<CollectionReportData> collectionReportData = waterDaoImpl.getCollectionReportData(payStartDateTime,payEndDateTime,tenantId,offset,limit,sortOrder);
		return collectionReportData;
	}

	public List<InactiveConsumerReportData> inactiveConsumerReport(String monthStartDate,String monthEndDate,String tenantId,@Valid Integer offset,@Valid Integer limit, RequestInfo requestInfo)
	{
		DateTimeFormatter formatter=DateTimeFormatter.ofPattern("dd/MM/yyyy");
		LocalDate startDate=LocalDate.parse(monthStartDate,formatter);
		LocalDate endDate=LocalDate.parse(monthEndDate,formatter);

		Long monthStartDateTime=LocalDateTime.of(startDate.getYear(),startDate.getMonth(),startDate.getDayOfMonth(),0,0,0).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		Long mothEndDateTime=LocalDateTime.of(endDate,LocalTime.MAX).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		List<InactiveConsumerReportData> inactiveConsumerReport=waterDaoImpl.getInactiveConsumerReport(monthStartDateTime,mothEndDateTime,tenantId,offset,limit);
		return inactiveConsumerReport;
	}
}