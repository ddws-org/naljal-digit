/*
 * eGov suite of products aim to improve the internal efficiency,transparency,
 *    accountability and the service delivery of the government  organizations.
 *
 *     Copyright (C) <2015>  eGovernments Foundation
 *
 *     The updated version of eGov suite of products as by eGovernments Foundation
 *     is available at http://www.egovernments.org
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program. If not, see http://www.gnu.org/licenses/ or
 *     http://www.gnu.org/licenses/gpl.html .
 *
 *     In addition to the terms of the GPL license to be adhered to in using this
 *     program, the following additional terms are to be complied with:
 *
 *         1) All versions of this program, verbatim or modified must carry this
 *            Legal Notice.
 *
 *         2) Any misrepresentation of the origin of the material is prohibited. It
 *            is required that all modified versions of this material be marked in
 *            reasonable ways as different from the original version.
 *
 *         3) This license does not grant any rights to any user of the program
 *            with regards to rights under trademark law for use of the trade names
 *            or trademarks of eGovernments Foundation.
 *
 *   In case of any queries, you can reach eGovernments Foundation at contact@egovernments.org.
 */
package org.egov.demand.service;

import static org.egov.demand.util.Constants.ADVANCE_TAXHEAD_JSONPATH_CODE;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.stream.Collectors;

import javax.validation.Valid;

import org.egov.common.contract.request.RequestInfo;
import org.egov.demand.amendment.model.Amendment;
import org.egov.demand.amendment.model.AmendmentCriteria;
import org.egov.demand.amendment.model.AmendmentUpdate;
import org.egov.demand.amendment.model.enums.AmendmentStatus;
import org.egov.demand.config.ApplicationProperties;
import org.egov.demand.model.*;
import org.egov.demand.model.BillV2.BillStatus;
import org.egov.demand.producer.Producer;
import org.egov.demand.repository.AmendmentRepository;
import org.egov.demand.repository.BillRepositoryV2;
import org.egov.demand.repository.DemandRepository;
import org.egov.demand.repository.ServiceRequestRepository;
import org.egov.demand.util.DemandEnrichmentUtil;
import org.egov.demand.util.Util;
import org.egov.demand.web.contract.DemandRequest;
import org.egov.demand.web.contract.DemandResponse;
import org.egov.demand.web.contract.User;
import org.egov.demand.web.contract.UserResponse;
import org.egov.demand.web.contract.UserSearchRequest;
import org.egov.demand.web.contract.factory.ResponseFactory;
import org.egov.demand.web.validator.DemandValidatorV1;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.DocumentContext;

import lombok.extern.slf4j.Slf4j;
import org.egov.mdms.model.MasterDetail;
import org.egov.mdms.model.MdmsCriteria;
import org.egov.mdms.model.MdmsCriteriaReq;
import org.egov.mdms.model.ModuleDetail;
import static org.egov.demand.util.Constants.*;

@Service
@Slf4j
public class DemandService {

	@Autowired
	private DemandRepository demandRepository;

	@Autowired
	private ApplicationProperties applicationProperties;

	@Autowired
	private ResponseFactory responseInfoFactory;

	@Autowired
	private DemandEnrichmentUtil demandEnrichmentUtil;
	
	@Autowired
	private ServiceRequestRepository serviceRequestRepository;
	
	@Autowired
	private AmendmentRepository amendmentRepository;
	
	@Autowired
	private BillRepositoryV2 billRepoV2;
	
	@Autowired
	private ObjectMapper mapper;
	
	@Autowired
	private Util util;

	@Autowired
	private DemandValidatorV1 demandValidatorV1;

	@Autowired
	private Producer producer;
	
