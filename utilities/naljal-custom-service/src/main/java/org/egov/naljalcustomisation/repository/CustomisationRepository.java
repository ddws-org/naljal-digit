package org.egov.naljalcustomisation.repository;

import lombok.extern.slf4j.Slf4j;
import org.egov.naljalcustomisation.repository.builder.CustomisationQueryBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Slf4j
@Repository
public class CustomisationRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private CustomisationQueryBuilder queryBuilder;

    public List<String> getTenantId() {
        String query = queryBuilder.getDistinctTenantIds();
        log.info("Tenant Id's List Query : " + query);
        return jdbcTemplate.queryForList(query, String.class);
    }

    public List<String> getPendingCollection(String tenantId, String startDate, String endDate) {
        StringBuilder query = new StringBuilder(queryBuilder.PENDINGCOLLECTION);
        query.append(" and DMD.tenantid = '").append(tenantId).append("'")
                .append( " and taxperiodfrom  >= ").append( startDate)
                .append(" and  taxperiodto <= " ).append(endDate);
        log.info("Active pending collection query : " + query);
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

    public List<String>  getPreviousMonthExpensePayments(String tenantId, Long startDate, Long endDate) {
        StringBuilder query = new StringBuilder(queryBuilder.PREVIOUSMONTHEXPPAYMENT);
        query.append( " and PAYMTDTL.receiptdate  >= ").append( startDate)
                .append(" and  PAYMTDTL.receiptdate <= " ).append(endDate).append(" and PAYMTDTL.tenantid = '").append(tenantId).append("'");
        log.info("Previous month expense paid query : " + query);
        return jdbcTemplate.queryForList(query.toString(), String.class);
    }

    public List<String> getPreviousMonthExpenseExpenses(String tenantId, String startDate, String endDate) {
        StringBuilder query = new StringBuilder(queryBuilder.PREVIOUSMONTHEXPENSE);

        query.append(" and challan.paiddate  >= ").append(startDate).append(" and  challan.paiddate <= ")
                .append(endDate).append(" and challan.tenantid = '").append(tenantId).append("'");
        log.info("Previous month expense query : " + query);
        return jdbcTemplate.queryForList(query.toString(), String.class);
    }

    public List<String> getActiveExpenses(String tenantId) {
        StringBuilder query = new StringBuilder(queryBuilder.ACTIVEEXPENSECOUNTQUERY);
        query.append(" and tenantid = '").append(tenantId).append("'");
        log.info("Active expense query : " + query);
        return jdbcTemplate.queryForList(query.toString(), String.class);
    }

}
