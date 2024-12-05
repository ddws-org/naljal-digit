package org.egov.wscalculation.repository;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;

import lombok.extern.slf4j.Slf4j;
import org.egov.common.contract.request.RequestInfo;
import org.egov.tracer.model.CustomException;
import org.egov.wscalculation.config.WSCalculationConfiguration;
import org.egov.wscalculation.repository.builder.DemandQueryBuilder;
import org.egov.wscalculation.web.models.Demand;
import org.egov.wscalculation.web.models.DemandRequest;
import org.egov.wscalculation.web.models.DemandResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import com.fasterxml.jackson.databind.ObjectMapper;


@Repository
@Slf4j
public class DemandRepository {


    @Autowired
    private ServiceRequestRepository serviceRequestRepository;

    @Autowired
    private WSCalculationConfiguration config;

    @Autowired
    private ObjectMapper mapper;

    @Autowired
    private DemandQueryBuilder queryBuilder;

    @Autowired
    private JdbcTemplate jdbcTemplate;


    /**
     * Creates demand
     * @param requestInfo The RequestInfo of the calculation Request
     * @param demands The demands to be created
     * @return The list of demand created
     */
    public List<Demand> saveDemand(RequestInfo requestInfo, List<Demand> demands){
        StringBuilder url = new StringBuilder(config.getBillingServiceHost());
        url.append(config.getDemandCreateEndPoint());
        DemandRequest request = new DemandRequest(requestInfo,demands);
        log.info("Creating demand for consumer code: "+request.getDemands().get(0).getConsumerCode());
        Object result = serviceRequestRepository.fetchResult(url, request);
        try{
           return  mapper.convertValue(result,DemandResponse.class).getDemands();
        }
        catch(IllegalArgumentException e){
            throw new CustomException("PARSING_ERROR","Failed to parse response of create demand");
        }
    }

    /**
     * Updates the demand
     * @param requestInfo The RequestInfo of the calculation Request
     * @param demands The demands to be updated
     * @return The list of demand updated
     */
    public List<Demand> updateDemand(RequestInfo requestInfo, List<Demand> demands){
        StringBuilder url = new StringBuilder(config.getBillingServiceHost());
        url.append(config.getDemandUpdateEndPoint());
        DemandRequest request = new DemandRequest(requestInfo,demands);
        log.info("Updating demand for consumer code: "+request.getDemands().get(0).getConsumerCode());
        Object result = serviceRequestRepository.fetchResult(url, request);
        try{
            return mapper.convertValue(result,DemandResponse.class).getDemands();
        }
        catch(IllegalArgumentException e){
            throw new CustomException("PARSING_ERROR","Failed to parse response of update demand");
        }
    }
    public List<String> getDemandsToAddPenalty(String tenantId, BigInteger penaltyThresholdTime, Integer penaltyApplicableAfterDays) {
        List<Object> preparedStmtList = new ArrayList<>();
        String query = queryBuilder.getPenaltyQuery(tenantId, penaltyThresholdTime, penaltyApplicableAfterDays);
        log.info("query:"+ query);
        return jdbcTemplate.queryForList(query, String.class);
    }


}
