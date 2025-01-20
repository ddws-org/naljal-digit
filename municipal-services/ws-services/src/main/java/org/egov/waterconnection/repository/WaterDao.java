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

	BigDecimal getArrearsAmount(SearchCriteria criteria);

	void postForMeterReading(WaterConnectionRequest waterConnectionrequest);
}
