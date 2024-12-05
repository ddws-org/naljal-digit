package org.egov.echallan.web.controllers;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import jakarta.validation.Valid;

import org.egov.common.contract.response.ResponseInfo;
import org.egov.echallan.model.Challan;
import org.egov.echallan.model.ChallanRequest;
import org.egov.echallan.model.ChallanResponse;
import org.egov.echallan.model.LastMonthSummary;
import org.egov.echallan.model.LastMonthSummaryResponse;
import org.egov.echallan.model.RequestInfoWrapper;
import org.egov.echallan.model.SearchCriteria;
import org.egov.echallan.repository.ChallanRepository;
import org.egov.echallan.repository.rowmapper.ChallanRowMapper;
import org.egov.echallan.service.ChallanService;
import org.egov.echallan.service.SchedulerService;
import org.egov.echallan.util.ResponseInfoFactory;
import org.egov.echallan.web.models.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("eChallan/v1")
public class ChallanController {

	@Autowired
	private ChallanService challanService;

	@Autowired
	private ResponseInfoFactory responseInfoFactory;
	
	@Autowired
	private SchedulerService schedulerService;
	

	@Autowired
	private ChallanRepository repository;
	
	@Autowired
	private ChallanRowMapper mapper;

	@PostMapping("/_create")
	public ResponseEntity<ChallanResponse> create(@Valid @RequestBody ChallanRequest challanRequest) {

		Challan challan = challanService.create(challanRequest);
		ResponseInfo resInfo = responseInfoFactory.createResponseInfoFromRequestInfo(challanRequest.getRequestInfo(), true);
		ChallanResponse response = ChallanResponse.builder().challans(Arrays.asList(challan))
				.responseInfo(resInfo)
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
	
	 @RequestMapping(value = "/_search", method = RequestMethod.POST)
	 public ResponseEntity<ChallanResponse> search(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
	                                                       @Valid @ModelAttribute SearchCriteria criteria) {
		 Map<String, String> finalData = new HashMap<String, String>();
	     List<Challan> challans = challanService.search(criteria, requestInfoWrapper.getRequestInfo(), finalData);
	     ChallanResponse response = ChallanResponse.builder().challans(challans).totalCount(mapper.getFull_count()).billData(finalData).responseInfo(
	               responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true))
	              .build();
	     return new ResponseEntity<>(response, HttpStatus.OK);
	}

	 @PostMapping("/_update")
	 public ResponseEntity<ChallanResponse> update(@Valid @RequestBody ChallanRequest challanRequest) {
		Map<String, String> finalData = new HashMap<String, String>();
		Challan challan = challanService.update(challanRequest, finalData);
		ResponseInfo resInfo = responseInfoFactory.createResponseInfoFromRequestInfo(challanRequest.getRequestInfo(), true);
		ChallanResponse response = ChallanResponse.builder().challans(Arrays.asList(challan))
				.responseInfo(resInfo)
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
		}


	@PostMapping("/_schedulermonthsummary")
	public void schedulermonthsummary(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
		schedulerService.sendMonthSummaryEvent(requestInfoWrapper.getRequestInfo());
	}

	@PostMapping("/_schedulernewexpenditure")
	public void schedulernewexpenditure(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
		schedulerService.sendNewExpenditureEvent(requestInfoWrapper.getRequestInfo());
	}

	@PostMapping("/_schedulermarkexpensebill")
	public void schedulermarkexpensebill(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
		schedulerService.sendMarkExpensebillEvent(requestInfoWrapper.getRequestInfo());
	}

	 
	@PostMapping("/_lastMonthSummary")
	public ResponseEntity<LastMonthSummaryResponse> lastMonthSummary(
			@RequestBody @Valid final RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute SearchCriteria criteria) {
		LastMonthSummary lastMonthSummary = challanService.getLastMonthSummary(criteria,
				requestInfoWrapper.getRequestInfo());

		LastMonthSummaryResponse response = LastMonthSummaryResponse.builder().LastMonthSummary(lastMonthSummary)
				.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
						true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
	
	@PostMapping("/_expenseDashboard")
	public ResponseEntity<ExpenseDashboardResponse> _expenseDashboard(
			@RequestBody @Valid final RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute SearchCriteria criteria) {
		ExpenseDashboard dashboardData = challanService.getExpenseDashboardData(criteria,
				requestInfoWrapper.getRequestInfo());

		ExpenseDashboardResponse response = ExpenseDashboardResponse.builder().ExpenseDashboard(dashboardData)
				.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
						true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
	

	 @RequestMapping(value = "/_plainsearch", method = RequestMethod.POST)
	 public ResponseEntity<ChallanResponse> planeSearch(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
	                                                       @Valid @ModelAttribute SearchCriteria criteria) {
		 Map<String, String> finalData = new HashMap<String, String>();
	     List<Challan> challans = challanService.planeSearch(criteria, requestInfoWrapper.getRequestInfo(), finalData);
	     ChallanResponse response = ChallanResponse.builder().challans(challans).totalCount(mapper.getFull_count()).billData(finalData).responseInfo(
	               responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true))
	              .build();
	     return new ResponseEntity<>(response, HttpStatus.OK);
	}


	 @PostMapping("/_chalanCollectionData")
		public ResponseEntity<ChallanCollectionDataResponse> _expenseCollectionData(
				@RequestBody @Valid final RequestInfoWrapper requestInfoWrapper,
				@Valid @ModelAttribute SearchCriteria criteria) {
			List<ChallanCollectionData> collectionData = challanService.getChallanCollectionData(criteria,
					requestInfoWrapper.getRequestInfo());

			ChallanCollectionDataResponse response = ChallanCollectionDataResponse.builder().ChallanCollectionData(collectionData)
					.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
							true))
					.build();
			return new ResponseEntity<>(response, HttpStatus.OK);
		}

	@PostMapping("/_updateCreateNoPayment")
	public ResponseEntity<ChallanResponse> updateCreateoPayment(@Valid @RequestBody ChallanRequest challanRequest) {
		Map<String, String> finalData = new HashMap<String, String>();
		Challan challan = challanService.updateCreateNoPayment(challanRequest, finalData);
		ResponseInfo resInfo = responseInfoFactory.createResponseInfoFromRequestInfo(challanRequest.getRequestInfo(), true);
		ChallanResponse response = ChallanResponse.builder().challans(Arrays.asList(challan))
				.responseInfo(resInfo)
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	@PostMapping("/_expenseBillReport")
	public ResponseEntity<ExpenseBillReportResponse> expenseBillReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
																	   @RequestParam("monthstartDate") String monthstartDate,
																	   @RequestParam("monthendDate") String monthendDate,
																	   @RequestParam("tenantId") String tenantId,
																	   @RequestParam("offset") Integer offset,
																	   @RequestParam("limit") Integer limit)
	{
		List<ExpenseBillReportData> expenseBillReport=challanService.expenseBillReport(requestInfoWrapper.getRequestInfo(),monthstartDate,monthendDate,tenantId,offset,limit);
		ExpenseBillReportResponse expenseBillReportResponse=
				ExpenseBillReportResponse.builder().ExpenseBillReportData(expenseBillReport)
						.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
								true))
						.build();
		return new ResponseEntity<>(expenseBillReportResponse,HttpStatus.OK);
	}

}