	/**
	 * Method to create new demand 
	 * 
	 * generates ids and saves to the repository
	 * 
	 * @param demandRequest
	 * @return
	 */
	public DemandResponse create(DemandRequest demandRequest) {

		DocumentContext mdmsData = util.getMDMSData(demandRequest.getRequestInfo(),
				demandRequest.getDemands().get(0).getTenantId());

		demandValidatorV1.validatedemandForCreate(demandRequest, true, mdmsData);

		log.info("the demand request in create async : {}", demandRequest);

		RequestInfo requestInfo = demandRequest.getRequestInfo();
		List<Demand> demands = demandRequest.getDemands();
		AuditDetails auditDetail = util.getAuditDetail(requestInfo);
		
		List<AmendmentUpdate> amendmentUpdates = consumeAmendmentIfExists(demands, auditDetail);
		generateAndSetIdsForNewDemands(demands, auditDetail);

		List<Demand> demandsToBeCreated = new ArrayList<>();
		List<Demand> demandToBeUpdated = new ArrayList<>();

		String businessService = demandRequest.getDemands().get(0).getBusinessService();
		Boolean isAdvanceAllowed = util.getIsAdvanceAllowed(businessService, mdmsData);

		if(isAdvanceAllowed){
			apportionAdvanceIfExist(demandRequest,mdmsData,demandsToBeCreated,demandToBeUpdated);
		}
		else {
			demandsToBeCreated.addAll(demandRequest.getDemands());
		}

		save(new DemandRequest(requestInfo,demandsToBeCreated));
		if (!CollectionUtils.isEmpty(amendmentUpdates))
			amendmentRepository.updateAmendment(amendmentUpdates);

		if(!CollectionUtils.isEmpty(demandToBeUpdated))
			update(new DemandRequest(requestInfo,demandToBeUpdated), null);
		
		billRepoV2.updateBillStatus(
				UpdateBillCriteria.builder()
				.statusToBeUpdated(BillStatus.EXPIRED)
				.businessService(businessService)
				.consumerCodes(demands.stream().map(Demand::getConsumerCode).collect(Collectors.toSet()))
				.tenantId(demands.get(0).getTenantId())
				.build()
				);
		return new DemandResponse(responseInfoFactory.getResponseInfo(requestInfo, HttpStatus.CREATED), demands);
	}

	/**
	 * Method to generate and set ids, Audit details to the demand 
	 * and demand-detail object
	 * 
	 */
	private void generateAndSetIdsForNewDemands(List<Demand> demands, AuditDetails auditDetail) {

		/*
		 * looping demands to set ids and collect demand details in another list
		 */
		for (Demand demand : demands) {

			String demandId = UUID.randomUUID().toString();
			String tenantId = demand.getTenantId();
			demand.setAuditDetails(auditDetail);
			demand.setId(demandId);

			for (DemandDetail demandDetail : demand.getDemandDetails()) {

				if (Objects.isNull(demandDetail.getCollectionAmount()))
					demandDetail.setCollectionAmount(BigDecimal.ZERO);
				demandDetail.setId(UUID.randomUUID().toString());
				demandDetail.setAuditDetails(auditDetail);
				demandDetail.setTenantId(tenantId);
				demandDetail.setDemandId(demandId);
			}
		}
	}

	
	/**
	 * Update method for demand flow 
	 * 
	 * updates the existing demands and inserts in case of new
	 * 
	 * @param demandRequest demand request object to be updated
	 * @return
	 */
	public DemandResponse updateAsync(DemandRequest demandRequest, PaymentBackUpdateAudit paymentBackUpdateAudit) {

		log.debug("the demand service : " + demandRequest);
		DocumentContext mdmsData = util.getMDMSData(demandRequest.getRequestInfo(),
				demandRequest.getDemands().get(0).getTenantId());

		demandValidatorV1.validateForUpdate(demandRequest, mdmsData);

		RequestInfo requestInfo = demandRequest.getRequestInfo();
		List<Demand> demands = demandRequest.getDemands();
		AuditDetails auditDetail = util.getAuditDetail(requestInfo);

		List<Demand> newDemands = new ArrayList<>();

		for (Demand demand : demands) {

			String demandId = demand.getId();

			if (StringUtils.isEmpty(demandId)) {
				/*
				 * If demand id is empty then gen new demand Id
				 */
				newDemands.add(demand);
			} else {

				demand.setAuditDetails(auditDetail);
				for (DemandDetail detail : demand.getDemandDetails()) {

					if (StringUtils.isEmpty(detail.getId())) {
						/*
						 * If id is empty for demand detail treat it as new
						 */
						detail.setId(UUID.randomUUID().toString());
						detail.setCollectionAmount(BigDecimal.ZERO);
					}
					detail.setAuditDetails(auditDetail);
					detail.setDemandId(demandId);
					detail.setTenantId(demand.getTenantId());
				}
			}
			util.updateDemandPaymentStatus(demand, null != paymentBackUpdateAudit);
		}

		generateAndSetIdsForNewDemands(newDemands, auditDetail);

		update(demandRequest, paymentBackUpdateAudit);
		if(paymentBackUpdateAudit != null){
			log.debug("Payment id after update: " + paymentBackUpdateAudit.getPaymentId());
		}
		String businessService = demands.get(0).getBusinessService();
		String tenantId = demands.get(0).getTenantId();
		
		UpdateBillCriteria updateBillCriteria = UpdateBillCriteria.builder()
				.consumerCodes(demands.stream().map(Demand::getConsumerCode).collect(Collectors.toSet()))
				.businessService(businessService)
				.tenantId(tenantId)
				.build();
		
		if (ObjectUtils.isEmpty(paymentBackUpdateAudit)) {
			
			updateBillCriteria.setStatusToBeUpdated(BillStatus.EXPIRED);
			billRepoV2.updateBillStatus(updateBillCriteria);
		} else {
			log.debug("Payment id before setting billstatus to paid : " + paymentBackUpdateAudit.getPaymentId());
			updateBillCriteria.setStatusToBeUpdated(BillStatus.PAID);
			billRepoV2.updateBillStatus(updateBillCriteria);
			log.debug("Payment id after updateBillStatus : " + paymentBackUpdateAudit.getPaymentId());

		}
		// producer.push(applicationProperties.getDemandIndexTopic(), demandRequest);
		return new DemandResponse(responseInfoFactory.getResponseInfo(requestInfo, HttpStatus.CREATED), demands);
	}

