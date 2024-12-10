package org.egov.wscalculation.repository.builder;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Set;
import java.util.TimeZone;
import java.util.stream.Collectors;

import org.egov.wscalculation.config.WSCalculationConfiguration;
import org.egov.wscalculation.web.models.AuditDetails;
import org.egov.wscalculation.web.models.MeterReadingSearchCriteria;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

@Component
public class WSCalculatorQueryBuilder {

	@Autowired
	private WSCalculationConfiguration config;

	private static final String Offset_Limit_String = "OFFSET ? LIMIT ?";
	private final static String Query = "SELECT mr.id, mr.connectionNo as connectionId, mr.billingPeriod, mr.meterStatus, mr.lastReading, mr.lastReadingDate, mr.currentReading,"
			+ " mr.currentReadingDate, mr.createdBy as mr_createdBy, mr.tenantid, mr.lastModifiedBy as mr_lastModifiedBy,"
			+ " mr.createdTime as mr_createdTime, mr.lastModifiedTime as mr_lastModifiedTime FROM eg_ws_meterreading mr";

	private final static String noOfConnectionSearchQuery = "SELECT count(*) FROM eg_ws_meterreading WHERE";

	private final static String noOfConnectionSearchQueryForCurrentMeterReading = "select mr.currentReading from eg_ws_meterreading mr";

	private final static String tenantIdWaterConnectionSearchQuery = "select DISTINCT tenantid from eg_ws_connection";

	private final static String connectionNoWaterConnectionSearchQuery = "SELECT conn.connectionNo as connectionno FROM eg_ws_service wc INNER JOIN eg_ws_connection conn ON wc.connection_id = conn.id ";

	private static final String connectionNoListQuery = "SELECT distinct(conn.connectionno) FROM eg_ws_connection conn INNER JOIN eg_ws_service ws ON conn.id = ws.connection_id";

	private static final String distinctTenantIdsCriteria = "SELECT distinct(tenantid) FROM eg_ws_connection ws";

	private static final String PREVIOUS_BILLING_CYCLE_DEMAND = " select count(*) from egbs_demand_v1 ";
	
	private static final String PREVIOUS_BILLING_CYCLE_CONNECTION = " select count(*) from eg_ws_connection ";

	private static final String nonmeteredConnectionList = " select distinct(conn.connectionno) from eg_ws_connection conn join eg_ws_service ws on conn.id=ws.connection_id where ws.connectiontype='Non_Metered' and conn.status not IN ('Inactive') and conn.connectionno not in ( select distinct(consumercode) from egbs_demand_v1 d where d.businessservice='WS' and d.status not IN ('CANCELLED') ";

	private static final String duplicateBulkDemandCallQuery = "SELECT COUNT(*) FROM eg_ws_bulk_demand_batch where status='IN_PROGRESS' ";

	public String getDistinctTenantIds() {
		return distinctTenantIdsCriteria;
	}

