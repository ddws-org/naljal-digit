package org.egov.waterconnection.web.controller;

import java.util.List;
import java.util.Map;

import jakarta.validation.Valid;

import org.egov.waterconnection.constants.WCConstants;
import org.egov.waterconnection.service.SchedulerService;
import org.egov.waterconnection.service.WaterService;
import org.egov.waterconnection.util.ResponseInfoFactory;
import org.egov.waterconnection.web.models.*;
import org.egov.waterconnection.web.models.BillReportData;
import org.egov.waterconnection.web.models.BillReportResponse;
import org.egov.waterconnection.web.models.CollectionReportData;
import org.egov.waterconnection.web.models.CollectionReportResponse;
import org.egov.waterconnection.web.models.FeedbackRequest;
import org.egov.waterconnection.web.models.FeedbackResponse;
import org.egov.waterconnection.web.models.FeedbackSearchCriteria;
import org.egov.waterconnection.web.models.LastMonthSummary;
import org.egov.waterconnection.web.models.LastMonthSummaryResponse;
import org.egov.waterconnection.web.models.RequestInfoWrapper;
import org.egov.waterconnection.web.models.RevenueCollectionData;
import org.egov.waterconnection.web.models.RevenueCollectionDataResponse;
import org.egov.waterconnection.web.models.RevenueDashboard;
import org.egov.waterconnection.web.models.RevenueDashboardResponse;
import org.egov.waterconnection.web.models.SearchCriteria;
import org.egov.waterconnection.web.models.WaterConnection;
import org.egov.waterconnection.web.models.WaterConnectionRequest;
import org.egov.waterconnection.web.models.WaterConnectionResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;

import io.swagger.models.parameters.QueryParameter;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
@RestController
@RequestMapping("/wc")
public class WaterController {

	@Autowired
	private WaterService waterService;

	@Autowired
	private final ResponseInfoFactory responseInfoFactory;

	
	@Autowired
	private SchedulerService schedulerService;

