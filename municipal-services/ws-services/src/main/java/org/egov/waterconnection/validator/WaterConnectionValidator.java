package org.egov.waterconnection.validator;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.egov.common.contract.request.RequestInfo;
import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.config.WSConfiguration;
import org.egov.waterconnection.constants.WCConstants;
import org.egov.waterconnection.repository.ServiceRequestRepository;
import org.egov.waterconnection.service.MeterInfoValidator;
import org.egov.waterconnection.service.PropertyValidator;
import org.egov.waterconnection.service.WaterFieldValidator;
import org.egov.waterconnection.web.models.Demand;
import org.egov.waterconnection.web.models.DemandDetail;
import org.egov.waterconnection.web.models.DemandRequest;
import org.egov.waterconnection.web.models.DemandResponse;
import org.egov.waterconnection.web.models.RequestInfoWrapper;
import org.egov.waterconnection.web.models.ValidatorResult;
import org.egov.waterconnection.web.models.WaterConnection;
import org.egov.waterconnection.web.models.WaterConnectionRequest;
import org.egov.waterconnection.web.models.Connection.StatusEnum;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;
import java.util.concurrent.CopyOnWriteArrayList;


@Component
@Slf4j
public class WaterConnectionValidator {

	@Autowired
	private PropertyValidator propertyValidator;
	
	@Autowired
	private WaterFieldValidator waterFieldValidator;
	
	@Autowired
	private MeterInfoValidator meterInfoValidator;

	@Autowired
	private ServiceRequestRepository serviceRequestRepository;
	
	@Autowired
	private WSConfiguration config;

	@Autowired
	private ObjectMapper mapper;

	/**Used strategy pattern for avoiding multiple if else condition
	 * 
	 * @param waterConnectionRequest
	 * @param reqType
	 */
	public void validateWaterConnection(WaterConnectionRequest waterConnectionRequest, int reqType) {
		Map<String, String> errorMap = new HashMap<>();
		if (StringUtils.isEmpty(waterConnectionRequest.getWaterConnection().getProcessInstance())
				|| StringUtils.isEmpty(waterConnectionRequest.getWaterConnection().getProcessInstance().getAction())) {
			errorMap.put("INVALID_WF_ACTION", "Workflow obj can not be null or action can not be empty!!");
			throw new CustomException(errorMap);
		}
		ValidatorResult isPropertyValidated = propertyValidator.validate(waterConnectionRequest, reqType);
		if (!isPropertyValidated.isStatus())
			errorMap.putAll(isPropertyValidated.getErrorMessage());
		// GPWSC system does not this functionality
//		ValidatorResult isWaterFieldValidated = waterFieldValidator.validate(waterConnectionRequest, reqType);
//		if (!isWaterFieldValidated.isStatus())
//			errorMap.putAll(isWaterFieldValidated.getErrorMessage());
		Long previousMetereReading =waterConnectionRequest.getWaterConnection().getPreviousReadingDate() ;
		if(previousMetereReading == null || previousMetereReading <=0) {
			errorMap.put("PREVIOUS_METER_READIN_INVALID","Previous Meter reading date cannot be null");
		}
		if(waterConnectionRequest.getWaterConnection().getOldConnectionNo() == null || waterConnectionRequest.getWaterConnection().getOldConnectionNo() == "") {
			errorMap.put("INVALID_OLD_CONNECTION_NO","Old connection number cannot be empty");
		}
		ValidatorResult isMeterInfoValidated = meterInfoValidator.validate(waterConnectionRequest, reqType);
		if (!isMeterInfoValidated.isStatus())
			errorMap.putAll(isMeterInfoValidated.getErrorMessage());
		if(waterConnectionRequest.getWaterConnection().getProcessInstance().getAction().equalsIgnoreCase("PAY"))
			errorMap.put("INVALID_ACTION","Pay action cannot be perform directly");

		LocalDate date =Instant.ofEpochMilli(previousMetereReading).atZone(ZoneId.systemDefault()).toLocalDate();
		if(date.isAfter(LocalDate.now().minusMonths(1))) {
			errorMap.put("INVALID_BILLING_CYCLE","Cannot generate demands for future months");
		}
		if (waterConnectionRequest.getWaterConnection().getPaymentType() != null
				&& !waterConnectionRequest.getWaterConnection().getPaymentType().isEmpty()) {

			if(waterConnectionRequest.getWaterConnection().getPaymentType()
					.equalsIgnoreCase(WCConstants.PAYMENT_TYPE_ARREARS) ||
					waterConnectionRequest.getWaterConnection().getPaymentType()
					.equalsIgnoreCase(WCConstants.PAYMENT_TYPE_ADVANCE)) {
				if (waterConnectionRequest.getWaterConnection().getPaymentType()
						.equalsIgnoreCase(WCConstants.PAYMENT_TYPE_ARREARS)
						&& waterConnectionRequest.getWaterConnection().getAdvance() != null) {
					errorMap.put("INVALID_PARAMETER", "Advance value is not considered when Paymenttype is arrears.");
				}
				if (waterConnectionRequest.getWaterConnection().getPaymentType()
						.equalsIgnoreCase(WCConstants.PAYMENT_TYPE_ADVANCE)
						&& (waterConnectionRequest.getWaterConnection().getArrears() != null
								|| waterConnectionRequest.getWaterConnection().getPenalty() != null)) {
					errorMap.put("INVALID_PARAMETER",
							"Arrears and Penalty value is not considered when Paymenttype is Advanced.");
				}
			}
			
			else {
				errorMap.put("INVALID_PARAMETER",
						"Payment type not allowed");
			}
		}	
		
		if (!errorMap.isEmpty())
			throw new CustomException(errorMap);
	}
	
