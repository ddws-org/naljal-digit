package org.egov.wscalculation.repository.builder;


import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import java.math.BigInteger;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Set;

@Component
@Slf4j
public class DemandQueryBuilder {
    private final static String selectClause = "SELECT b.demandid FROM egbs_demanddetail_v1 b ";
    private final static String subQuery = "SELECT dt.demandid FROM egbs_demand_v1 d LEFT OUTER JOIN egbs_demanddetail_v1 dt ON d.id = dt.demandid AND dt.taxamount > dt.collectionamount " +
            "AND dt.taxheadcode = '10101'"+"AND d.status = 'ACTIVE'";
    private final static String firstWhereClause = "WHERE demandid IN (" ;
    private final static String secondWhereClause = ") AND b.tenantid = '";

    private final  static String groupByClause = " GROUP BY b.demandid " +
            "HAVING COUNT(*) = 1 ";

    public String getPenaltyQuery(String tenantId, BigInteger penaltyThresholdDate, Integer daysToBeSubstracted ) {
        //TODO: find out days
        long currentTimeMillis = System.currentTimeMillis();
        long tenDaysAgoMillis = Instant.ofEpochMilli(currentTimeMillis)
                .minus(daysToBeSubstracted, ChronoUnit.DAYS)
                .toEpochMilli();
        String subStringQuery ;
        subStringQuery = subQuery +  " AND d.tenantid = '"+tenantId+"'" +
                " AND d.createdtime < " + tenDaysAgoMillis + " AND d.taxperiodfrom > " + penaltyThresholdDate;
        String firstStringWhereClause;
        firstStringWhereClause = firstWhereClause + subStringQuery + secondWhereClause + tenantId+"'"+ groupByClause;
        String query ;
        query = selectClause + firstStringWhereClause;
        StringBuilder  builder = new StringBuilder(query);
        log.info("Query formed :" + builder.toString());
        return builder.toString();

    }
}