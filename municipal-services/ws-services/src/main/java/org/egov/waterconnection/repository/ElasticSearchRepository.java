package org.egov.waterconnection.repository;

import java.util.List;

import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.config.WSConfiguration;
import org.egov.waterconnection.repository.builder.FuzzySearchQueryBuilder;
import org.egov.waterconnection.web.models.SearchCriteria;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Base64;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import javax.net.ssl.*;

import org.springframework.web.client.RestTemplate;
import javax.net.ssl.*;
@Slf4j
@Component
public class ElasticSearchRepository {


    private WSConfiguration config;

    private FuzzySearchQueryBuilder queryBuilder;

    private ObjectMapper mapper;

    @Autowired
    public ElasticSearchRepository(WSConfiguration config, FuzzySearchQueryBuilder queryBuilder, ObjectMapper mapper) {
        this.config = config;
        this.queryBuilder = queryBuilder;
        this.mapper = mapper;
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

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.add("Authorization", getESEncodedCredentials());
        final HttpEntity entity = new HttpEntity( headers);
        // response = restTemplate.exchange(url.toString(), HttpMethod.GET, entity, Map.class);
        HttpEntity<String> requestEntity = new HttpEntity<>(searchQuery, headers);
        ResponseEntity response = null;
        try {
            response = this.restTemplate().postForEntity(url, requestEntity, Object.class);
        } catch (Exception e) {
        	log.error("Failed to fetch data from ES: "+e.getMessage());
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
        builder.append(config.getEsWSIndex());
        builder.append(config.getEsSearchEndpoint());

        return builder.toString();
    }

    public String getESEncodedCredentials() {
        String credentials = config.getEsUsername() + ":" + config.getEsPassword();
        byte[] credentialsBytes = credentials.getBytes();
        byte[] base64CredentialsBytes = Base64.getEncoder().encode(credentialsBytes);
        return "Basic " + new String(base64CredentialsBytes);
    }
    public static void trustSelfSignedSSL() {
        try {
            SSLContext ctx = SSLContext.getInstance("TLS");
            X509TrustManager tm = new X509TrustManager() {
                public void checkClientTrusted(X509Certificate[] xcs, String string) throws CertificateException {
                }

                public void checkServerTrusted(X509Certificate[] xcs, String string) throws CertificateException {
                }

                public X509Certificate[] getAcceptedIssuers() {
                    return null;
                }
            };
            ctx.init(null, new TrustManager[]{tm}, null);
            SSLContext.setDefault(ctx);

            // Disable hostname verification
            HttpsURLConnection.setDefaultHostnameVerifier(new HostnameVerifier() {
                public boolean verify(String hostname, javax.net.ssl.SSLSession sslSession) {
                    return true;
                }
            });
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    @Primary
    public RestTemplate restTemplate() {
        trustSelfSignedSSL();
        return new RestTemplate();
    }


}