	@RequestMapping(value = "/_create", method = RequestMethod.POST, produces = "application/json")
	public ResponseEntity<WaterConnectionResponse> createWaterConnection(
			@Valid @RequestBody WaterConnectionRequest waterConnectionRequest) {
		List<WaterConnection> waterConnection = waterService.createWaterConnection(waterConnectionRequest);
		WaterConnectionResponse response = WaterConnectionResponse.builder().waterConnection(waterConnection)
				.responseInfo(responseInfoFactory
						.createResponseInfoFromRequestInfo(waterConnectionRequest.getRequestInfo(), true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	@RequestMapping(value = "/_search", method = RequestMethod.POST)
	public ResponseEntity<WaterConnectionResponse> search(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute SearchCriteria criteria) {
		WaterConnectionResponse response = waterService.search(criteria, requestInfoWrapper.getRequestInfo());
		response.setResponseInfo(
				responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true));
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	@RequestMapping(value = "/_update", method = RequestMethod.POST, produces = "application/json")
	public ResponseEntity<WaterConnectionResponse> updateWaterConnection(
			@Valid @RequestBody WaterConnectionRequest waterConnectionRequest) {
		List<WaterConnection> waterConnection = waterService.updateWaterConnection(waterConnectionRequest);
		WaterConnectionResponse response = WaterConnectionResponse.builder().waterConnection(waterConnection)
				.responseInfo(responseInfoFactory
						.createResponseInfoFromRequestInfo(waterConnectionRequest.getRequestInfo(), true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);

	}
	
	@RequestMapping(value = "/_submitfeedback", method = RequestMethod.POST)
	public ResponseEntity<String> submitFeedback(@Valid @RequestBody FeedbackRequest feedbackrequest) {

		waterService.submitFeedback(feedbackrequest);

		return new ResponseEntity<>(WCConstants.SUCCESSFUL_FEEDBACK_SUBMIT, HttpStatus.OK);

	}

	@RequestMapping(value = "/_getfeedback", method = RequestMethod.POST)
	public ResponseEntity<FeedbackResponse> getFeedback(
			@Valid @ModelAttribute FeedbackSearchCriteria feedbackSearchCriteria, @RequestBody RequestInfoWrapper requestInfoWrapper) throws JsonMappingException, JsonProcessingException {

		Object feedbackList = waterService.getFeedback(feedbackSearchCriteria);

		FeedbackResponse feedbackResponse = FeedbackResponse.builder()
				.responseInfo(responseInfoFactory
						.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true))
				.feedback(feedbackList).build();

		return new ResponseEntity<>(feedbackResponse, HttpStatus.OK);
	}
	@PostMapping("/_revenueDashboard")
	public ResponseEntity<RevenueDashboardResponse> _revenueDashboard(
			@RequestBody @Valid final RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute SearchCriteria criteria) {
		RevenueDashboard dashboardData = waterService.getRevenueDashboardData(criteria,
				requestInfoWrapper.getRequestInfo());

		RevenueDashboardResponse response = RevenueDashboardResponse.builder().RevenueDashboard(dashboardData)
				.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
						true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
	
	@PostMapping("/_schedulerpendingcollection")
	public void schedulerpendingcollection(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
		schedulerService.sendPendingCollectionEvent(requestInfoWrapper.getRequestInfo());
	}

	@PostMapping("/_schedulergeneratedemand")
	public void schedulergeneratedemand(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
		schedulerService.sendGenerateDemandEvent(requestInfoWrapper.getRequestInfo());
	}
	
	@PostMapping("/_schedulerTodaysCollection")
	public void schedulerTodaysCollection(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper) {
		schedulerService.sendTodaysCollection(requestInfoWrapper.getRequestInfo());
	}
	
	
	@PostMapping("/_lastMonthSummary")
	public ResponseEntity<LastMonthSummaryResponse> lastMonthSummary(
			@RequestBody @Valid final RequestInfoWrapper requestInfoWrapper,
			@Valid @ModelAttribute SearchCriteria criteria) {
		LastMonthSummary lastMonthSummary = waterService.getLastMonthSummary(criteria,
				requestInfoWrapper.getRequestInfo());

		LastMonthSummaryResponse response = LastMonthSummaryResponse.builder().LastMonthSummary(lastMonthSummary)
				.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
						true))
				.build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}
	
	 @PostMapping("/fuzzy/_search")
	    public ResponseEntity<WaterConnectionResponse> fuzzySearch(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
	                                                      @Valid @ModelAttribute SearchCriteria criteria) {

		 WaterConnectionResponse response = waterService.getWCListFuzzySearch(criteria, requestInfoWrapper.getRequestInfo()); 
		 response.setResponseInfo(
					responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true));
			return new ResponseEntity<>(response, HttpStatus.OK);
	    }
	 
	 @RequestMapping(value = "/_plainsearch", method = RequestMethod.POST)
		public ResponseEntity<WaterConnectionResponse> planeSearch(
				@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
				@Valid @ModelAttribute SearchCriteria criteria) {
			WaterConnectionResponse response = waterService.planeSearch(criteria, requestInfoWrapper.getRequestInfo());
			response.setResponseInfo(
					responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true));
	    return new ResponseEntity<>(response, HttpStatus.OK);
		}
  
