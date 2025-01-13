package org.egov.naljalcustomisation.repository;

import java.util.List;
import java.util.Base64;

import org.egov.naljalcustomisation.config.CustomisationConfiguration;
import org.egov.tracer.model.CustomException;
import org.egov.naljalcustomisation.repository.builder.FuzzySearchQueryBuilder;
import org.egov.naljalcustomisation.web.model.SearchCriteria;
import org.springframework.beans.factory.annotation.Autowired;

import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class ElasticSearchRepository {
    private CustomisationConfiguration customisationConfiguration;

    private FuzzySearchQueryBuilder queryBuilder;

    private ObjectMapper mapper;

    private RestTemplate restTemplate;

    @Autowired
    public ElasticSearchRepository(CustomisationConfiguration customisationConfiguration, FuzzySearchQueryBuilder queryBuilder, ObjectMapper mapper, RestTemplate restTemplate) {
        this.customisationConfiguration = customisationConfiguration;
        this.queryBuilder = queryBuilder;
        this.mapper = mapper;
        this.restTemplate = restTemplate;
    }


    /**
     * Searches records from elasticsearch based on the fuzzy search criteria
     *
     * @param criteria
     * @return
     */

    public Object fuzzySearchProperties(SearchCriteria criteria, List<String> ids) {

        String url = getESURL();

        String searchQuery = queryBuilder.getFuzzySearchQuery(criteria, ids);
        log.info("searchQuery {}", searchQuery);
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.add("Authorization", getESEncodedCredentials());
        log.info("headers {}", headers);
        final HttpEntity entity = new HttpEntity(headers);
        // response = restTemplate.exchange(url.toString(), HttpMethod.GET, entity, Map.class);
        HttpEntity<String> requestEntity = new HttpEntity<>(searchQuery, headers);
        ResponseEntity response = null;
        try {
            response = restTemplate.postForEntity(url, requestEntity, Object.class);
        } catch (Exception e) {
            log.error("Failed to fetch data from ES: " + e.getMessage());
            throw new CustomException("ES_ERROR", "Failed to fetch data from ES");
        }

        return response.getBody();

    }

    /**
     * Generates elasticsearch search url from application properties
     *
     * @return
     */
    private String getESURL() {

        StringBuilder builder = new StringBuilder(customisationConfiguration.getEsHost());
        builder.append(customisationConfiguration.getEsWSIndex());
        builder.append(customisationConfiguration.getEsSearchEndpoint());

        return builder.toString();
    }

    public String getESEncodedCredentials() {
        String credentials = customisationConfiguration.getEsUsername() + ":" + customisationConfiguration.getEsPassword();
        byte[] credentialsBytes = credentials.getBytes();
        byte[] base64CredentialsBytes = Base64.getEncoder().encode(credentialsBytes);
        return "Basic " + new String(base64CredentialsBytes);
    }
}

