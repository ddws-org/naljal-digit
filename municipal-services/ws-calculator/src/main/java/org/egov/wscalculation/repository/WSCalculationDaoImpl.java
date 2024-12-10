package org.egov.wscalculation.repository;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.egov.wscalculation.producer.WSCalculationProducer;
import org.egov.wscalculation.repository.builder.WSCalculatorQueryBuilder;
import org.egov.wscalculation.repository.rowmapper.DemandSchedulerRowMapper;
import org.egov.wscalculation.repository.rowmapper.MeterReadingCurrentReadingRowMapper;
import org.egov.wscalculation.repository.rowmapper.MeterReadingRowMapper;
import org.egov.wscalculation.web.models.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Repository
public class WSCalculationDaoImpl implements WSCalculationDao {

	@Autowired
	private WSCalculationProducer wSCalculationProducer;

	@Autowired
	private WSCalculatorQueryBuilder queryBuilder;

	@Autowired
	private JdbcTemplate jdbcTemplate;

	@Autowired
	private MeterReadingRowMapper meterReadingRowMapper;

	@Autowired
	private MeterReadingCurrentReadingRowMapper currentMeterReadingRowMapper;

	@Autowired
	private DemandSchedulerRowMapper demandSchedulerRowMapper;

	@Value("${egov.meterservice.createmeterconnection}")
	private String createMeterConnection;

	/**
	 * 
	 * @param meterConnectionRequest MeterConnectionRequest contains meter reading
	 *                               connection to be created
	 */
	@Override
	public void saveMeterReading(MeterConnectionRequest meterConnectionRequest) {
		wSCalculationProducer.push(createMeterConnection, meterConnectionRequest);
	}

	/**
	 * 
	 * @param criteria would be meter reading criteria
	 * @return List of meter readings based on criteria
	 */
	@Override
	public List<MeterReading> searchMeterReadings(MeterReadingSearchCriteria criteria) {
		List<Object> preparedStatement = new ArrayList<>();
		String query = queryBuilder.getSearchQueryString(criteria, preparedStatement);
		if (query == null)
			return Collections.emptyList();
		log.debug("Query: " + query);
		log.debug("Prepared Statement" + preparedStatement.toString());
		return jdbcTemplate.query(query, preparedStatement.toArray(), meterReadingRowMapper);
	}

	@Override
	public List<MeterReading> searchCurrentMeterReadings(MeterReadingSearchCriteria criteria) {
		List<Object> preparedStatement = new ArrayList<>();
		String query = queryBuilder.getCurrentReadingConnectionQuery(criteria, preparedStatement);
		if (query == null)
			return Collections.emptyList();
		log.debug("Query: " + query);
		log.debug("Prepared Statement" + preparedStatement.toString());
		return jdbcTemplate.query(query, preparedStatement.toArray(), currentMeterReadingRowMapper);
	}

	/**
	 * 
	 * @param ids of string of connection ids on which search is performed
	 * @return total number of meter reading objects if present in the table for
	 *         that particular connection ids
	 */
	@Override
	public int isMeterReadingConnectionExist(List<String> ids) {
		Set<String> connectionIds = new HashSet<>(ids);
		List<Object> preparedStatement = new ArrayList<>();
		String query = queryBuilder.getNoOfMeterReadingConnectionQuery(connectionIds, preparedStatement);
		log.debug("Query: " + query);
		return jdbcTemplate.queryForObject(query, preparedStatement.toArray(), Integer.class);
	}

	@Override
	public ArrayList<String> searchTenantIds() {
		ArrayList<String> tenantIds = new ArrayList<>();
		String query = queryBuilder.getTenantIdConnectionQuery();
		if (query == null)
			return tenantIds;
		log.debug("Query: " + query);
		tenantIds = (ArrayList<String>) jdbcTemplate.queryForList(query, String.class);
		return tenantIds;
	}

	@Override
	public ArrayList<String> searchConnectionNos(String connectionType, String tenantId) {
		ArrayList<String> connectionNos = new ArrayList<>();
		List<Object> preparedStatement = new ArrayList<>();
		String query = queryBuilder.getConnectionNumberFromWaterServicesQuery(preparedStatement, connectionType,
				tenantId);
		if (query == null)
			return connectionNos;
		log.info("Query: " + query);

		connectionNos = (ArrayList<String>) jdbcTemplate.query(query, preparedStatement.toArray(),
				demandSchedulerRowMapper);
		return connectionNos;
	}