	public List<Demand> demandPlainSearch(DemandCriteria demandCriteria, RequestInfo requestInfo)
	{
		if (demandCriteria.getLimit() != null && demandCriteria.getLimit() > applicationProperties.getDemandMaxLimit())
			demandCriteria.setLimit(applicationProperties.getDemandMaxLimit());

		Set<String> demandIds = null;

		if(demandCriteria.getDemandId() != null && !CollectionUtils.isEmpty(demandCriteria.getDemandId()))
			demandIds = demandCriteria.getDemandId();
		else
			demandIds = new HashSet<>(demandRepository.getDemandIds(demandCriteria));

		if(demandIds.isEmpty())
			return Collections.emptyList();

		DemandCriteria demandSearchCriteria = DemandCriteria.builder().demandId(demandIds).build();
        return demandRepository.getDemandsPlainSearch(demandSearchCriteria);
	}

	/**
	 * Search method to fetch demands from DB
	 * 
	 * @param demandCriteria
	 * @param requestInfo
	 * @return
	 */
	public List<Demand> getDemands(DemandCriteria demandCriteria, RequestInfo requestInfo) {

		demandValidatorV1.validateDemandCriteria(demandCriteria, requestInfo);

		UserSearchRequest userSearchRequest = null;
		List<User> payers = null;
		List<Demand> demands = null;
		
		String userUri = applicationProperties.getUserServiceHostName()
				.concat(applicationProperties.getUserServiceSearchPath());
		
		/*
		 * user type is CITIZEN by default because only citizen can have demand or payer can be null
		 */
		String citizenTenantId = demandCriteria.getTenantId().split("\\.")[0];
		
		/*
		 * If payer related data is provided first then user search has to be made first followed by demand search
		 */
		if (demandCriteria.getEmail() != null || demandCriteria.getMobileNumber() != null) {
			
			userSearchRequest = UserSearchRequest.builder().requestInfo(requestInfo)
					.tenantId(citizenTenantId).emailId(demandCriteria.getEmail())
					.mobileNumber(demandCriteria.getMobileNumber()).build();
			
			payers = mapper.convertValue(serviceRequestRepository.fetchResult(userUri, userSearchRequest), UserResponse.class).getUser();
			
			if(CollectionUtils.isEmpty(payers))
				return new ArrayList<>();
			
			Set<String> ownerIds = payers.stream().map(User::getUuid).collect(Collectors.toSet());
			demandCriteria.setPayer(ownerIds);
			demands = demandRepository.getDemands(demandCriteria);
			
		} else {
			
			/*
			 * If no payer related data given then search demand first then enrich payer(user) data
			 */
			demands = demandRepository.getDemands(demandCriteria);
			if (!demands.isEmpty()) {

				Set<String> payerUuids = demands.stream().filter(demand -> null != demand.getPayer())
						.map(demand -> demand.getPayer().getUuid()).collect(Collectors.toSet());

				if (!CollectionUtils.isEmpty(payerUuids)) {

					userSearchRequest = UserSearchRequest.builder().requestInfo(requestInfo).uuid(payerUuids).build();

					payers = mapper.convertValue(serviceRequestRepository.fetchResult(userUri, userSearchRequest),
							UserResponse.class).getUser();
				}
			}
		}
		
		if (!CollectionUtils.isEmpty(demands) && !CollectionUtils.isEmpty(payers))
			demands = demandEnrichmentUtil.enrichPayer(demands, payers);

		return demands;
	}

	public void save(DemandRequest demandRequest) {
		demandRepository.save(demandRequest);
		producer.push(applicationProperties.getCreateDemandIndexTopic(), demandRequest);
	}

	public void update(DemandRequest demandRequest, PaymentBackUpdateAudit paymentBackUpdateAudit) {
		demandRepository.update(demandRequest, paymentBackUpdateAudit);
		producer.push(applicationProperties.getUpdateDemandIndexTopic(), demandRequest);
	}


