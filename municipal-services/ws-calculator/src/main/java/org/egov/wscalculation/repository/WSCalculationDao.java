package org.egov.wscalculation.repository;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.egov.wscalculation.web.models.*;

public interface WSCalculationDao {

	void saveMeterReading(MeterConnectionRequest meterConnectionRequest);
	
	List<MeterReading> searchMeterReadings(MeterReadingSearchCriteria criteria);
	
	ArrayList<String> searchTenantIds();

	ArrayList<String> searchConnectionNos(String connectionType, String tenantId);
	
	List<MeterReading> searchCurrentMeterReadings(MeterReadingSearchCriteria criteria);
	
	int isMeterReadingConnectionExist(List<String> ids);
	
	List<String> getConnectionsNoList(String tenantId, String connectionType);
	
	List<String> getTenantId();
	
	int isBillingPeriodExists(String connectionNo, String billingPeriod);
	Boolean isDemandExists(String tenantId, Long bilingDate,Long endTime, Set<String> connectionNos);

	List<String> getNonMeterConnectionsList(String tenantId, Long dayStartTime, Long dayEndTime);

	Boolean isDuplicateBulkDemandCall(String tenantId, String billingPeriod, Timestamp fromTime);

	void insertBulkDemandCall(String tenantId, String billingPeriod, String status, AuditDetails auditDetails);

	void updateStatusForOldRecords(String tenantId, Timestamp durationAgo, String billingPeriod, AuditDetails auditDetails);

	Boolean isConnectionExists(String tenantId, Long startTime, Long endTime, Set<String> connectionNos);

}