	public void validatePropertyForConnection(List<WaterConnection> waterConnectionList) {
		waterConnectionList.forEach(waterConnection -> {
			if (StringUtils.isEmpty(waterConnection.getId())) {
				StringBuilder builder = new StringBuilder();
				builder.append("PROPERTY UUID NOT FOUND FOR ")
						.append(waterConnection.getConnectionNo() == null ? waterConnection.getApplicationNo()
								: waterConnection.getConnectionNo());
				log.error(builder.toString());
			}
		});
	}
	
	/**
	 * Validate for previous data to current data
	 * 
	 * @param request water connection request
	 * @param searchResult water connection search result
	 */
	public void validateUpdate(WaterConnectionRequest request, WaterConnection searchResult, int reqType) {
		validateAllIds(request.getWaterConnection(), searchResult);
		validateDuplicateDocuments(request);
		setFieldsFromSearch(request, searchResult, reqType);
		DemandResponse response =  validateUpdateForDemand(request,searchResult);
		if(response != null) {
			List<Demand> demands = response.getDemands();
			CopyOnWriteArrayList<Demand> demList = null;
			CopyOnWriteArrayList<Demand> allDemands = null;
			if( demands != null && !demands.isEmpty()) {
				demList = new CopyOnWriteArrayList<>(demands);
				allDemands = new CopyOnWriteArrayList<>(demands);
			}
			 
			if(allDemands != null && !allDemands.isEmpty()) {
				for (Demand demand : allDemands) {
					if(demand.isPaymentCompleted()) {
						demList.remove(demand);
					}
					Integer totalTax = demand.getDemandDetails().stream().mapToInt(i->i.getTaxAmount().intValue()).sum();
					Integer totalCollection = demand.getDemandDetails().stream().mapToInt(i->i.getCollectionAmount().intValue()).sum();
					if(totalTax.compareTo(totalCollection) == 0) {
						demList.remove(demand);
					}
					
				}
			}
				Boolean isArrear = false;
				Boolean isAdvance = false;
				
				if(request.getWaterConnection().getAdvance()!=null && request.getWaterConnection().getAdvance().compareTo(BigDecimal.ZERO) == 0) {
					isAdvance =  true;
				}
				if(request.getWaterConnection().getArrears()!=null && request.getWaterConnection().getArrears().compareTo(BigDecimal.ZERO) == 0) {
					isArrear =  true;
				}
				if ((request.getWaterConnection().getStatus().equals(StatusEnum.INACTIVE) && demList != null && demList.size() > 0)
						|| (searchResult.getArrears() != null && request.getWaterConnection().getArrears() == null && demList != null && demList.size() > 0
								|| (isArrear && demList != null && demList.size() > 0))|| (request.getWaterConnection().getStatus().equals(StatusEnum.INACTIVE) && demList != null && demList.size() > 0)
						|| (searchResult.getAdvance() != null && request.getWaterConnection().getAdvance() == null && demList != null && demList.size() > 0
						|| isAdvance)) {
					for (Demand demand : demList) {
						demand.setStatus(org.egov.waterconnection.web.models.Demand.StatusEnum.CANCELLED);
					}
					updateDemand(request.getRequestInfo(), demList);
					
				}
			}
			
		
	}
/**
 * GPWSC specific validation
 * @param request
 * @param searchResult
 */
	private DemandResponse validateUpdateForDemand(WaterConnectionRequest request, WaterConnection searchResult) {
		Map<String, String> errorMap = new HashMap<>();
		StringBuilder url = new StringBuilder();
		url.append(config.getBillingHost()).append(config.getDemandSearchUri());
		url.append("?consumerCode=").append(request.getWaterConnection().getConnectionNo());
		url.append("&tenantId=").append(request.getWaterConnection().getTenantId());
		url.append("&status=ACTIVE");
		url.append("&businessService=WS");
		DemandResponse demandResponse = null;
		try {
			Object response = serviceRequestRepository.fetchResult(url, RequestInfoWrapper.builder().requestInfo(request.getRequestInfo()).build());
			 demandResponse = mapper.convertValue(response, DemandResponse.class);
			
		} catch (Exception ex) {
			log.error("Calculation response error!!", ex);
			throw new CustomException("WATER_CALCULATION_EXCEPTION", "Calculation response can not parsed!!!");
		}
		
		if( demandResponse!= null && demandResponse.getDemands().size() >0 ) {
			List<Demand> demands = demandResponse.getDemands().stream().filter( d-> !d.getConsumerType().equalsIgnoreCase("waterConnection-arrears")).collect(Collectors.toList());
			List<Demand> arrearDemands = demandResponse.getDemands().stream().filter( d-> d.getConsumerType().equalsIgnoreCase("waterConnection-arrears")).collect(Collectors.toList());
			List<Demand> advanceDemands = demandResponse.getDemands().stream().filter( d-> d.getConsumerType().equalsIgnoreCase("waterConnection-advance")).collect(Collectors.toList());

			List<DemandDetail> collectArrears = arrearDemands.size() > 0 ? arrearDemands.get(0).getDemandDetails().stream().filter( d-> d.getCollectionAmount().intValue()>0).collect(Collectors.toList()): new ArrayList<DemandDetail>();
			List<DemandDetail> collectAdvance = advanceDemands.size() > 0 ? advanceDemands.get(0).getDemandDetails().stream().filter( d-> d.getCollectionAmount().intValue()>0).collect(Collectors.toList()): new ArrayList<DemandDetail>();

			if(demands.size() > 0 || collectArrears.size() >0  || collectAdvance.size() > 0) {
				if(!searchResult.getOldConnectionNo().equalsIgnoreCase(request.getWaterConnection().getOldConnectionNo())) {
					errorMap.put("INVALID_UPDATE_OLD_CONNO", "Old ConnectionNo cannot be modified!!");
				}
				if(searchResult.getPreviousReadingDate() != request.getWaterConnection().getPreviousReadingDate()) {
					errorMap.put("INVALID_UPDATE_PRVMETERREADING", "Previous Meter Reading Date cannot be modified cannot be modified!!");
				}
				if(searchResult.getArrears() != request.getWaterConnection().getArrears()) {
					errorMap.put("INVALID_UPDATE_ARREARS", "Arrears cannot be modified cannot be modified!!");
				}
			}
		}
		
		return demandResponse;
	}
   
