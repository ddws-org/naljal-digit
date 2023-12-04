package org.egov.waterconnection.service;

import java.util.List;

import javax.validation.Valid;

import org.egov.common.contract.request.RequestInfo;
import org.egov.waterconnection.web.models.*;
import org.egov.waterconnection.web.models.BillReportData;
import org.egov.waterconnection.web.models.BillReportResponse;
import org.egov.waterconnection.web.models.CollectionReportData;
import org.egov.waterconnection.web.models.Feedback;
import org.egov.waterconnection.web.models.FeedbackRequest;
import org.egov.waterconnection.web.models.FeedbackSearchCriteria;

import org.egov.waterconnection.web.models.LastMonthSummary;
import org.egov.waterconnection.web.models.RevenueCollectionData;
import org.egov.waterconnection.web.models.RevenueDashboard;

import org.egov.waterconnection.web.models.SearchCriteria;
import org.egov.waterconnection.web.models.WaterConnection;
import org.egov.waterconnection.web.models.WaterConnectionRequest;
import org.egov.waterconnection.web.models.WaterConnectionResponse;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonMappingException;

public interface WaterService {

	List<WaterConnection> createWaterConnection(WaterConnectionRequest waterConnectionRequest);

	WaterConnectionResponse search(SearchCriteria criteria, RequestInfo requestInfo);
	
	List<WaterConnection> updateWaterConnection(WaterConnectionRequest waterConnectionRequest);
	
	void submitFeedback( FeedbackRequest feedbackrequest);

	Object getFeedback( FeedbackSearchCriteria feedBackSearchCriteria) throws JsonMappingException, JsonProcessingException;

	LastMonthSummary getLastMonthSummary(@Valid SearchCriteria criteria, RequestInfo requestInfo);

	RevenueDashboard getRevenueDashboardData(@Valid SearchCriteria criteria, RequestInfo requestInfo);

	WaterConnectionResponse getWCListFuzzySearch(SearchCriteria criteria, RequestInfo requestInfo);
	
	WaterConnectionResponse planeSearch(SearchCriteria criteria, RequestInfo requestInfo);

	List<RevenueCollectionData> getRevenueCollectionData(@Valid SearchCriteria criteria, RequestInfo requestInfo);

	List<BillReportData> billReport(@Valid String demandStartDate, @Valid String demandEndDate, @Valid String tenantId, @Valid Integer offset, @Valid Integer limit, @Valid String sortOrder, RequestInfo requestInfo);

	List<CollectionReportData> collectionReport(String paymentStartDate, String paymentEndDate, String tenantId,@Valid Integer offset, @Valid Integer limit, @Valid String sortOrder,
			RequestInfo requestInfo);
	
	List<InactiveConsumerReportData> inactiveConsumerReport(String monthStartDate,String monthEndDate,String tenantId, @Valid Integer offset, @Valid Integer limit, RequestInfo requestInfo);

}
