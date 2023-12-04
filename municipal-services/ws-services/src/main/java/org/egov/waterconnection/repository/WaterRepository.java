package org.egov.waterconnection.repository;

import java.util.Calendar;
import java.util.List;
import java.util.Map;

import org.egov.waterconnection.repository.builder.WsQueryBuilder;
import org.egov.waterconnection.service.WaterService;
import org.egov.waterconnection.util.WaterServicesUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import lombok.extern.slf4j.Slf4j;


@Slf4j
@Repository
public class WaterRepository {

	
	@Autowired
	private WsQueryBuilder queryBuilder;

	@Autowired
    private JdbcTemplate jdbcTemplate;
	
	@Autowired
	private WaterServicesUtil util;
	
	public List<String> getTenantId() {
		String query = queryBuilder.getDistinctTenantIds();
		log.info("Tenants List Query : " + query);
		return jdbcTemplate.queryForList(query, String.class);
	}


	public List<String> getPendingCollection(String tenantId, String startDate, String endDate) {
		StringBuilder query = new StringBuilder(WsQueryBuilder.PENDINGCOLLECTION);
		query.append(" and DMD.tenantid = '").append(tenantId).append("'")
		.append( " and taxperiodfrom  >= ").append( startDate)  
		.append(" and  taxperiodto <= " ).append(endDate);
		log.info("Active pending collection query : " + query);
		return jdbcTemplate.queryForList(query.toString(), String.class);
		
	}


	public List<String> getPreviousMonthExpenseExpenses(String tenantId, String startDate, String endDate) {
		StringBuilder query = new StringBuilder(queryBuilder.PREVIOUSMONTHEXPENSE);

		query.append(" and challan.paiddate  >= ").append(startDate).append(" and  challan.paiddate <= ")
				.append(endDate);
		log.info("Previous month expense query : " + query);
		return jdbcTemplate.queryForList(query.toString(), String.class);
	}


	public List<Map<String, Object>> getTodayCollection(String tenantId, String startDate, String endDate, String mode) {
		StringBuilder query = new StringBuilder();
		if(mode.equalsIgnoreCase("CASH")) {
		 query = new StringBuilder(queryBuilder.PREVIOUSDAYCASHCOLLECTION);
		}else {
			query = new StringBuilder(queryBuilder.PREVIOUSDAYONLINECOLLECTION);
		}
		query.append( " and p.transactiondate  >= ").append( startDate)  
		.append(" and  p.transactiondate <= " ).append(endDate).append(" and p.tenantId = '").append(tenantId).append("'"); 
		log.info("Previous Day collection query : " + query);
		List<Map<String, Object>> list =  jdbcTemplate.queryForList(query.toString());
		return list;
	}
	
	public Integer getTotalPendingCollection(String tenantId, Long endDate) {
		StringBuilder query = new StringBuilder(queryBuilder.PENDINGCOLLECTION);
		Calendar startDate = Calendar.getInstance();
		startDate.setTimeInMillis(endDate);
		int currentMonthNumber = startDate.get(Calendar.MONTH);
		if (currentMonthNumber < 3) {
			startDate.set(Calendar.YEAR, startDate.get(Calendar.YEAR) - 1);
		}
		startDate.set(Calendar.MONTH,3);
		startDate.set(Calendar.DAY_OF_MONTH, startDate.getActualMinimum(Calendar.DAY_OF_MONTH));
		util.setTimeToBeginningOfDay(startDate);
		query.append(" and  dmd.taxperiodto between " +  startDate.getTimeInMillis() +" and "+ endDate );
		query.append(" and dmd.tenantid = '").append(tenantId).append("'");
		System.out.println("Query in WS for pending collection: " + query.toString());
		return jdbcTemplate.queryForObject(query.toString(), Integer.class);
	}

	public Integer getNewDemand(String tenantId, Long startDate, Long endDate) {
		StringBuilder query = new StringBuilder(queryBuilder.NEWDEMAND);
		query.append(" and dmd.taxperiodto between " + startDate + " and " + endDate)
		.append(" and dmd.tenantId = '").append(tenantId).append("'");
		return jdbcTemplate.queryForObject(query.toString(), Integer.class);

	}

	public Integer getActualCollection(String tenantId, Long startDate, Long endDate) {
		StringBuilder query = new StringBuilder(queryBuilder.ACTUALCOLLECTION);
		query.append(" and py.transactionDate  >= ").append(startDate).append(" and py.transactionDate <= ")
				.append(endDate).append(" and py.tenantId = '").append(tenantId).append("'");
		return jdbcTemplate.queryForObject(query.toString(), Integer.class);

	}
	


}