	 @PostMapping("/_revenueCollectionData")
		public ResponseEntity<RevenueCollectionDataResponse> _revenueCollectionData(
				@RequestBody @Valid final RequestInfoWrapper requestInfoWrapper,
				@Valid @ModelAttribute SearchCriteria criteria) {
			List<RevenueCollectionData> collectionData = waterService.getRevenueCollectionData(criteria,
					requestInfoWrapper.getRequestInfo());

			RevenueCollectionDataResponse response = RevenueCollectionDataResponse.builder().RevenueCollectionData(collectionData)
					.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
							true))
					.build();

			return new ResponseEntity<>(response, HttpStatus.OK);
		}
	 
	 @RequestMapping(value = "/_billReport", method = RequestMethod.POST)
		public ResponseEntity<BillReportResponse> billReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
				@RequestParam(value = "demandStartDate", required = true) String demandStartDate,@RequestParam(value = "demandEndDate", required = true) String demandEndDate,@RequestParam(value = "tenantId",required = true) String tenantId,@RequestParam(value="offset",required = true) Integer offset,@RequestParam(value="limit",required = true)Integer limit,@RequestParam(value="sortOrder") String sortOrder) {
		 List<BillReportData> billReport = waterService.billReport(demandStartDate,demandEndDate,tenantId,offset,limit,sortOrder,requestInfoWrapper.getRequestInfo());

			BillReportResponse response =  BillReportResponse.builder().BillReportData(billReport)
					.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
							true))
					.build();
			return new ResponseEntity<>(response, HttpStatus.OK);
		}
	 
	 @RequestMapping(value = "/_collectionReport", method = RequestMethod.POST)
		public ResponseEntity<CollectionReportResponse> collectionReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
				@RequestParam(value = "paymentStartDate", required = true) String paymentStartDate,@RequestParam(value = "paymentEndDate", required = true) String paymentEndDate,@RequestParam(value = "tenantId",required = true) String tenantId, @RequestParam(value="offset",required = true) Integer offset, @RequestParam(value="limit",required = true)Integer limit, @RequestParam(value="sortOrder") String sortOrder) {
		 List<CollectionReportData> collectionReport = waterService.collectionReport(paymentStartDate,paymentEndDate,tenantId,offset,limit,sortOrder,requestInfoWrapper.getRequestInfo());

			CollectionReportResponse response =  CollectionReportResponse.builder().CollectionReportData(collectionReport)
					.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),
							true))
					.build();
			return new ResponseEntity<>(response, HttpStatus.OK);
		}
	@RequestMapping(value = "/_inactiveConsumerReport",method = RequestMethod.POST)
	   public ResponseEntity<InactiveConsumerReportResponse> inactiveConsumerReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,
			  @RequestParam(value="monthStartDate",required = true) String monthStartDate,@RequestParam(value="monthEndDate",required = true) String monthEndDate,
			  @RequestParam(value = "tenantId",required = true)	String tenantId,@RequestParam(value="offset",required = true) Integer offset, @RequestParam(value="limit",required = true)Integer limit)
	{
		List<InactiveConsumerReportData> inactiveConsumerReport=waterService.inactiveConsumerReport(monthStartDate,monthEndDate,tenantId,offset,limit,requestInfoWrapper.getRequestInfo());
		InactiveConsumerReportResponse response=InactiveConsumerReportResponse.builder().InactiveConsumerReportData(inactiveConsumerReport)
				.responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),true)).build();

        return new ResponseEntity<>(response,HttpStatus.OK);
    }
	@RequestMapping(value = "/_countWCbyDemandGenerationDate", method = RequestMethod.POST)
	   public ResponseEntity<WaterConnectionByDemandGenerationDateResponse> countWCbyDemandGenerationDate(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper, @Valid @ModelAttribute SearchCriteria criteria) {
		WaterConnectionByDemandGenerationDateResponse response = waterService.countWCbyDemandGennerationDate(criteria, requestInfoWrapper.getRequestInfo());
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	@PostMapping("/consumers/demand-not-generated")
	public ResponseEntity<WaterConnectionResponse> getConsumersWithDemandNotGenerated(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,@RequestParam(value="previousMeterReading") String previousMeterReading,@RequestParam (value="tenantId") String tenantId)
	{
		WaterConnectionResponse response= waterService.getConsumersWithDemandNotGenerated(previousMeterReading,tenantId,requestInfoWrapper.getRequestInfo());
		response.setResponseInfo(
				responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true));
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	@PostMapping("/ledger-report")
	public ResponseEntity<LedgerReportResponse> getLedgerReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper, @RequestParam String consumercode, @RequestParam String tenantId, @RequestParam Integer offset, @RequestParam Integer limit, @RequestParam String year) {
		List<Map<String, Object>> list = waterService.ledgerReport(consumercode, tenantId, offset, limit, year,requestInfoWrapper);
		LedgerReportResponse response = LedgerReportResponse.builder().ledgerReport(list).
				responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(), true)).
				tenantName(tenantId).financialYear(year).build();
		return new ResponseEntity<>(response, HttpStatus.OK);
	}

	@PostMapping("/month-report")
	public ResponseEntity<?> getMonthReport(@Valid @RequestBody RequestInfoWrapper requestInfoWrapper,@RequestParam String startDate,@RequestParam String endDate,@RequestParam String tenantId, @RequestParam Integer offset, @RequestParam Integer limit,@RequestParam String sortOrder)
	{
		List<MonthReport> monthReportList=waterService.monthReport(startDate,endDate,tenantId,offset,limit,sortOrder);
		MonthReportResponse monthReportResponse=MonthReportResponse.builder().monthReport(monthReportList).
				tenantName(tenantId).month(startDate.concat("-"+endDate)).
				responseInfo(responseInfoFactory.createResponseInfoFromRequestInfo(requestInfoWrapper.getRequestInfo(),true)).build();
		return new ResponseEntity<>(monthReportResponse,HttpStatus.OK);
	}

}
