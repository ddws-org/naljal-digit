package org.egov.hrms.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.jayway.jsonpath.JsonPath;
import lombok.extern.slf4j.Slf4j;
import org.egov.common.contract.request.RequestInfo;
import org.egov.hrms.config.PropertiesManager;
import org.egov.hrms.model.Employee;
import org.egov.hrms.repository.ElasticSearchRepository;
import org.egov.hrms.repository.EmployeeRepository;
import org.egov.hrms.utils.HRMSConstants;
import org.egov.hrms.utils.HRMSUtils;
import org.egov.hrms.web.contract.EmployeeSearchCriteria;
import org.egov.hrms.web.contract.User;
import org.egov.hrms.web.contract.UserResponse;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.*;
import java.util.stream.Collectors;

import static org.egov.hrms.utils.HRMSConstants.ES_DATA_PATH;

@Slf4j
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
    @Autowired
    private UserService userService;
    @Autowired
    private HRMSUtils hrmsUtils;


    public List<Employee> getEmployees(RequestInfo requestInfo, EmployeeSearchCriteria criteria) {

        if(criteria.getTenantId() == null)
        {	criteria.setTenantId(config.getStateLevelTenantId()); }

        List<String> idsFromDB = employeeRepository.fetchEmployeesforAssignment(criteria,requestInfo);

//        if(CollectionUtils.isEmpty(idsFromDB))
//            return new LinkedList<>();

        validateFuzzySearchCriteria(criteria);

        Object esResponse = elasticSearchRepository.fuzzySearchEmployees(criteria, idsFromDB);

        Map<String, Set<String>> tenantIdToEmpId = getTenantIdToEmpIdMap(esResponse);

        List<Employee> employees = new LinkedList<>();

        for (Map.Entry<String, Set<String>> entry : tenantIdToEmpId.entrySet()) {
            String tenantId = entry.getKey();
            Set<String> empIds = entry.getValue();
            List<String> empList = new ArrayList<>(empIds);

            EmployeeSearchCriteria employeeSearchCriteria = EmployeeSearchCriteria.builder().tenantId(tenantId).codes(empList).build();

            employees.addAll(employeeRepository.fetchEmployees(employeeSearchCriteria, requestInfo));
            Set<String> uuids = employees.stream().map(Employee::getUuid).collect(Collectors.toSet());
            Map<String,Object> map = new HashMap<>();
            map.put(HRMSConstants.HRMS_USER_SEARCH_CRITERA_UUID,uuids);
            UserResponse userResponse = userService.getUser(requestInfo, map);
            log.info("userResponse {}",userResponse);
            List<User> users = userResponse.getUser();
            hrmsUtils.enrichOwner(users, employees);
        }

        return employees;
    }
    private void validateFuzzySearchCriteria(EmployeeSearchCriteria criteria){

        if(criteria.getName() == null)
            throw new CustomException("INVALID_SEARCH_CRITERIA","The search criteria is invalid");

    }
    private Map<String, Set<String>> getTenantIdToEmpIdMap(Object esResponse) {

        List<Map<String, Object>> data;
        Map<String, Set<String>> tenantIdToEmpIds = new LinkedHashMap<>();


        try {
            data = JsonPath.read(esResponse, ES_DATA_PATH);


            if (!CollectionUtils.isEmpty(data)) {

                for (Map<String, Object> map : data) {

                    String tenantId = JsonPath.read(map, "$.tenantData.code");
                    String empId = JsonPath.read(map, "$.code");
                    if (tenantIdToEmpIds.containsKey(tenantId))
                        tenantIdToEmpIds.get(tenantId).add(empId);
                    else {
                        Set<String> empIds = new HashSet<>();
                        empIds.add(empId);
                        tenantIdToEmpIds.put(tenantId, empIds);
                    }

                }

            }

        } catch (Exception e) {
            throw new CustomException("PARSING_ERROR", "Failed to extract employeeIds from es response");
        }

        return tenantIdToEmpIds;
    }
}
