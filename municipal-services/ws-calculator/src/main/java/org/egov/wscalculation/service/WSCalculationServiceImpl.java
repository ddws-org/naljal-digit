package org.egov.wscalculation.service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

import org.egov.common.contract.request.RequestInfo;
import org.egov.common.contract.request.User;
import org.egov.mdms.model.MdmsCriteriaReq;
import org.egov.tracer.model.CustomException;
import org.egov.wscalculation.config.WSCalculationConfiguration;
import org.egov.wscalculation.constants.WSCalculationConstant;
import org.egov.wscalculation.producer.WSCalculationProducer;
import org.egov.wscalculation.web.models.*;
import org.egov.wscalculation.web.models.Demand.StatusEnum;
import org.egov.wscalculation.web.models.enums.Status;
import org.egov.wscalculation.repository.DemandRepository;
import org.egov.wscalculation.repository.ServiceRequestRepository;
import org.egov.wscalculation.repository.WSCalculationDao;
import org.egov.wscalculation.util.CalculatorUtil;
import org.egov.wscalculation.util.WSCalculationUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataRetrievalFailureException;
import org.springframework.stereotype.Service;

import com.jayway.jsonpath.JsonPath;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class WSCalculationServiceImpl implements WSCalculationService {

	@Autowired
	private PayService payService;

	@Autowired
	private EstimationService estimationService;
	
	@Autowired
	private CalculatorUtil calculatorUtil;
	
	@Autowired
	private DemandService demandService;
	
	@Autowired
	private MasterDataService masterDataService; 

	@Autowired
	private WSCalculationDao wSCalculationDao;
	
	@Autowired
	private ServiceRequestRepository repository;
	
	@Autowired
	private WSCalculationUtil wSCalculationUtil;
	
	@Autowired
	private DemandRepository demandRepository;

	@Autowired
	private WSCalculationProducer wsCalculationProducer;
	
	@Autowired
	private WSCalculationConfiguration config;

	/**
	 * Get CalculationReq and Calculate the Tax Head on Water Charge And Estimation Charge
	 */
	public List<Calculation> getCalculation(CalculationReq request) {
		List<Calculation> calculations;

		Map<String, Object> masterMap;
//		if (request.getIsconnectionCalculation()) {
		// Calculate and create demand for connection
		masterMap = masterDataService.loadMasterData(request.getRequestInfo(),
				request.getCalculationCriteria().get(0).getTenantId());
		calculations = getCalculations(request, masterMap);
//		} else {
//			//Calculate and create demand for application
//			masterMap = masterDataService.loadMasterData(request.getRequestInfo(),
//					request.getCalculationCriteria().get(0).getTenantId());
//			calculations = getCalculations(request, masterMap);
//		}
		List<WaterConnection> wsresults = calculatorUtil.getWaterConnection(request.getRequestInfo(),
				request.getCalculationCriteria().get(0).getConnectionNo(),
				request.getCalculationCriteria().get(0).getTenantId());

		//TODO need to change this to WS service.
		if (wsresults != null && wsresults.get(0).getStatus() != null
				&& wsresults.get(0).getStatus().equals(org.egov.wscalculation.web.models.Connection.StatusEnum.INACTIVE)) {
			return calculations;
		}
		boolean isWSUpdateSMS = false;
		List<Demand> searchResult = demandService.searchDemandBasedOnConsumerCode(
				request.getCalculationCriteria().get(0).getTenantId(),
				request.getCalculationCriteria().get(0).getConnectionNo(), request.getRequestInfo());
		
		if ((searchResult != null && searchResult.size() > 0
				&& searchResult.get(0).getConsumerType().equalsIgnoreCase("waterConnection-arrears")
				&& !request.getIsconnectionCalculation() && wsresults != null && wsresults.size() > 0
				&& wsresults.get(0).getPreviousReadingDate().longValue() != request.getCalculationCriteria().get(0)
						.getWaterConnection().getPreviousReadingDate().longValue())
				||
				(searchResult != null && searchResult.size() > 0
						&& searchResult.get(0).getConsumerType().equalsIgnoreCase("waterConnection-advance")
						&& !request.getIsconnectionCalculation() && wsresults != null && wsresults.size() > 0
						&& wsresults.get(0).getPreviousReadingDate().longValue() != request.getCalculationCriteria().get(0)
								.getWaterConnection().getPreviousReadingDate().longValue())) {
			searchResult.get(0).setStatus(StatusEnum.CANCELLED);
			isWSUpdateSMS = true;
			demandRepository.updateDemand(request.getRequestInfo(), searchResult);
		}
		
		

		if(request.getIsAdvanceCalculation() != null && request.getIsAdvanceCalculation().booleanValue()) {
			demandService.generateDemand(request.getRequestInfo(), calculations, masterMap,
					request.getIsconnectionCalculation(), isWSUpdateSMS, request.getIsAdvanceCalculation());
		}else {
			demandService.generateDemand(request.getRequestInfo(), calculations, masterMap,
					request.getIsconnectionCalculation(), isWSUpdateSMS, false);
		}
		unsetWaterConnection(calculations);
		return calculations;
	}
	
	
	/**
	 * 
	 * 
	 * @param request - Calculation Request Object
	 * @return List of calculation.
	 */
	public List<Calculation> bulkDemandGeneration(CalculationReq request, Map<String, Object> masterMap) {
		List<Calculation> calculations = getCalculations(request, masterMap);
		demandService.generateDemand(request.getRequestInfo(), calculations, masterMap, true, false, request.getIsAdvanceCalculation());
		return calculations;
	}

	/**
	 * 
	 * @param request - Calculation Request Object
	 * @return list of calculation based on request
	 */
	public List<Calculation> getEstimation(CalculationReq request) {
		Map<String, Object> masterData = masterDataService.loadExemptionMaster(request.getRequestInfo(),
				request.getCalculationCriteria().get(0).getTenantId());
		List<Calculation> calculations = getFeeCalculation(request, masterData);
		unsetWaterConnection(calculations);
		return calculations;
	}
	/**
	 * It will take calculation and return calculation with tax head code 
	 * 
	 * @param requestInfo Request Info Object
	 * @param criteria Calculation criteria on meter charge
	 * @param estimatesAndBillingSlabs Billing Slabs
	 * @param masterMap Master MDMS Data
	 * @return Calculation With Tax head
	 */
	public Calculation getCalculation(RequestInfo requestInfo, CalculationCriteria criteria,
			Map<String, List> estimatesAndBillingSlabs, Map<String, Object> masterMap, boolean isConnectionFee) {

		@SuppressWarnings("unchecked")
		List<TaxHeadEstimate> estimates = estimatesAndBillingSlabs.get("estimates");
		@SuppressWarnings("unchecked")
		List<String> billingSlabIds = estimatesAndBillingSlabs.get("billingSlabIds");
		WaterConnection waterConnection = criteria.getWaterConnection();
		Property property = wSCalculationUtil.getProperty(
				WaterConnectionRequest.builder().waterConnection(waterConnection).requestInfo(requestInfo).build());
		
		String tenantId = null != property.getTenantId() ? property.getTenantId() : criteria.getTenantId();

		@SuppressWarnings("unchecked")
		Map<String, TaxHeadCategory> taxHeadCategoryMap = ((List<TaxHeadMaster>) masterMap
				.get(WSCalculationConstant.TAXHEADMASTER_MASTER_KEY)).stream()
						.collect(Collectors.toMap(TaxHeadMaster::getCode, TaxHeadMaster::getCategory, (OldValue, NewValue) -> NewValue));

		BigDecimal taxAmt = BigDecimal.ZERO;
		BigDecimal waterCharge = BigDecimal.ZERO;
		BigDecimal penalty = BigDecimal.ZERO;
		BigDecimal exemption = BigDecimal.ZERO;
		BigDecimal rebate = BigDecimal.ZERO;
		BigDecimal fee = BigDecimal.ZERO;
		BigDecimal advance = BigDecimal.ZERO;


		for (TaxHeadEstimate estimate : estimates) {

			TaxHeadCategory category = taxHeadCategoryMap.get(estimate.getTaxHeadCode());
			estimate.setCategory(category);

			switch (category) {

			case CHARGES:
				waterCharge = waterCharge.add(estimate.getEstimateAmount());
				break;

			case ADVANCE_COLLECTION:
				advance = advance.add(estimate.getEstimateAmount());
				break; 
				
			case PENALTY:
				penalty = penalty.add(estimate.getEstimateAmount());
				break;

			case REBATE:
				rebate = rebate.add(estimate.getEstimateAmount());
				break;

			case EXEMPTION:
				exemption = exemption.add(estimate.getEstimateAmount());
				break;
			case FEE:
				fee = fee.add(estimate.getEstimateAmount());
				break;
			default:
				taxAmt = taxAmt.add(estimate.getEstimateAmount());
				break;
			}
		}
		TaxHeadEstimate decimalEstimate = payService.roundOfDecimals(taxAmt.add(penalty).add(waterCharge).add(fee).add(advance),
				rebate.add(exemption), isConnectionFee);
		if (null != decimalEstimate) {
			decimalEstimate.setCategory(taxHeadCategoryMap.get(decimalEstimate.getTaxHeadCode()));
			estimates.add(decimalEstimate);
			if (decimalEstimate.getEstimateAmount().compareTo(BigDecimal.ZERO) >= 0)
				taxAmt = taxAmt.add(decimalEstimate.getEstimateAmount());
			else
				rebate = rebate.add(decimalEstimate.getEstimateAmount());
		}

		BigDecimal totalAmount = taxAmt.add(penalty).add(rebate).add(exemption).add(waterCharge).add(fee).add(advance);
		return Calculation.builder().totalAmount(totalAmount).taxAmount(taxAmt).penalty(penalty).exemption(exemption)
				.charge(waterCharge).advance(advance).fee(fee).waterConnection(waterConnection).rebate(rebate).tenantId(tenantId)
				.taxHeadEstimates(estimates).billingSlabIds(billingSlabIds).connectionNo(criteria.getConnectionNo()).applicationNO(criteria.getApplicationNo())
				.build();
	}
	
	
	/**
	 * 
	 * @param request would be calculations request
	 * @param masterMap master data
	 * @return all calculations including water charge and taxhead on that
	 */
	List<Calculation> getCalculations(CalculationReq request, Map<String, Object> masterMap) {
		List<Calculation> calculations = new ArrayList<>(request.getCalculationCriteria().size());
		for (CalculationCriteria criteria : request.getCalculationCriteria()) {
			Map<String, List> estimationMap = null;
			if(request.getIsAdvanceCalculation() == null || (!request.getIsAdvanceCalculation().booleanValue())) {
				estimationMap	= estimationService.getEstimationMap(criteria, request.getRequestInfo(),
						masterMap,request.getIsconnectionCalculation(),false);
			}else {
				estimationMap   = estimationService.getEstimationMap(criteria, request.getRequestInfo(),
						masterMap,request.getIsconnectionCalculation(), request.getIsAdvanceCalculation());
			}
			 
			ArrayList<?> billingFrequencyMap = (ArrayList<?>) masterMap
					.get(WSCalculationConstant.Billing_Period_Master);
			masterDataService.enrichBillingPeriod(criteria, billingFrequencyMap, masterMap,request.getIsconnectionCalculation());
			Calculation calculation = getCalculation(request.getRequestInfo(), criteria, estimationMap, masterMap, true);
			calculations.add(calculation);
		}
		return calculations;
	}


	@Override
	public void jobScheduler() {
		// TODO Auto-generated method stub
		ArrayList<String> tenantIds = wSCalculationDao.searchTenantIds();

		for (String tenantId : tenantIds) {
			RequestInfo requestInfo = new RequestInfo();
			User user = new User();
			user.setTenantId(tenantId);
			requestInfo.setUserInfo(user);
			String jsonPath = WSCalculationConstant.JSONPATH_ROOT_FOR_BilingPeriod;
			MdmsCriteriaReq mdmsCriteriaReq = calculatorUtil.getBillingFrequency(requestInfo, tenantId);
			StringBuilder url = calculatorUtil.getMdmsSearchUrl();
			Object res = repository.fetchResult(url, mdmsCriteriaReq);
			if (res == null) {
				throw new CustomException("MDMS_ERROR_FOR_BILLING_FREQUENCY",
						"ERROR IN FETCHING THE BILLING FREQUENCY");
			}
			ArrayList<?> mdmsResponse = JsonPath.read(res, jsonPath);
			getBillingPeriod(mdmsResponse, requestInfo, tenantId);
		}
	}
	

	@SuppressWarnings("unchecked")
	public void getBillingPeriod(ArrayList<?> mdmsResponse, RequestInfo requestInfo, String tenantId) {
		log.info("Billing Frequency Map" + mdmsResponse.toString());
		Map<String, Object> master = (Map<String, Object>) mdmsResponse.get(0);
		LocalDateTime demandStartingDate = LocalDateTime.now();
		Long demandGenerateDateMillis = (Long) master.get(WSCalculationConstant.Demand_Generate_Date_String);

		String connectionType = "Non-metred";

		if (demandStartingDate.getDayOfMonth() == (demandGenerateDateMillis) / 86400) {

			ArrayList<String> connectionNos = wSCalculationDao.searchConnectionNos(connectionType, tenantId);
			for (String connectionNo : connectionNos) {

				CalculationReq calculationReq = new CalculationReq();
				CalculationCriteria calculationCriteria = new CalculationCriteria();
				calculationCriteria.setTenantId(tenantId);
				calculationCriteria.setConnectionNo(connectionNo);

				List<CalculationCriteria> calculationCriteriaList = new ArrayList<>();
				calculationCriteriaList.add(calculationCriteria);

				calculationReq.setRequestInfo(requestInfo);
				calculationReq.setCalculationCriteria(calculationCriteriaList);
				calculationReq.setIsconnectionCalculation(true);
				getCalculation(calculationReq);

			}
		}
	}

	/**
	 * Generate Demand Based on Time (Monthly, Quarterly, Yearly)
	 */
	public void generateDemandBasedOnTimePeriod(RequestInfo requestInfo, boolean isSendMessage) {
		DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
		LocalDateTime date = LocalDateTime.now();
		log.info("Time schedule start for water demand generation on : " + date.format(dateTimeFormatter));
		List<String> tenantIds = wSCalculationDao.getTenantId();
		if (tenantIds.isEmpty())
			return;
		log.info("Tenant Ids : " + tenantIds.toString());
		tenantIds.forEach(tenantId -> {
			HashMap<Object, Object> demandData = new HashMap<Object, Object>();
			demandData.put("requestInfo", requestInfo);
			demandData.put("tenantId", tenantId);
			demandData.put("isSendMessage", isSendMessage);
			wsCalculationProducer.push(config.getBulkDemandSchedularTopic(),demandData);
//			demandService.generateDemandForTenantId(tenantId, requestInfo);
		});
	}
	
	public void generateBulkDemandForTenant(BulkDemand bulkDemand) {
		String tenantId = bulkDemand.getTenantId();
		if(tenantId != null && tenantId.split("\\.").length >1) {
			demandService.generateBulkDemandForTenantId(bulkDemand);
		}else {
			throw new CustomException("INVALD_TENANT", "Cannot generate bulk dmeand for this tenant");
		}
		
	}
	/**
	 * 
	 * @param request - Calculation Request Object
	 * @param masterMap - Master MDMS Data
	 * @return list of calculation based on estimation criteria
	 */
	List<Calculation> getFeeCalculation(CalculationReq request, Map<String, Object> masterMap) {

		List<Calculation> calculations = new ArrayList<>(request.getCalculationCriteria().size());
		for (CalculationCriteria criteria : request.getCalculationCriteria()) {
			Map<String, List> estimationMap = estimationService.getEstimationMap(criteria, request.getRequestInfo(),
					masterMap,request.getIsconnectionCalculation(),false);
			ArrayList<?> billingFrequencyMap = (ArrayList<?>) masterMap
					.get(WSCalculationConstant.Billing_Period_Master);
			masterDataService.enrichBillingPeriod(criteria, billingFrequencyMap, masterMap,request.getIsconnectionCalculation());
			Calculation calculation = getCalculation(request.getRequestInfo(), criteria, estimationMap, masterMap, true);
			calculations.add(calculation);
		}
		return calculations;
		
		//		List<Calculation> calculations = new ArrayList<>(request.getCalculationCriteria().size());
//		for (CalculationCriteria criteria : request.getCalculationCriteria()) {
//			Map<String, List> estimationMap = estimationService.getFeeEstimation(criteria, request.getRequestInfo(),
//					masterMap);
//			masterDataService.enrichBillingPeriodForFee(masterMap);
//			Calculation calculation = getCalculation(request.getRequestInfo(), criteria, estimationMap, masterMap, false);
//			calculations.add(calculation);
//		}
//		return calculations;
	}
	
	public void unsetWaterConnection(List<Calculation> calculation) {
		calculation.forEach(cal -> cal.setWaterConnection(null));
	}
	
	/**
	 * Add adhoc tax to demand
	 * @param adhocTaxReq - Adhox Tax Request Object
	 * @return List of Calculation
	 */
	public List<Calculation> applyAdhocTax(AdhocTaxReq adhocTaxReq) {
		List<TaxHeadEstimate> estimates = new ArrayList<>();
		if (!(adhocTaxReq.getAdhocpenalty().compareTo(BigDecimal.ZERO) == 0))
			estimates.add(TaxHeadEstimate.builder().taxHeadCode(WSCalculationConstant.WS_TIME_ADHOC_PENALTY)
					.estimateAmount(adhocTaxReq.getAdhocpenalty().setScale(2, 2)).build());
		if (!(adhocTaxReq.getAdhocrebate().compareTo(BigDecimal.ZERO) == 0))
			estimates.add(TaxHeadEstimate.builder().taxHeadCode(WSCalculationConstant.WS_TIME_ADHOC_REBATE)
					.estimateAmount(adhocTaxReq.getAdhocrebate().setScale(2, 2).negate()).build());
		Calculation calculation = Calculation.builder()
				.tenantId(adhocTaxReq.getRequestInfo().getUserInfo().getTenantId())
				.connectionNo(adhocTaxReq.getConsumerCode()).taxHeadEstimates(estimates).build();
		List<Calculation> calculations = Collections.singletonList(calculation);
		return demandService.updateDemandForAdhocTax(adhocTaxReq.getRequestInfo(), calculations);
	}

	@Override
	public RollOutDashboard sendDataForRollOut(RollOutDashboardRequest rollOutDashboardRequest) {
		DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
		LocalDateTime date = LocalDateTime.now();
		log.info("Time schedule start for roll out dashboard on : " + date.format(dateTimeFormatter));

		try {
			String tenantId = rollOutDashboardRequest.getRollOutDashboard().getTenantid();
			if (tenantId != null) {
				rollOutDashboardRequest.getRollOutDashboard().setCreatedTime(new Date());
				log.info("Role out data sending to kafka topic "+ rollOutDashboardRequest.getRollOutDashboard());
				wsCalculationProducer.push(config.getRollOutDashBoardTopic(), rollOutDashboardRequest.getRollOutDashboard());
			}
		} catch (Exception e) {
			log.info("Exception occurred while fetching tenantId");
			throw new DataRetrievalFailureException("Data not found "+e);
		}
		return rollOutDashboardRequest.getRollOutDashboard();
	}



	
}
