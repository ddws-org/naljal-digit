package org.egov.wscalculation.service;

import java.util.List;

import org.egov.common.contract.request.RequestInfo;
import org.egov.wscalculation.web.models.*;

public interface WSCalculationService {

	List<Calculation> getCalculation(CalculationReq calculationReq);

	void jobScheduler();

	void generateDemandBasedOnTimePeriod(RequestInfo requestInfo, boolean isSendMessage);
	void generateBulkDemandForTenant(BulkDemand bulkDemand);

	RollOutDashboard sendDataForRollOut(RollOutDashboardRequest rollOutDashboardRequest);
}
