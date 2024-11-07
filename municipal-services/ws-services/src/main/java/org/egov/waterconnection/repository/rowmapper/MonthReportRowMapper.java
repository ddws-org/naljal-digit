package org.egov.waterconnection.repository.rowmapper;

import org.egov.waterconnection.web.models.MonthReport;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Component;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

@Component
public class MonthReportRowMapper implements RowMapper<MonthReport>
{
    @Override
    public MonthReport mapRow(ResultSet rs, int rowNum) throws SQLException {
        return MonthReport.builder()
                .demandGenerationDate(rs.getLong("demandGenerationDate"))
                .penalty(rs.getBigDecimal("penalty"))
                .demandAmount(rs.getBigDecimal("demandAmount"))
                .advance(rs.getBigDecimal("advance"))
                .build();
    }
}