	/**
	 * 
	 * @param criteria          would be meter reading criteria
	 * @param preparedStatement Prepared SQL Statement
	 * @return Query for given criteria
	 */
	public String getSearchQueryString(MeterReadingSearchCriteria criteria, List<Object> preparedStatement) {
		if (criteria.isEmpty()) {
			return null;
		}
		StringBuilder query = new StringBuilder(Query);
		if (!StringUtils.isEmpty(criteria.getTenantId())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" mr.tenantid= ? ");
			preparedStatement.add(criteria.getTenantId());
		}
		if (!CollectionUtils.isEmpty(criteria.getConnectionNos())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" mr.connectionNo IN (").append(createQuery(criteria.getConnectionNos())).append(" )");
			addToPreparedStatement(preparedStatement, criteria.getConnectionNos());
		}
		addOrderBy(query);
		return addPaginationWrapper(query, preparedStatement, criteria);
	}

	private String createQuery(Set<String> ids) {
		StringBuilder builder = new StringBuilder();
		int length = ids.size();
		for (int i = 0; i < length; i++) {
			builder.append(" ?");
			if (i != length - 1)
				builder.append(",");
		}
		return builder.toString();
	}

	private void addToPreparedStatement(List<Object> preparedStatement, Set<String> ids) {
		preparedStatement.addAll(ids);
	}

	private void addClauseIfRequired(List<Object> values, StringBuilder queryString) {
		if (values.isEmpty())
			queryString.append(" WHERE ");
		else {
			queryString.append(" AND");
		}
	}

	private String addPaginationWrapper(StringBuilder query, List<Object> preparedStmtList,
			MeterReadingSearchCriteria criteria) {
		query.append(" ").append(Offset_Limit_String);
		Integer limit = config.getMeterReadingDefaultLimit();
		Integer offset = config.getMeterReadingDefaultOffset();

		if (criteria.getLimit() != null && criteria.getLimit() <= config.getMeterReadingDefaultLimit())
			limit = criteria.getLimit();

		if (criteria.getLimit() != null && criteria.getLimit() > config.getMeterReadingDefaultLimit())
			limit = config.getMeterReadingDefaultLimit();

		if (criteria.getOffset() != null)
			offset = criteria.getOffset();

		preparedStmtList.add(offset);
		preparedStmtList.add(limit + offset);
		return query.toString();
	}

	public String getNoOfMeterReadingConnectionQuery(Set<String> connectionIds, List<Object> preparedStatement) {
		StringBuilder query = new StringBuilder(noOfConnectionSearchQuery);
		query.append(" connectionNo in (").append(createQuery(connectionIds)).append(" )");
		addToPreparedStatement(preparedStatement, connectionIds);
		return query.toString();
	}

	public String getCurrentReadingConnectionQuery(MeterReadingSearchCriteria criteria,
			List<Object> preparedStatement) {
		if (criteria.isEmpty()) {
			return null;
		}
		StringBuilder query = new StringBuilder(noOfConnectionSearchQueryForCurrentMeterReading);
		if (!StringUtils.isEmpty(criteria.getTenantId())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" mr.tenantid= ? ");
			preparedStatement.add(criteria.getTenantId());
		}
		if (!CollectionUtils.isEmpty(criteria.getConnectionNos())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" mr.connectionNo IN (").append(createQuery(criteria.getConnectionNos())).append(" )");
			addToPreparedStatement(preparedStatement, criteria.getConnectionNos());
		}
		query.append(" ORDER BY mr.currentReadingDate DESC LIMIT 1");
		return query.toString();
	}

	public String getTenantIdConnectionQuery() {
		return tenantIdWaterConnectionSearchQuery;
	}

	private void addOrderBy(StringBuilder query) {
		query.append(" ORDER BY mr.currentReadingDate DESC");
	}

	public String getConnectionNumberFromWaterServicesQuery(List<Object> preparedStatement, String connectionType,
			String tenentId) {
		StringBuilder query = new StringBuilder(connectionNoWaterConnectionSearchQuery);
		if (!StringUtils.isEmpty(connectionType)) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" wc.connectionType = ? ");
			preparedStatement.add(connectionType);
		}

		if (!StringUtils.isEmpty(tenentId)) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.tenantId = ? ");
			preparedStatement.add(tenentId);
		}
		return query.toString();

	}

	public String getConnectionNumberList(String tenantId, String connectionType, List<Object> preparedStatement) {
		StringBuilder query = new StringBuilder(connectionNoListQuery);
		// Add connection type
		addClauseIfRequired(preparedStatement, query);
		query.append(" ws.connectiontype = ? ");
		preparedStatement.add(connectionType);
		// add tenantid
		addClauseIfRequired(preparedStatement, query);
		query.append(" conn.tenantid = ? ");
		preparedStatement.add(tenantId);
		addClauseIfRequired(preparedStatement, query);
		query.append(" conn.connectionno is not null");
		return query.toString();

	}

	public String getNonMeteredConnectionsList(String tenantId, Long dayStartTime, Long dayEndTime,
			List<Object> preparedStatement) {
		StringBuilder query = new StringBuilder(nonmeteredConnectionList);

		// add tenantid
		query.append(" and d.tenantid = ? ");
		preparedStatement.add(tenantId);
		addClauseIfRequired(preparedStatement, query);
		query.append(" ( d.taxperiodto  between " + dayStartTime + " and " + dayEndTime +" ) )");
		query.append(" and conn.tenantid = ?  ");
		preparedStatement.add(tenantId);
		return query.toString();

	}

	public String getDuplicateBulkDemandCallQuery(String tenantId, String billingPeriod, Timestamp fromTime, List<Object> preparedStatement) {
		StringBuilder query = new StringBuilder(duplicateBulkDemandCallQuery);

		query.append(" and tenantId = ?");
		preparedStatement.add(tenantId);
		addClauseIfRequired(preparedStatement,query);
		query.append(" billingPeriod = ?");
		preparedStatement.add(billingPeriod);
		addClauseIfRequired(preparedStatement,query);
		query.append(" createdTime > ?");
		preparedStatement.add(fromTime.getTime());

		return query.toString();
	}

	public String getInsertBulkDemandCallQuery(String tenantId, String billingPeriod, String status, AuditDetails auditDetails, List<Object> preparedStatement) {
		StringBuilder query = new StringBuilder("INSERT INTO eg_ws_bulk_demand_batch (tenantId, billingPeriod, status, createdBy, lastModifiedBy, createdTime, lastModifiedTime) VALUES (?, ?, ?, ?, ?, ?, ?)");

		preparedStatement.add(tenantId);
		preparedStatement.add(billingPeriod);
		preparedStatement.add(status);

		preparedStatement.add(auditDetails.getCreatedBy());
		preparedStatement.add(auditDetails.getLastModifiedBy());
		preparedStatement.add(auditDetails.getCreatedTime());
		preparedStatement.add(auditDetails.getLastModifiedTime());

		return query.toString();
	}

	public String isBillingPeriodExists(String connectionNo, String billingPeriod, List<Object> preparedStatement) {
		SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
		Date billingStrartDate = null;
		Calendar startCal = Calendar.getInstance(TimeZone.getTimeZone("Asia/Kolkata"));
		try {
			billingStrartDate = sdf.parse(billingPeriod.split("-")[0].trim());
			startCal.setTime(billingStrartDate);
		} catch (ParseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		StringBuilder query = new StringBuilder(noOfConnectionSearchQuery);
		query.append(" connectionNo = ? ");
		preparedStatement.add(connectionNo);
		addClauseIfRequired(preparedStatement, query);
		query.append(" ? between lastreadingdate and currentreadingdate ");
		preparedStatement.add(startCal.getTimeInMillis());
		return query.toString();
	}

	public String previousBillingCycleDemandQuery(Set<String> connectionNos, String tenantId, Long startDate,
			Long endDate, List<Object> preparedStmtList) {

		StringBuilder builder = new StringBuilder(PREVIOUS_BILLING_CYCLE_DEMAND);

		if (!CollectionUtils.isEmpty(connectionNos)) {
			addClauseIfRequired(preparedStmtList, builder);
			builder.append(" consumercode IN (").append(createQuery(connectionNos)).append(")");
			addToPreparedStatement(preparedStmtList, connectionNos);
		}
		if (startDate != null && endDate != null) {
			addClauseIfRequired(preparedStmtList, builder);
			builder.append(" taxperiodto between  ?  and  ? ");
			preparedStmtList.add(startDate);
			preparedStmtList.add(endDate);
			// todo taxperiod to is in between startdate and enddate of previous billing
			// cycle
		}

		if (!StringUtils.isEmpty(tenantId)) {
			addClauseIfRequired(preparedStmtList, builder);
			builder.append(" tenantId =?  ");
			preparedStmtList.add(tenantId);
		}
		if(!CollectionUtils.isEmpty(preparedStmtList))
			builder.append("and status not IN ('CANCELLED')");
		
		System.out.println("Final query ::" + builder.toString());
		return builder.toString();
	}

	public String previousBillingCycleConnectionQuery(Set<String> connectionNos, String tenantId, Long startDate,
			Long endDate, List<Object> preparedStmtList) {

		StringBuilder builder = new StringBuilder(PREVIOUS_BILLING_CYCLE_CONNECTION);

		if (!CollectionUtils.isEmpty(connectionNos)) {
			addClauseIfRequired(preparedStmtList, builder);
			builder.append(" connectionno IN (").append(createQuery(connectionNos)).append(")");
			addToPreparedStatement(preparedStmtList, connectionNos);
		}
		if (startDate != null && endDate != null) {
			addClauseIfRequired(preparedStmtList, builder);
			builder.append(" previousreadingdate between  ?  and  ? ");
			preparedStmtList.add(startDate);
			preparedStmtList.add(endDate);
		}
		if (!StringUtils.isEmpty(tenantId)) {
			addClauseIfRequired(preparedStmtList, builder);
			builder.append(" tenantId =?  ");
			preparedStmtList.add(tenantId);
		}
		System.out.println("Final conn query ::" + builder.toString());
		return builder.toString();
	}

}
