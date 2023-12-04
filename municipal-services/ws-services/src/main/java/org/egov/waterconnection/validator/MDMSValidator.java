package org.egov.waterconnection.validator;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.egov.common.contract.request.RequestInfo;
import org.egov.mdms.model.MdmsCriteriaReq;
import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.constants.WCConstants;
import org.egov.waterconnection.web.models.FeedbackRequest;
import org.egov.waterconnection.web.models.RoadCuttingInfo;
import org.egov.waterconnection.web.models.WaterConnection;
import org.egov.waterconnection.web.models.WaterConnectionRequest;
import org.egov.waterconnection.repository.ServiceRequestRepository;
import org.egov.waterconnection.service.MasterDataService;
import org.egov.waterconnection.util.WaterServicesUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class MDMSValidator {
	@Autowired
	private WaterServicesUtil waterServicesUtil;

	@Autowired
	private ServiceRequestRepository serviceRequestRepository;

	@Value("${egov.mdms.host}")
	private String mdmsHost;

	@Value("${egov.mdms.search.endpoint}")
	private String mdmsEndpoint;

	@Autowired
	private MasterDataService masterDataService;
	

	@Autowired
	private ObjectMapper mapper;

	/**
	 * Validate Master data for given request
	 * 
	 * @param request
	 * @param reqType
	 */
	public void validateMasterData(WaterConnectionRequest request, int reqType) {
		switch (reqType) {
		case WCConstants.UPDATE_APPLICATION:
			validateMasterDataForUpdateConnection(request);
			break;
		case WCConstants.MODIFY_CONNECTION:
			validateMasterDataForModifyConnection(request);
			break;
		default:
			break;
		}
	}

	public void validateMasterDataForUpdateConnection(WaterConnectionRequest request) {
		if (request.getWaterConnection().getProcessInstance().getAction()
				.equalsIgnoreCase(WCConstants.ACTIVATE_CONNECTION_CONST)) {
			String jsonPath = WCConstants.JSONPATH_ROOT;
			String taxjsonPath = WCConstants.TAX_JSONPATH_ROOT;
			String tenantId = request.getWaterConnection().getTenantId();
			List<String> names = new ArrayList<>(Arrays.asList(WCConstants.MDMS_WC_CONNECTION_TYPE,
					WCConstants.MDMS_WC_CONNECTION_CATEGORY, WCConstants.MDMS_WC_WATER_SOURCE));
			Map<String, List<String>> codes = getAttributeValues(tenantId, WCConstants.MDMS_WC_MOD_NAME, names,
					"$.*.code", jsonPath, request.getRequestInfo());
			List<String> taxModelnames = new ArrayList<>(Arrays.asList(WCConstants.WC_ROADTYPE_MASTER));
			Map<String, List<String>> codeFromCalculatorMaster = getAttributeValues(tenantId, WCConstants.WS_TAX_MODULE,
					taxModelnames, "$.*.code", taxjsonPath, request.getRequestInfo());

			// merge codes
			String[] finalmasterNames = { WCConstants.MDMS_WC_CONNECTION_TYPE, WCConstants.MDMS_WC_CONNECTION_CATEGORY,
					WCConstants.MDMS_WC_WATER_SOURCE, WCConstants.WC_ROADTYPE_MASTER };
			Map<String, List<String>> finalcodes = Stream.of(codes, codeFromCalculatorMaster).map(Map::entrySet)
					.flatMap(Collection::stream).collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
			validateMDMSData(finalmasterNames, finalcodes);
			validateCodes(request.getWaterConnection(), finalcodes);
		}
	}

	public Map<String, List<String>> getAttributeValues(String tenantId, String moduleName, List<String> names,
			String filter, String jsonPath, RequestInfo requestInfo) {
		StringBuilder uri = new StringBuilder(mdmsHost).append(mdmsEndpoint);
		MdmsCriteriaReq criteriaReq = waterServicesUtil.prepareMdMsRequest(tenantId, moduleName, names, filter,
				requestInfo);
		try {

			Object result = serviceRequestRepository.fetchResult(uri, criteriaReq);
			return JsonPath.read(result, jsonPath);
		} catch (Exception e) {
			throw new CustomException(WCConstants.INVALID_CONNECTION_TYPE, WCConstants.INVALID_CONNECTION_TYPE);
		}
	}

	private void validateMDMSData(String[] masterNames, Map<String, List<String>> codes) {
		Map<String, String> errorMap = new HashMap<>();
		for (String masterName : masterNames) {
			if (CollectionUtils.isEmpty(codes.get(masterName))) {
				errorMap.put("MDMS_DATA_ERROR ", "Unable to fetch " + masterName + " codes from MDMS");
			}
		}
		if (!errorMap.isEmpty())
			throw new CustomException(errorMap);
	}

	/**
	 * validateCodes will validate for given fields and return error map if codes
	 * are not matching
	 * 
	 * @param waterConnection WaterConnection Object
	 * @param codes           List of codes
	 * @return error map for given fields
	 */
	private void validateCodes(WaterConnection waterConnection, Map<String, List<String>> codes) {
		Map<String, String> errorMap = new HashMap<>();
		StringBuilder messageBuilder = new StringBuilder();
		if (!StringUtils.isEmpty(waterConnection.getConnectionType())
				&& !codes.get(WCConstants.MDMS_WC_CONNECTION_TYPE).contains(waterConnection.getConnectionType())) {
			messageBuilder = new StringBuilder();
			messageBuilder.append("Connection type value is invalid, please enter proper value! ");
			errorMap.put("INVALID_WATER_CONNECTION_TYPE", messageBuilder.toString());
		}
		if (!StringUtils.isEmpty(waterConnection.getWaterSource())
				&& !codes.get(WCConstants.MDMS_WC_WATER_SOURCE).contains(waterConnection.getWaterSource())) {
			messageBuilder = new StringBuilder();
			messageBuilder.append("Water Source / Water Sub Source value is invalid, please enter proper value! ");
			errorMap.put("INVALID_WATER_CONNECTION_SOURCE", messageBuilder.toString());
		}
		/*
		 * if (!StringUtils.isEmpty(waterConnection.getRoadType()) &&
		 * !codes.get(WCConstants.WC_ROADTYPE_MASTER).contains(waterConnection.
		 * getRoadType())) { messageBuilder = new StringBuilder(); messageBuilder.
		 * append("Road type value is invalid, please enter proper value! ");
		 * errorMap.put("INVALID_WATER_ROAD_TYPE", messageBuilder.toString()); }
		 */

		if (waterConnection.getRoadCuttingInfo() == null) {
			errorMap.put("INVALID_ROAD_INFO", "Road Cutting Information should not be empty");
		}

		if (waterConnection.getRoadCuttingInfo() != null) {
			for (RoadCuttingInfo roadCuttingInfo : waterConnection.getRoadCuttingInfo()) {
				if (!StringUtils.isEmpty(roadCuttingInfo.getRoadType())
						&& !codes.get(WCConstants.WC_ROADTYPE_MASTER).contains(roadCuttingInfo.getRoadType())) {
					messageBuilder = new StringBuilder();
					messageBuilder.append("Road type value is invalid, please enter proper value! ");
					errorMap.put("INVALID_WATER_ROAD_TYPE", messageBuilder.toString());
				}
			}
		}
		if (!errorMap.isEmpty())
			throw new CustomException(errorMap);
	}

	/**
	 * Validate master data of water connection request
	 *
	 * @param request waterconnection request
	 */
	public void validateMasterForCreateRequest(WaterConnectionRequest request) {
		// calling property related master
		List<String> propertyModuleMasters = new ArrayList<>(Arrays.asList(WCConstants.PROPERTY_OWNERTYPE));
		Map<String, List<String>> codesFromPropetyMasters = getAttributeValues(
				request.getWaterConnection().getTenantId(), WCConstants.PROPERTY_MASTER_MODULE, propertyModuleMasters,
				"$.*.code", WCConstants.PROPERTY_JSONPATH_ROOT, request.getRequestInfo());
		// merge codes
		String[] finalmasterNames = { WCConstants.PROPERTY_OWNERTYPE };
		validateMDMSData(finalmasterNames, codesFromPropetyMasters);
		validateCodesForCreateRequest(request, codesFromPropetyMasters);
	}

	/**
	 *
	 * @param request Water connection request
	 * @param codes   list of master data codes to varify against the water
	 *                connection request
	 */
	public void validateCodesForCreateRequest(WaterConnectionRequest request, Map<String, List<String>> codes) {
		Map<String, String> errorMap = new HashMap<>();
		if (!CollectionUtils.isEmpty(request.getWaterConnection().getConnectionHolders())) {
			request.getWaterConnection().getConnectionHolders().forEach(holderDetail -> {
				if (!StringUtils.isEmpty(holderDetail.getOwnerType())
						&& !codes.get(WCConstants.PROPERTY_OWNERTYPE).contains(holderDetail.getOwnerType())) {
					errorMap.put("INVALID_CONNECTION_HOLDER_TYPE",
							"The Connection holder type '" + holderDetail.getOwnerType() + "' does not exists");
				}
			});
		}

		if (!errorMap.isEmpty())
			throw new CustomException(errorMap);
	}

	public void validateMasterDataForModifyConnection(WaterConnectionRequest request) {
		if (request.getWaterConnection().getProcessInstance().getAction()
				.equalsIgnoreCase(WCConstants.APPROVE_CONNECTION)) {
			String jsonPath = WCConstants.JSONPATH_ROOT;
			String taxjsonPath = WCConstants.TAX_JSONPATH_ROOT;
			String tenantId = request.getWaterConnection().getTenantId();
			List<String> names = new ArrayList<>(Arrays.asList(WCConstants.MDMS_WC_CONNECTION_TYPE,
					WCConstants.MDMS_WC_CONNECTION_CATEGORY, WCConstants.MDMS_WC_WATER_SOURCE));
			Map<String, List<String>> codes = getAttributeValues(tenantId, WCConstants.MDMS_WC_MOD_NAME, names,
					"$.*.code", jsonPath, request.getRequestInfo());
			List<String> taxModelnames = new ArrayList<>(Arrays.asList(WCConstants.WC_ROADTYPE_MASTER));
			Map<String, List<String>> codeFromCalculatorMaster = getAttributeValues(tenantId, WCConstants.WS_TAX_MODULE,
					taxModelnames, "$.*.code", taxjsonPath, request.getRequestInfo());
			// merge codes
			String[] finalmasterNames = { WCConstants.MDMS_WC_CONNECTION_TYPE, WCConstants.MDMS_WC_CONNECTION_CATEGORY,
					WCConstants.MDMS_WC_WATER_SOURCE, WCConstants.WC_ROADTYPE_MASTER };
			Map<String, List<String>> finalcodes = Stream.of(codes, codeFromCalculatorMaster).map(Map::entrySet)
					.flatMap(Collection::stream).collect(Collectors.toMap(Map.Entry::getKey, Map.Entry::getValue));
			validateMDMSData(finalmasterNames, finalcodes);
			validateCodes(request.getWaterConnection(), finalcodes);
		}
	}

	public void validateQuestion(FeedbackRequest feedbackrequest) {
		// TODO Auto-generated method stub
		Object masterData = masterDataService.getFeedbackQuestions(feedbackrequest.getRequestInfo(),
				feedbackrequest.getFeedback().getTenantId());
		Map additonalDetails = (Map) feedbackrequest.getFeedback().getAdditionalDetails();
		List<Map<String, String>> requestCheckList = (List<Map<String, String>>) additonalDetails
				.get(WCConstants.MDMS_CHECKLIST);
		List<Map<String, Object>> mdmsCheckList = JsonPath.read(masterData, WCConstants.REQ_CHECKLIST_PATH);
		if (mdmsCheckList.size() > 0 && (requestCheckList == null || requestCheckList.size() == 0)) {
			throw new CustomException(WCConstants.INVALID_CHECKLIST, " Mandatory feedback is not provided!");
		}
		mdmsCheckList.forEach(mdmsClItem -> {
			Map<String, String> reqClItem = null;
			for (int j = 0; j < requestCheckList.size(); j++) {
				if (requestCheckList.get(j).get("code").equalsIgnoreCase((String) mdmsClItem.get("code"))) {
					reqClItem = requestCheckList.get(j);
				}
			}
			if (reqClItem != null) {
				String[] reqOptions = reqClItem.get("value").split(",");
				List<String> mdmsClOptions = (List<String>) mdmsClItem.get("options");
				if (((String) mdmsClItem.get("type")).equalsIgnoreCase(WCConstants.CHECK_LIST_SINGLE_SELECT)) {
					if (reqOptions.length > 1) {
						throw new CustomException(WCConstants.INVALID_CHECKLIST_TYPE, "Feedback "
								+ mdmsClItem.get("code") + " is SINGLE SELECT, cannot select multiple options.");
					} else if (!mdmsClOptions.contains(reqOptions[0])) {
						throw new CustomException(WCConstants.INVALID_CHECKLIST_ANS,
								" Value provided is not feedback options.");
					}
				} else if (((String) mdmsClItem.get("type")).equalsIgnoreCase(WCConstants.CHECK_LIST_MULTI_SELECT)) {
					for (int h = 0; h < reqOptions.length; h++) {
						if (!mdmsClOptions.contains(reqOptions[h])) {
							throw new CustomException(WCConstants.INVALID_CHECKLIST,
									"Checklist " + mdmsClItem.get("code") + " does not allow option " + reqOptions[h]);
						}
					}

				} else {
					throw new CustomException(WCConstants.INVALID_CHECKLIST_ANS,
							"  Value provided is not feedback options.");
				}
			} else {
				throw new CustomException(WCConstants.MISSING_CHECKLIST,
						" Required Feedback " + mdmsClItem.get("code") + " is not answered ");
			}
		});

	}
	
	/**
	 * Validate MIS fields
	 * Aadhar number, category, subcategory
	 * @param waterConnectionRequest
	 */
	public void validateMISFields(WaterConnectionRequest waterConnectionRequest) {
		HashMap<String,String> errorMap = new HashMap<String,String>();
		
		List<String> names = new ArrayList<>(Arrays.asList(WCConstants.MDMS_WC_MIS_CATEGORY,
				WCConstants.MDMS_WC_MIS_SUBCATEGORY));
		Map<String, List<String>> codes = getAttributeValues(waterConnectionRequest.getWaterConnection().getTenantId(), WCConstants.MDMS_WC_MOD_NAME, names,
				"$.*.code", WCConstants.JSONPATH_ROOT, waterConnectionRequest.getRequestInfo());
		
		
		HashMap<String, Object> addDetail = mapper.convertValue(
				waterConnectionRequest.getWaterConnection().getAdditionalDetails(), HashMap.class);
		if (!StringUtils.isEmpty(addDetail)
				&& addDetail.getOrDefault(WCConstants.AADHAR_KEY, null) != null) {
			
			String aadharNumber = String.valueOf(addDetail.get(WCConstants.AADHAR_KEY));
			if ( aadharNumber.length() != 16) {
				errorMap.put("INVALID_AADHAR_NUMBER", "Aadhar Number should be 16 Digits.");
			}
		}
		
		if (!StringUtils.isEmpty(addDetail)
				&& addDetail.getOrDefault(WCConstants.CATEGORY_KEY, null) != null) {
			
			String category = String.valueOf(addDetail.get(WCConstants.CATEGORY_KEY));
			List categoryCodes = codes.get(WCConstants.MDMS_WC_MIS_CATEGORY);
			if ( !categoryCodes.isEmpty() && !categoryCodes.contains(category)) {
				errorMap.put("INVALID_CATEGORY", "Category is invalid.");
			}
		}
		
		if (!StringUtils.isEmpty(addDetail)
				&& addDetail.getOrDefault(WCConstants.SUBCATEGORY_KEY, null) != null) {
			
			String category = String.valueOf(addDetail.get(WCConstants.SUBCATEGORY_KEY));
			List categoryCodes = codes.get(WCConstants.MDMS_WC_MIS_SUBCATEGORY);
			if ( !categoryCodes.isEmpty() && !categoryCodes.contains(category)) {
				errorMap.put("INVALID_SUBCATEGORY", "SubCategory is invalid.");
			}
		}
		
		if (!errorMap.isEmpty())
			throw new CustomException(errorMap);
	}
}
