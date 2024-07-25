package org.egov.hrms.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;
import org.egov.common.contract.request.RequestInfo;
import org.egov.hrms.config.PropertiesManager;
import org.egov.hrms.model.Employee;
import org.egov.hrms.repository.ElasticSearchRepository;
import org.egov.hrms.repository.EmployeeRepository;
import org.egov.hrms.web.contract.EmployeeSearchCriteria;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.*;

import static org.egov.hrms.utils.HRMSConstants.ES_DATA_PATH;

@Service
public class FuzzySearchService {
    @Autowired
    private ElasticSearchRepository elasticSearchRepository;
    @Autowired
    private ObjectMapper mapper;
    @Autowired
    private EmployeeRepository employeeRepository;
    @Autowired
    private PropertiesManager config;

    public List<Employee> getEmployees(RequestInfo requestInfo, EmployeeSearchCriteria criteria) {

        if(criteria.getTenantId() == null)
        {	criteria.setTenantId(config.getStateLevelTenantId()); }

        List<String> idsFromDB = employeeRepository.fetchEmployeesforAssignment(criteria,requestInfo);

        if(CollectionUtils.isEmpty(idsFromDB))
            return new LinkedList<>();

        validateFuzzySearchCriteria(criteria);

        Object esResponse = elasticSearchRepository.fuzzySearchEmployees(criteria, idsFromDB);

        Map<String, Set<String>> tenantIdToPropertyId = getTenantIdToPropertyIdMap(esResponse);

        List<Employee> employees = new LinkedList<>();

        for (Map.Entry<String, Set<String>> entry : tenantIdToPropertyId.entrySet()) {
            String tenantId = entry.getKey();
            Set<String> propertyIds = entry.getValue();

//            EmployeeSearchCriteria employeeSearchCriteria = EmployeeSearchCriteria.builder().tenantId(tenantId).propertyIds(propertyIds).build();

            employees.addAll(employeeRepository.fetchEmployees(criteria,requestInfo));

        }

//        List<Employee> orderedProperties = orderByESScore(properties, esResponse);

        return employees;
    }
    private void validateFuzzySearchCriteria(EmployeeSearchCriteria criteria){

        if(criteria.getName() == null)
            throw new CustomException("INVALID_SEARCH_CRITERIA","The search criteria is invalid");

    }
    private Map<String, Set<String>> getTenantIdToPropertyIdMap(Object esResponse) {

        List<Map<String, Object>> data;
        Map<String, Set<String>> tenantIdToPropertyIds = new LinkedHashMap<>();


        try {
            data = JsonPath.read(esResponse, ES_DATA_PATH);


            if (!CollectionUtils.isEmpty(data)) {

                for (Map<String, Object> map : data) {

                    String tenantId = JsonPath.read(map, "$.tenantData.code");
                    String propertyId = JsonPath.read(map, "$.propertyId");

                    if (tenantIdToPropertyIds.containsKey(tenantId))
                        tenantIdToPropertyIds.get(tenantId).add(propertyId);
                    else {
                        Set<String> propertyIds = new HashSet<>();
                        propertyIds.add(propertyId);
                        tenantIdToPropertyIds.put(tenantId, propertyIds);
                    }

                }

            }

        } catch (Exception e) {
            throw new CustomException("PARSING_ERROR", "Failed to extract propertyIds from es response");
        }

        return tenantIdToPropertyIds;
    }
}
