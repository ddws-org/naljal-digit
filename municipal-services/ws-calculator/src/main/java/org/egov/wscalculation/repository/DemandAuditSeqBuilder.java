package org.egov.wscalculation.repository;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.stereotype.Repository;

@Component
@Slf4j
@Repository
public class DemandAuditSeqBuilder {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    public static final String SELECT_NEXT_SEQUENCE_USER = "select nextval('seq_eg_ws_demand_auditchange')";

    public Long getNextSequence() {
        return jdbcTemplate.queryForObject(SELECT_NEXT_SEQUENCE_USER, Long.class);
    }


}