	/**
	 * Calls the demand apportion API if any advance amoount is available for that comsumer code
	 * @param demandRequest The demand request for create
	 * @param mdmsData The master data for billing service
	 * @param demandToBeCreated The list which maintains the demand that has to be created in the system
	 * @param demandToBeUpdated The list which maintains the demand that has to be updated in the system
	 */
	private void apportionAdvanceIfExist(DemandRequest demandRequest, DocumentContext mdmsData,List<Demand> demandToBeCreated,List<Demand> demandToBeUpdated){
		List<Demand> demands = demandRequest.getDemands();
		RequestInfo requestInfo = demandRequest.getRequestInfo();

		for(Demand demand : demands) {
			String businessService = demand.getBusinessService();
			String consumerCode = demand.getConsumerCode();
			String tenantId = demand.getTenantId();

			// Searching demands based on consumer code of the current demand (demand which has to be created)
			DemandCriteria searchCriteria = DemandCriteria.builder().tenantId(tenantId)
					.status(Demand.StatusEnum.ACTIVE.toString()).consumerCode(Collections.singleton(consumerCode)).businessService(businessService).build();
			List<Demand> demandsFromSearch = demandRepository.getDemands(searchCriteria);

			// If no demand is found means there is no advance available. The current demand is added for creation
			if (CollectionUtils.isEmpty(demandsFromSearch)){
				demandToBeCreated.add(demand);
				continue;
			}

			// Fetch the demands containing advance amount
			List<Demand> demandsToBeApportioned = getDemandsContainingAdvance(demandsFromSearch, mdmsData);

			// If no demand is found with advance amount the code continues to next demand and adds the current demand for creation
			if(CollectionUtils.isEmpty(demandsToBeApportioned)){
				demandToBeCreated.add(demand);
				continue;
			}

			// The current demand is added to get apportioned
			demandsToBeApportioned.add(demand);

			DemandApportionRequest apportionRequest = DemandApportionRequest.builder().requestInfo(requestInfo).demands(demandsToBeApportioned).tenantId(tenantId).build();

			Object response = serviceRequestRepository.fetchResult(util.getApportionURL(), apportionRequest);
			ApportionDemandResponse apportionDemandResponse = mapper.convertValue(response, ApportionDemandResponse.class);

			// Only the current demand is to be created rest all are to be updated
			apportionDemandResponse.getDemands().forEach(demandFromResponse -> {
				if(demandFromResponse.getId().equalsIgnoreCase(demand.getId()))
					demandToBeCreated.add(demandFromResponse);
				else demandToBeUpdated.add(demandFromResponse);
			});
		}

	}


	/**
	 * Returns demands which has advance amount avaialable for apportion
	 * @param demands List of demands from which demands with advance has to be picked
	 * @param mdmsData Master Data for billing service
	 * @return
	 */
	private List<Demand> getDemandsContainingAdvance(List<Demand> demands,DocumentContext mdmsData){

		Set<Demand> demandsWithAdvance = new HashSet<>();

		// Create the jsonPath to fetch the advance taxhead for the given businessService
		String businessService = demands.get(0).getBusinessService();
		String jsonpath = ADVANCE_TAXHEAD_JSONPATH_CODE;
		jsonpath = jsonpath.replace("{}",businessService);

		// Apply the jsonPath on the master Data to fetch the value. The output will be an array with single element
		List<String> taxHeads = mdmsData.read(jsonpath);

		if(CollectionUtils.isEmpty(taxHeads))
			throw new CustomException("NO TAXHEAD FOUND","No Advance taxHead found for businessService: "+businessService);

		String advanceTaxHeadCode =  taxHeads.get(0);

		/*
		* Loop through each demand and each demandDetail to find the demandDetail for which advance amount is available
		* */

		for (Demand demand : demands){

			for(DemandDetail demandDetail : demand.getDemandDetails()){

				if(demandDetail.getTaxHeadMasterCode().equalsIgnoreCase(advanceTaxHeadCode)
						&& demandDetail.getTaxAmount().compareTo(demandDetail.getCollectionAmount()) != 0){
					demandsWithAdvance.add(demand);
					break;
				}
			}
		}

		return new ArrayList<>(demandsWithAdvance);
	}
	
