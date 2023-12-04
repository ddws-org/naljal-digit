package org.egov.echallan.expense.validator;

import static java.util.Objects.isNull;
import static org.apache.commons.lang.StringUtils.isBlank;
import static org.apache.commons.lang.StringUtils.isEmpty;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.egov.common.contract.request.RequestInfo;
import org.egov.echallan.config.ChallanConfiguration;
import org.egov.echallan.model.Challan;
import org.egov.echallan.model.ChallanRequest;
import org.egov.echallan.model.RequestInfoWrapper;
import org.egov.echallan.model.Challan.StatusEnum;
import org.egov.echallan.repository.ServiceRequestRepository;
import org.egov.echallan.web.models.vendor.Vendor;
import org.egov.echallan.web.models.vendor.VendorResponse;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;

import lombok.extern.slf4j.Slf4j;

@Component
@Slf4j
public class ExpenseValidator {

	@Autowired
	private ChallanConfiguration config;

	@Autowired
	private ServiceRequestRepository serviceRequestRepository;

	@Autowired
	private ObjectMapper mapper;

	public void validateFields(ChallanRequest request, Object mdmsData) {
		Challan challan = request.getChallan();
		Map<String, String> errorMap = new HashMap<>();

		if (isBlank(challan.getTypeOfExpense()))
			errorMap.put("BLANK_TypeOfExpense", "TypeOfExpense is manadatory");
		else {
			if (!((List<String>) JsonPath.read(mdmsData, "$.MdmsRes.Expense.ExpenseType"))
					.contains(challan.getTypeOfExpense()))
				errorMap.put("INVALID_TypeOfExpense", "TypeOfExpense is invalid");
		}

		if (isBlank(challan.getVendor()))
			errorMap.put("BLANK_Vendor", "Vendor is mandatory");
		else {
			Vendor vendor = (Vendor) validateVendor(challan.getVendor(), challan.getTenantId(),
					request.getRequestInfo());
			if (isNull(vendor))
				errorMap.put("INVALID_Vendor", "Vendor does not exists with id :" + challan.getVendor());
			else {
				challan.setAccountId(vendor.getOwnerId());
			}
		}
		Long currentTime = System.currentTimeMillis();
		if (isNull(challan.getBillDate()))
			errorMap.put("NULL_BillDate", "Bill date is mandatory");
		else if (challan.getBillDate() > currentTime)
			errorMap.put("BillDate_CurrentDate", "Bill date should be before current date");
		else if (!isNull(challan.getBillIssuedDate()) && challan.getBillIssuedDate() > challan.getBillDate())
			errorMap.put("BillIssuedDate_After_BillDate", " Party bill date should be before bill date.");

		if (challan.getIsBillPaid() && isNull(challan.getPaidDate()))
			errorMap.put("NULL_PaidDate", "Paid date is mandatory");

		if (challan.getIsBillPaid() && (!isNull(challan.getPaidDate())) && (!isNull(challan.getBillDate()))
				&& challan.getPaidDate() < challan.getBillDate())
			errorMap.put("PaidDate_Before_BillDate", "Paid date should be after billdate");

		if (challan.getIsBillPaid() && (!isNull(challan.getPaidDate())) && challan.getPaidDate() > currentTime)
			errorMap.put("PaidDate_CurrentDate", " Paid date should be before current date");

		if (isNull(challan.getTaxPeriodFrom()) && isNull(challan.getTaxPeriodTo())) {
			errorMap.put("FromDate_ToDate_Mandetory", "Both Expense Fromdate and Todate is Mandetory");
		}
		
		if (isNull(challan.getTaxPeriodFrom()) && !isNull(challan.getTaxPeriodTo())) {
			errorMap.put("FromDate_Mandetory", "Expense From date Is Mandetory");

		}if (!isNull(challan.getTaxPeriodFrom()) && isNull(challan.getTaxPeriodTo())) {
			errorMap.put("ToDate_Mandetory", "Expense Todate is Mandetory");
		}
		
		
		if (challan.getTaxPeriodFrom() > challan.getTaxPeriodTo())
			errorMap.put("ToDate_Before_FromDate", " From date should be Less Than Todate date");
		else if (challan.getTaxPeriodFrom() > challan.getBillDate())
			errorMap.put("FromDate_CurrentDate", "From date should be before or equal to bill Date date");
		else if (challan.getTaxPeriodTo() > challan.getBillDate())
			errorMap.put("ToDate_CurrentDate", "To date should be before current date");
		
		if(challan.getTaxPeriodFrom().equals(challan.getTaxPeriodTo())){
			challan.setTaxPeriodTo(challan.getTaxPeriodTo() + 1);
		}
		
		if (!errorMap.isEmpty())
			throw new CustomException(errorMap);
	
	}