	@Override
	public List<String> getConnectionsNoList(String tenantId, String connectionType) {
		List<Object> preparedStatement = new ArrayList<>();
		String query = queryBuilder.getConnectionNumberList(tenantId, connectionType, preparedStatement);
		log.info("water " + connectionType + " connection list : " + query);
		return jdbcTemplate.query(query, preparedStatement.toArray(), demandSchedulerRowMapper);
	}

	@Override
	public List<String> getNonMeterConnectionsList(String tenantId, Long dayStartTime, Long dayEndTime) {
		List<Object> preparedStatement = new ArrayList<>();
		String query = queryBuilder.getNonMeteredConnectionsList(tenantId, dayStartTime, dayEndTime, preparedStatement);
		log.info("water NMconnection list query: " + query);
		return jdbcTemplate.query(query, preparedStatement.toArray(), demandSchedulerRowMapper);
	}

	@Override
	public Boolean isDuplicateBulkDemandCall(String tenantId, String billingPeriod, Timestamp fromTime) {
		List<Object> preparedStatement = new ArrayList<>();
		String query = queryBuilder.getDuplicateBulkDemandCallQuery(tenantId, billingPeriod, fromTime, preparedStatement);
		int count = jdbcTemplate.queryForObject(query, preparedStatement.toArray(), Integer.class);
		return count > 0;
	}


	@Override
	public void insertBulkDemandCall(String tenantId, String billingPeriod, String status, AuditDetails auditDetails) {
		List<Object> preparedStatement = new ArrayList<>();
		String query = queryBuilder.getInsertBulkDemandCallQuery(tenantId, billingPeriod, status, auditDetails, preparedStatement);
		jdbcTemplate.update(query, preparedStatement.toArray());
	}

	@Override
	public List<String> getTenantId() {
		String query = queryBuilder.getDistinctTenantIds();
		log.info("Tenant Id's List Query : " + query);
		return jdbcTemplate.queryForList(query, String.class);
	}

	@Override
	public void updateStatusForOldRecords(String tenantId,Timestamp durationAgo,String billingPeriod, AuditDetails auditDetails) {
		String query = "UPDATE eg_ws_bulk_demand_batch SET status = 'EXPIRED', lastModifiedBy = ?, lastModifiedTime = ? WHERE tenantId = ? AND billingPeriod = ? AND createdTime < ?";
		jdbcTemplate.update(query,auditDetails.getLastModifiedBy(), auditDetails.getLastModifiedTime(),tenantId,billingPeriod, durationAgo.getTime());
	}

	@Override
	public int isBillingPeriodExists(String connectionNo, String billingPeriod) {
		List<Object> preparedStatement = new ArrayList<>();
		String query = queryBuilder.isBillingPeriodExists(connectionNo, billingPeriod, preparedStatement);
		log.info("Is BillingPeriod Exits Query: " + query);
		return jdbcTemplate.queryForObject(query, preparedStatement.toArray(), Integer.class);
	}

	public Boolean isDemandExists(String tenantId, Long startDate,  Long endTime, Set<String> connectionNos) {
		List<Object> preparedStmtList = new ArrayList<>();
		String query = queryBuilder.previousBillingCycleDemandQuery(connectionNos, tenantId, startDate, endTime,
				preparedStmtList);
		Integer count = jdbcTemplate.queryForObject(query, preparedStmtList.toArray(), Integer.class);
		return count > 0;
	}
	public Boolean isConnectionExists(String tenantId, Long startDate,  Long endTime, Set<String> connectionNos) {
		List<Object> preparedStmtList = new ArrayList<>();
		String query = queryBuilder.previousBillingCycleConnectionQuery(connectionNos, tenantId, startDate, endTime,
				preparedStmtList);
		Integer count = jdbcTemplate.queryForObject(query, preparedStmtList.toArray(), Integer.class);
		return count > 0;
	}

}
