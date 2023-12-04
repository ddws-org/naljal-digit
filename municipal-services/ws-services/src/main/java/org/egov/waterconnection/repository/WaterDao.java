package org.egov.waterconnection.repository;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import org.egov.common.contract.request.RequestInfo;
import org.egov.waterconnection.web.models.*;

public interface WaterDao {
	void saveWaterConnection(WaterConnectionRequest waterConnectionRequest);

	WaterConnectionResponse getWaterConnectionList(SearchCriteria criteria,RequestInfo requestInfo);
	
	void updateWaterConnection(WaterConnectionRequest waterConnectionRequest, boolean isStateUpdatable);

	List<String> getWCListFuzzySearch(SearchCriteria criteria);
	
	WaterConnectionResponse getWaterConnectionListForPlaneSearch(SearchCriteria criteria,RequestInfo requestInfo);

	void enrichFileStoreIds(WaterConnectionRequest waterConnectionRequest);

	void pushForEditNotification(WaterConnectionRequest waterConnectionRequest);

	BillingCycle getBillingCycle(String paymentId);

	List<Feedback> getFeebback(FeedbackSearchCriteria feedbackSearchCriteria);

	BigDecimal getTotalDemandAmount(SearchCriteria criteria);

	BigDecimal getActualCollectionAmount(SearchCriteria criteria);

	BigDecimal getPendingCollectionAmount(SearchCriteria criteria);

	BigDecimal getArrearsAmount(SearchCriteria criteria);

	Integer getResidentialCollectionAmount(SearchCriteria criteria);

	Integer getCommercialCollectionAmount(SearchCriteria criteria);

	Integer getOthersCollectionAmount(SearchCriteria criteria);

	Map<String, Object> getResidentialPaid(SearchCriteria criteria);

	Map<String, Object> getCommercialPaid(SearchCriteria criteria);

	Map<String, Object> getAllPaid(SearchCriteria criteria);

	BigDecimal getTotalAdvanceAdjustedAmount(SearchCriteria criteria);

	BigDecimal getTotalPendingPenaltyAmount(SearchCriteria criteria);

	BigDecimal getAdvanceCollectionAmount(SearchCriteria criteria);

	BigDecimal getPenaltyCollectionAmount(SearchCriteria criteria);

	void postForMeterReading(WaterConnectionRequest waterConnectionrequest);
}