	private Object validateVendor(String vendor, String tenantId, RequestInfo requestInfo) {
		StringBuilder uri = new StringBuilder(config.getVendorHost()).append(config.getVendorContextPath())
				.append(config.getVendorSearchEndpoint()).append("?tenantId=").append(tenantId);
		if (!isEmpty(vendor)) {
			uri.append("&ids=").append(vendor);
		}

		RequestInfoWrapper requestInfoWrpr = new RequestInfoWrapper();
		requestInfoWrpr.setRequestInfo(requestInfo);
		try {

			LinkedHashMap responseMap = (LinkedHashMap) serviceRequestRepository.fetchResult(uri, requestInfoWrpr);
			VendorResponse vendorResponse = mapper.convertValue(responseMap, VendorResponse.class);
			if (!CollectionUtils.isEmpty(vendorResponse.getVendor())) {
				return vendorResponse.getVendor().get(0);
			} else {
				return null;
			}

		} catch (IllegalArgumentException e) {
			throw new CustomException("IllegalArgumentException", "ObjectMapper convert to vendor");
		}

	}

	public void validateUpdateRequest(ChallanRequest request, List<Challan> searchResult) {
		Challan challan = request.getChallan();
		Map<String, String> errorMap = new HashMap<>();
		if (searchResult.size() == 0)
			errorMap.put("INVALID_UPDATE_REQ_NOT_EXIST", "The Challan to be updated is not in database");
		Challan searchchallan = searchResult.get(0);

		if (searchchallan.getApplicationStatus() == StatusEnum.PAID) {
			if (!challan.getTypeOfExpense().equalsIgnoreCase(searchchallan.getTypeOfExpense()))
				errorMap.put("INVALID_UPDATE_REQ_NOTMATCHED_TYPEEXPENSE", " Update type of expense is not allowed");
			if (!challan.getVendor().equalsIgnoreCase(searchchallan.getVendor()))
				errorMap.put("INVALID_UPDATE_REQ_NOTMATCHED_VENDOR", " Update vendor is not allowed");
			if (!challan.getBillDate().equals(searchchallan.getBillDate()))
				errorMap.put("INVALID_UPDATE_REQ_NOTMATCHED_BILLDATE", " Update bill date is not allowed");
			if (!challan.getBillIssuedDate().equals(searchchallan.getBillIssuedDate()))
				errorMap.put("INVALID_UPDATE_REQ_NOTMATCHED_BILLISSUEDATE", " Update party bill date is not allowed");
			if (!challan.getPaidDate().equals(searchchallan.getPaidDate()))
				errorMap.put("INVALID_UPDATE_REQ_NOTMATCHED_PAIDDATE", " Update Paid date is not allowed");
			if (!challan.getIsBillPaid() == searchchallan.getIsBillPaid())
				errorMap.put("INVALID_UPDATE_REQ_NOTMATCHED_BILLPAID", " Update bill paid is not allowed");
		}

		if (!errorMap.isEmpty())
			throw new CustomException(errorMap);

	}

}
