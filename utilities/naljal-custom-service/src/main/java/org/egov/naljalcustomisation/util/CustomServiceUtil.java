package org.egov.naljalcustomisation.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.egov.common.contract.request.RequestInfo;
import org.egov.naljalcustomisation.config.CustomisationConfiguration;
import org.egov.naljalcustomisation.repository.ServiceRequestRepository;
import org.egov.naljalcustomisation.web.model.*;
import org.egov.tracer.model.CustomException;

import java.util.Calendar;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

@Component
@Slf4j
public class CustomServiceUtil {

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private ServiceRequestRepository serviceRequestRepository;

    @Autowired
    private CustomisationConfiguration customisationConfiguration;

    private String tenantId = "tenantId=";
    private String propertyIds = "propertyIds=";
    private String mobileNumber = "mobileNumber=";
    private String locality = "locality=";
    private String uuids = "uuids=";

    @Value("${egov.property.service.host}")
    private String propertyHost;

    @Value("${egov.property.searchendpoint}")
    private String searchPropertyEndPoint;

    /**
     *
     * @param result
     *            Response object from property service call
     * @return List of property
     */
    public List<Property> getPropertyDetails(Object result) {

        try {
            PropertyResponse propertyResponse = objectMapper.convertValue(result, PropertyResponse.class);
            return propertyResponse.getProperties();
        } catch (Exception ex) {
            throw new CustomException("PROPERTY_PARSING_ERROR", "The property json cannot be parsed");
        }
    }
    public StringBuilder getPropertyURL() {
        return new StringBuilder().append(propertyHost).append(searchPropertyEndPoint);
    }

    public StringBuilder getPropertyURL(PropertyCriteria criteria) {
        StringBuilder url = new StringBuilder(getPropertyURL());
        boolean isanyparametermatch = false;
        url.append("?");
        if (!StringUtils.isEmpty(criteria.getTenantId())) {
            isanyparametermatch = true;
            url.append(tenantId).append(criteria.getTenantId());
        }
        if (!CollectionUtils.isEmpty(criteria.getPropertyIds())) {
            if (isanyparametermatch)url.append("&");
            isanyparametermatch = true;
            String propertyIdsString = criteria.getPropertyIds().stream().map(propertyId -> propertyId)
                    .collect(Collectors.toSet()).stream().collect(Collectors.joining(","));
            url.append(propertyIds).append(propertyIdsString);
        }
        if (!StringUtils.isEmpty(criteria.getMobileNumber())) {
            if (isanyparametermatch)url.append("&");
            isanyparametermatch = true;
            url.append(mobileNumber).append(criteria.getMobileNumber());
        }
        if (!StringUtils.isEmpty(criteria.getLocality())) {
            if (isanyparametermatch)url.append("&");
            isanyparametermatch = true;
            url.append(locality).append(criteria.getLocality());
        }
        if (!CollectionUtils.isEmpty(criteria.getUuids())) {
            if (isanyparametermatch)url.append("&");
            String uuidString = criteria.getUuids().stream().map(uuid -> uuid).collect(Collectors.toSet()).stream()
                    .collect(Collectors.joining(","));
            url.append(uuids).append(uuidString);
        }
        return url;
    }

    /**
     *
     * @param waterConnectionSearchCriteria
     *            WaterConnectionSearchCriteria containing search criteria on
     *            water connection
     * @param requestInfo
     * @return List of property matching on given criteria
     */
    public List<Property> propertySearchOnCriteria(SearchCriteria waterConnectionSearchCriteria,
                                                   RequestInfo requestInfo) {
        if (StringUtils.isEmpty(waterConnectionSearchCriteria.getMobileNumber())
                && StringUtils.isEmpty(waterConnectionSearchCriteria.getPropertyId())) {
            return Collections.emptyList();
        }
        PropertyCriteria propertyCriteria = new PropertyCriteria();
        if (!StringUtils.isEmpty(waterConnectionSearchCriteria.getTenantId())) {
            propertyCriteria.setTenantId(waterConnectionSearchCriteria.getTenantId());
        }
        if (!StringUtils.isEmpty(waterConnectionSearchCriteria.getMobileNumber())) {
            propertyCriteria.setMobileNumber(waterConnectionSearchCriteria.getMobileNumber());
        }
        if (!StringUtils.isEmpty(waterConnectionSearchCriteria.getPropertyId())) {
            HashSet<String> propertyIds = new HashSet<>();
            propertyIds.add(waterConnectionSearchCriteria.getPropertyId());
            propertyCriteria.setPropertyIds(propertyIds);
        }
        if (!StringUtils.isEmpty(waterConnectionSearchCriteria.getName())) {
            propertyCriteria.setName(waterConnectionSearchCriteria.getName());
        }
        if (!StringUtils.isEmpty(waterConnectionSearchCriteria.getLocality())) {
            propertyCriteria.setLocality(waterConnectionSearchCriteria.getLocality());
        }
        return getPropertyDetails(serviceRequestRepository.fetchResult(getPropertyURL(propertyCriteria),
                RequestInfoWrapper.builder().requestInfo(requestInfo).build()));
    }

    public StringBuilder getcollectionURL() {
        StringBuilder builder = new StringBuilder();
        return builder.append(customisationConfiguration.getCollectionHost()).append(customisationConfiguration.getPaymentSearch());
    }

    public static void setTimeToBeginningOfDay(Calendar calendar) {
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
    }
}