	/**
	 * Method to add demand details from amendment if exists in DB
	 * @param demandRequest
	 */
	private List<AmendmentUpdate> consumeAmendmentIfExists(List<Demand> demands, AuditDetails auditDetails) {

		List<AmendmentUpdate> updateListForConsumedAmendments = new ArrayList<>();
		Set<String> consumerCodes = demands.stream().map(Demand::getConsumerCode).collect(Collectors.toSet());

		/*
		 * Search amendments for all consumer-codes and keep in map of list based on consumer-codes
		 */
		AmendmentCriteria amendmentCriteria = AmendmentCriteria.builder()
				.tenantId(demands.get(0).getTenantId())
				.status(AmendmentStatus.ACTIVE)
				.consumerCode(consumerCodes)
				.build();
		List<Amendment> amendmentsFromSearch = amendmentRepository.getAmendments(amendmentCriteria);
		Map<String, List<Amendment>> mapOfConsumerCodeAndAmendmentsList = amendmentsFromSearch.stream()
				.collect(Collectors.groupingBy(Amendment::getConsumerCode)); 
		
		/*
		 * Add demand-details in to demand from all amendments existing for that consumer-code
		 * 
		 * Add the amendment to update list for consumed
		 */
		for (Demand demand : demands) {
		
			
			List<Amendment> amendments = mapOfConsumerCodeAndAmendmentsList.get(demand.getConsumerCode());
			if (CollectionUtils.isEmpty(amendments))
				continue;
			
			for (Amendment amendment : amendments) {
				
				demand.getDemandDetails().addAll(amendment.getDemandDetails());
				
				AmendmentUpdate amendmentUpdate = AmendmentUpdate.builder()
						.additionalDetails(amendment.getAdditionalDetails())
						.amendedDemandId(demand.getId())
						.amendmentId(amendment.getAmendmentId())
						.auditDetails(auditDetails)
						.status(AmendmentStatus.CONSUMED)
						.tenantId(demand.getTenantId())
						.build();
				updateListForConsumedAmendments.add(amendmentUpdate);
			}
		}

		return updateListForConsumedAmendments;
	}