	/**
	 * Validates if all ids are same as obtained from search result
	 * 
	 * @param updateWaterConnection The water connection request from update request 
	 * @param searchResult The water connection from search result
	 */
	private void validateAllIds(WaterConnection updateWaterConnection, WaterConnection searchResult) {
		Map<String, String> errorMap = new HashMap<>();
		if (!searchResult.getApplicationNo().equals(updateWaterConnection.getApplicationNo()))
			errorMap.put("CONNECTION_NOT_FOUND", "The application number from search: " + searchResult.getApplicationNo()
					+ " and from update: " + updateWaterConnection.getApplicationNo() + " does not match");
		if (!CollectionUtils.isEmpty(errorMap))
			throw new CustomException(errorMap);
	}
    
    /**
     * Validates application documents for duplicates
     * 
     * @param request The waterConnection Request
     */
	private void validateDuplicateDocuments(WaterConnectionRequest request) {
		if (request.getWaterConnection().getDocuments() != null) {
			List<String> documentFileStoreIds = new LinkedList<>();
			request.getWaterConnection().getDocuments().forEach(document -> {
				if (documentFileStoreIds.contains(document.getFileStoreId()))
					throw new CustomException("DUPLICATE_DOCUMENT_ERROR",
							"Same document cannot be used multiple times");
				else
					documentFileStoreIds.add(document.getFileStoreId());
			});
		}
	}
	/**
	 * Enrich Immutable fields
	 * 
	 * @param request Water connection request
	 * @param searchResult water connection search result
	 */
	private void setFieldsFromSearch(WaterConnectionRequest request, WaterConnection searchResult, int reqType) {
		if (reqType == WCConstants.UPDATE_APPLICATION) {
			request.getWaterConnection().setConnectionNo(searchResult.getConnectionNo());
		}
	}

	  /**
     * Updates the demand
     * @param requestInfo The RequestInfo of the calculation Request
     * @param demands The demands to be updated
     * @return The list of demand updated
     */
    private List<Demand> updateDemand(RequestInfo requestInfo, List<Demand> demands){
        StringBuilder url = new StringBuilder(config.getBillingHost());
        url.append(config.getDemandUpdateEndPoint());
        DemandRequest request = new DemandRequest(requestInfo,demands);
        Object result = serviceRequestRepository.fetchResult(url, request);
        try{
            return mapper.convertValue(result,DemandResponse.class).getDemands();
        }
        catch(IllegalArgumentException e){
            throw new CustomException("PARSING_ERROR","Failed to parse response of update demand");
        }
    }
}
