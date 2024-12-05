package org.egov.hrms.repository;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.egov.hrms.config.PropertiesManager;
import org.egov.hrms.web.contract.EmployeeSearchCriteria;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Repository;
import org.springframework.web.client.RestTemplate;

import java.util.Base64;
import java.util.List;

@Slf4j
@Repository
public class ElasticSearchRepository {
    private PropertiesManager config;

    private FuzzySearchQueryBuilder queryBuilder;

    private RestTemplate restTemplate;

    private ObjectMapper mapper;

    @Autowired
    public ElasticSearchRepository(PropertiesManager config, FuzzySearchQueryBuilder queryBuilder, RestTemplate restTemplate, ObjectMapper mapper) {
        this.config = config;
        this.queryBuilder = queryBuilder;
        this.restTemplate = restTemplate;
        this.mapper = mapper;
    }

    public Object fuzzySearchEmployees(EmployeeSearchCriteria criteria, List<String> uuids) {


        String url = getESURL();

        String searchQuery = queryBuilder.getFuzzySearchQuery(criteria, uuids);

        HttpHeaders headers = new HttpHeaders();
        headers.add("Authorization", getESEncodedCredentials());
        headers.setContentType(MediaType.APPLICATION_JSON);
        log.info("Headers: " + headers.toString());
        HttpEntity<String> requestEntity = new HttpEntity<>(searchQuery, headers);
        ResponseEntity response = null;
        try {
            response = restTemplate.postForEntity(url, requestEntity, Object.class);

        } catch (Exception e) {
            e.printStackTrace();
            throw new CustomException("ES_ERROR","Failed to fetch data from ES");
        }

        return response.getBody();

    }


    /**
     * Generates elasticsearch search url from application properties
     *
     * @return
     */
    private String getESURL() {

        StringBuilder builder = new StringBuilder(config.getEsHost());
        builder.append(config.getEsPTIndex());
        builder.append(config.getEsSearchEndpoint());

        return builder.toString();
    }

    public String getESEncodedCredentials() {
        String credentials = config.getUserName() + ":" + config.getPassword();
        byte[] credentialsBytes = credentials.getBytes();
        byte[] base64CredentialsBytes = Base64.getEncoder().encode(credentialsBytes);
        return "Basic " + new String(base64CredentialsBytes);
    }
}