	public DemandHistory getDemandHistory(@Valid DemandCriteria demandCriteria, RequestInfo requestInfo) {
		demandValidatorV1.validateDemandCriteria(demandCriteria, requestInfo);

		List<Demand> demands = null;
		List<Demand> demandList = getDemands(demandCriteria, requestInfo);
		demands = demandRepository.getDemandHistory(demandCriteria);
		List<Demand> demList = demandList.stream().filter(i->(!i.getIsPaymentCompleted().booleanValue())).collect(Collectors.toList());
		
		BigDecimal advanceAdjustedAmount = BigDecimal.ZERO;
		BigDecimal waterCharge = demList.get(demList.size() - 1).getDemandDetails().get(0).getTaxAmount();
		for(Demand dem : demList) {
			for(DemandDetail ddl : dem.getDemandDetails()){
				if(ddl.getTaxHeadMasterCode().equalsIgnoreCase("WS_ADVANCE_CARRYFORWARD")){
					   advanceAdjustedAmount = demList.get(demList.size() - 1).getDemandDetails().get(0).getCollectionAmount();
					}
				}
		}
		if(demandList.size() == 1) {
		 waterCharge = demList.get(demList.size() - 1).getDemandDetails().get(0).getTaxAmount().
				 subtract(demList.get(demList.size() - 1).getDemandDetails().get(0).getCollectionAmount());
		}

		demands.stream().filter(i->i.getStatus().equals(Demand.StatusEnum.ACTIVE));
		DemandHistory demandHistory = new DemandHistory();
		demandHistory.setDemandList(demands);
		demandHistory.setWaterCharge(waterCharge);
		demandHistory.setAdvanceAdjustedAmount(advanceAdjustedAmount);
		return demandHistory;
	
	}
	public AggregatedDemandDetailResponse getAllDemands(DemandCriteria demandCriteria, RequestInfo requestInfo) {

		//demandValidatorV1.validateDemandCriteria(demandCriteria, requestInfo);
		long latestDemandCreatedTime = 0l;

		long latestDemandPenaltyCreatedtime=0l;

		UserSearchRequest userSearchRequest = null;
		List<User> payers = null;
		List<Demand> demands = null;

		String userUri = applicationProperties.getUserServiceHostName()
				.concat(applicationProperties.getUserServiceSearchPath());

		/*
		 * user type is CITIZEN by default because only citizen can have demand or payer can be null
		 */
		String citizenTenantId = demandCriteria.getTenantId().split("\\.")[0];

		/*
		 * If payer related data is provided first then user search has to be made first followed by demand search
		 */

		/*
		 * If no payer related data given then search demand first then enrich payer(user) data
		 */
		log.info("demandCriteria::"+demandCriteria);
		demands = demandRepository.getDemands(demandCriteria);
		log.info("demands:"+demands);
		if (!demands.isEmpty()) {

			Set<String> payerUuids = demands.stream().filter(demand -> null != demand.getPayer())
					.map(demand -> demand.getPayer().getUuid()).collect(Collectors.toSet());

			if (!CollectionUtils.isEmpty(payerUuids)) {

				userSearchRequest = UserSearchRequest.builder().requestInfo(requestInfo).uuid(payerUuids).build();

				payers = mapper.convertValue(serviceRequestRepository.fetchResult(userUri, userSearchRequest),
						UserResponse.class).getUser();
			}
		}
		log.info("demannds::"+demands);

		if (!CollectionUtils.isEmpty(demands) && !CollectionUtils.isEmpty(payers))
			demands = demandEnrichmentUtil.enrichPayer(demands, payers);

		log.info("demannddddds::"+demands);
		demands = demands.stream().filter(demand -> {
			return demand.getStatus().equals(Demand.StatusEnum.ACTIVE);
		}).collect(Collectors.toList());
		List<Map<Long, List<DemandDetail>>> demandDetailsList = new ArrayList<>();

		List<Demand> demandsTogetDemandGeneratedDate= demands;

		// Filter demands where demandDetails have taxHeadMasterCode as 10101
		List<Demand> filteredDemands = demandsTogetDemandGeneratedDate.stream()
				.filter(demand -> demand.getDemandDetails().stream()
						.anyMatch(detail -> "10101".equals(detail.getTaxHeadMasterCode())))
				.collect(Collectors.toList());

		Collections.sort(filteredDemands, new Comparator<Demand>() {
			@Override
			public int compare(Demand d1, Demand d2) {
				return Long.compare(d2.getTaxPeriodFrom(), d1.getTaxPeriodFrom());
			}
		});



		if (!filteredDemands.isEmpty()) {
			Demand latestDemand = filteredDemands.get(0);

			Optional<DemandDetail> detail10101 = latestDemand.getDemandDetails().stream()
					.filter(detail -> "10101".equals(detail.getTaxHeadMasterCode()))
					.findFirst();

			Optional<DemandDetail> detailWSTimePenalty = latestDemand.getDemandDetails().stream()
					.filter(detail -> "WS_TIME_PENALTY".equals(detail.getTaxHeadMasterCode()))
					.findFirst();

			if (detail10101.isPresent()) {
				latestDemandCreatedTime = detail10101.get().getAuditDetails().getCreatedTime();
			}

			if (detailWSTimePenalty.isPresent()) {
				latestDemandPenaltyCreatedtime = detailWSTimePenalty.get().getAuditDetails().getCreatedTime();
			}
		} else {
			log.info("No demands found with taxHeadMasterCode 10101 or WS_TIME_PENALTY.");
		}


		for (Demand demand : demands) {
			log.info("Inside demand");
			Map<Long, List<DemandDetail>> demandMap = new HashMap<>();
			Long taxPeriodFrom = (Long) demand.getTaxPeriodFrom();
			List<DemandDetail> demandDetails =  demand.getDemandDetails();
			List<DemandDetail> filteredDemandDetaillist = demandDetails.stream()
					.filter(detail -> {
						BigDecimal difference = detail.getTaxAmount().subtract(detail.getCollectionAmount());
						return (difference.compareTo(BigDecimal.ZERO)) != 0;
					})  // Filter condition
					.collect(Collectors.toList());
			log.info("Filtered List:"+filteredDemandDetaillist);
			if(!filteredDemandDetaillist.isEmpty()) {
				demandMap.put(taxPeriodFrom, filteredDemandDetaillist);
				demandDetailsList.add(demandMap);
			}
		}
		log.info("demandDetailsList:"+demandDetailsList);
		// Sorting the list of maps based on the key in descending order
		List<Map<Long, List<DemandDetail>>> sortedDemandDetailsList = demandDetailsList.stream()
				.sorted((mapA, mapB) -> {
					Long keyA = mapA.keySet().stream().findFirst().orElse(0L);
					Long keyB = mapB.keySet().stream().findFirst().orElse(0L);
					return keyB.compareTo(keyA); // Descending order
				})
				.collect(Collectors.toList());

		log.info("Sorted map:"+sortedDemandDetailsList);

		List<DemandDetail> currentMonthDemandDetailList = new ArrayList<>();
		if (!sortedDemandDetailsList.isEmpty()) {
			Map<Long, List<DemandDetail>> firstMap = sortedDemandDetailsList.get(0);
			firstMap.forEach((key, value) -> {
				currentMonthDemandDetailList.addAll(value); // Get all details from the first map
			});
		}
		// Extract RemainingMonthDemandDetailList
		List<DemandDetail> remainingMonthDemandDetailList = new ArrayList<>();
		if (sortedDemandDetailsList.size() > 1) {
			for (int i = 1; i < sortedDemandDetailsList.size(); i++) {
				Map<Long, List<DemandDetail>> map = sortedDemandDetailsList.get(i);
				map.forEach((key, value) -> {
					remainingMonthDemandDetailList.addAll(value); // Collect all details from the other maps
				});
			}
		}
		log.info("currentMonthDemandDetailList"+currentMonthDemandDetailList);
		log.info("remainingMonthDemandDetailList"+remainingMonthDemandDetailList);
		BigDecimal currentmonthBill = BigDecimal.ZERO;
		BigDecimal currentMonthPenalty = BigDecimal.ZERO;
		BigDecimal currentmonthTotalDue = BigDecimal.ZERO;
		BigDecimal advanceAvailable = BigDecimal.ZERO;
		BigDecimal advanceAdjusted = BigDecimal.ZERO;
		BigDecimal remainingAdvance = BigDecimal.ZERO;
		BigDecimal totalAreas = BigDecimal.ZERO;
		BigDecimal totalAreasWithPenalty = BigDecimal.ZERO;
		BigDecimal netdue = BigDecimal.ZERO;
		BigDecimal netDueWithPenalty = BigDecimal.ZERO;
		BigDecimal totalApplicablePenalty =BigDecimal.ZERO;
		BigDecimal currentmonthRoundOff=BigDecimal.ZERO;
		BigDecimal totalAreasRoundOff=BigDecimal.ZERO;

		currentmonthBill = currentMonthDemandDetailList.stream()
				.filter(dd -> dd.getTaxHeadMasterCode().equals("10101")) // filter by taxHeadCode
				.map(dd -> dd.getTaxAmount().subtract(dd.getCollectionAmount())) // map to the balance between taxAmount and collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add);

		currentmonthRoundOff = currentMonthDemandDetailList.stream()
				.filter(dd -> dd.getTaxHeadMasterCode().equals("WS_Round_Off")) // filter by taxHeadCode
				.map(dd -> dd.getTaxAmount().subtract(dd.getCollectionAmount())) // map to the balance between taxAmount and collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add);
		log.info("currentmonthRoundOff::::"+currentmonthRoundOff);

		log.info("currentMonthDemandDetailList::::"+currentMonthDemandDetailList);
		currentMonthPenalty = currentMonthDemandDetailList.stream()
				.filter(dd -> dd.getTaxHeadMasterCode().equals("WS_TIME_PENALTY")) // filter by taxHeadCode
				.map(dd -> dd.getTaxAmount().subtract(dd.getCollectionAmount())) // map to the balance between taxAmount and collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add);
		log.info("currentMonthDemandDetailListafter::::"+currentMonthDemandDetailList);
		log.info("currentMonthPenalty" + currentMonthPenalty);
		currentmonthTotalDue = currentmonthBill.add(currentMonthPenalty).add(currentmonthRoundOff);
		log.info("currentmonthTotalDue" + currentmonthTotalDue);
		if(currentMonthPenalty.equals(BigDecimal.ZERO)) {
			List<MasterDetail> masterDetails = new ArrayList<>();
			MasterDetail masterDetail = new MasterDetail("Penalty", "[?(@)]");
			masterDetails.add(masterDetail);
			ModuleDetail moduleDetail = ModuleDetail.builder().moduleName("ws-services-calculation").masterDetails(masterDetails).build();
			List<ModuleDetail> moduleDetails = new ArrayList<>();
			moduleDetails.add(moduleDetail);
			MdmsCriteria mdmsCriteria = MdmsCriteria.builder().tenantId(demandCriteria.getTenantId())
					.moduleDetails(moduleDetails)
					.build();
			MdmsCriteriaReq mdmsreq = MdmsCriteriaReq.builder().mdmsCriteria(mdmsCriteria).requestInfo(requestInfo).build();
			DocumentContext mdmsData = util.getAttributeValues(mdmsreq);
			if (!mdmsData.equals(null)) {
				List<Map<String, Object>> paymentMasterDataList = mdmsData.read(PENALTY_PATH_CODE);
				Map<String, Object> paymentMasterData = paymentMasterDataList.get(0);
				Integer rate = (Integer) paymentMasterData.get("rate");
				String penaltyType = String.valueOf(paymentMasterData.get("type"));
				totalApplicablePenalty = currentmonthBill.multiply(new BigDecimal(rate).divide(new BigDecimal(100)));
				totalApplicablePenalty = totalApplicablePenalty.setScale(0, RoundingMode.HALF_UP);
			} else {
				log.info("MDMS data is Null Penalty not connfigured");
			}
		}


		//Tax headcode for WScharges,legacypenalty,legacyarea
		List<String> taxHeadCodesToFilterWithoutPenalty = Arrays.asList("10102", "10201", "10101","WS_Round_Off");

		// Initialize the variable for the sum of taxAmount - collectedAmount specifically for WS_Round_Off
		totalAreasRoundOff = remainingMonthDemandDetailList.stream()
				.filter(dd -> "WS_Round_Off".equals(dd.getTaxHeadMasterCode())) // Filter specifically for WS_Round_Off
				.map(dd -> dd.getTaxAmount().subtract(dd.getCollectionAmount())) // Calculate taxAmount - collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add); // Sum all results

		// Initialize the variable for the sum of taxAmount - collectedAmount for the filtered tax head codes
		totalAreas = remainingMonthDemandDetailList.stream()
				.filter(dd -> taxHeadCodesToFilterWithoutPenalty.contains(dd.getTaxHeadMasterCode())) // Filter by tax head codes
				.map(dd -> dd.getTaxAmount().subtract(dd.getCollectionAmount())) // Calculate taxAmount - collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add); // Sum all results

		BigDecimal penaltyInRemainingMonth= remainingMonthDemandDetailList.stream()
				.filter(dd -> dd.getTaxHeadMasterCode().equals("WS_TIME_PENALTY")) // filter by taxHeadCode
				.map(dd -> dd.getTaxAmount().subtract(dd.getCollectionAmount())) // map to the balance between taxAmount and collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add);

		totalAreasWithPenalty = totalAreas.add(penaltyInRemainingMonth);



		BigDecimal currentMonthAdvanceAvailable=currentMonthDemandDetailList.stream()
				.filter(dd -> dd.getTaxHeadMasterCode().equals("WS_ADVANCE_CARRYFORWARD")) // filter by taxHeadCode
				.map(dd -> dd.getTaxAmount()) // map to the balance between taxAmount and collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add);
		BigDecimal currentMonthAdvanceCollected= currentMonthDemandDetailList.stream()
				.filter(dd -> dd.getTaxHeadMasterCode().equals("WS_ADVANCE_CARRYFORWARD")) // filter by taxHeadCode
				.map(dd -> dd.getCollectionAmount()) // map to the balance between taxAmount and collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add);
		BigDecimal remainingMonthAdvanceAvailable = remainingMonthDemandDetailList.stream()
				.filter(dd -> dd.getTaxHeadMasterCode().equals("WS_ADVANCE_CARRYFORWARD")) // filter by taxHeadCode
				.map(dd -> dd.getTaxAmount()) // map to the balance between taxAmount and collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add);
		BigDecimal remainingMonthAdvanceCollected= remainingMonthDemandDetailList.stream()
				.filter(dd -> dd.getTaxHeadMasterCode().equals("WS_ADVANCE_CARRYFORWARD")) // filter by taxHeadCode
				.map(dd -> dd.getCollectionAmount()) // map to the balance between taxAmount and collectedAmount
				.reduce(BigDecimal.ZERO, BigDecimal::add);
		advanceAvailable = currentMonthAdvanceAvailable.add(remainingMonthAdvanceAvailable);
		advanceAdjusted = currentMonthAdvanceCollected.add(remainingMonthAdvanceCollected);
		remainingAdvance = advanceAvailable.subtract(advanceAdjusted);
		//TODO:
		if(remainingAdvance !=BigDecimal.ZERO && currentmonthBill !=BigDecimal.ZERO && advanceAdjusted.equals(BigDecimal.ZERO)) {
		}

		netdue = currentmonthBill.add(totalAreas).add(remainingAdvance).add(currentmonthRoundOff);
		netDueWithPenalty = currentmonthTotalDue.add(totalAreasWithPenalty).add(remainingAdvance);

		//BigDecimal currentMonthBill
		AggregatedDemandDetailResponse aggregatedDemandDetailResponse = AggregatedDemandDetailResponse.builder()
				.mapOfDemandDetailList(sortedDemandDetailsList)
				.currentmonthBill(currentmonthBill)
				.currentMonthPenalty(currentMonthPenalty)
				.currentmonthTotalDue(currentmonthTotalDue)
				.currentmonthRoundOff(currentmonthRoundOff)
				.totalAreas(totalAreas)
				.totalAreasWithPenalty(totalAreasWithPenalty)
				.totalAreasRoundOff(totalAreasRoundOff)
				.netdue(netdue)
				.netDueWithPenalty(netDueWithPenalty)
				.advanceAdjusted(advanceAdjusted)
				.advanceAvailable(advanceAvailable)
				.remainingAdvance(remainingAdvance)
				.totalApplicablePenalty(totalApplicablePenalty)
				.latestDemandCreatedTime(latestDemandCreatedTime)
				.latestDemandPenaltyCreatedtime(latestDemandPenaltyCreatedtime).build();


		return aggregatedDemandDetailResponse;
	}
	
}
