package org.egov.naljalcustomisation.service;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

import jakarta.validation.Valid;

import org.egov.common.contract.request.RequestInfo;
import org.egov.common.contract.request.Role;
import org.egov.naljalcustomisation.util.CustomServiceUtil;
import org.egov.tracer.model.CustomException;
import org.egov.naljalcustomisation.config.CustomisationConfiguration;
import org.egov.naljalcustomisation.constants.CustomConstants;
import org.egov.naljalcustomisation.repository.ServiceRequestRepository;
import org.egov.naljalcustomisation.web.model.AuditDetails;
import org.egov.naljalcustomisation.web.model.Connection;
import org.egov.naljalcustomisation.web.model.Connection.StatusEnum;
import org.egov.naljalcustomisation.web.model.OwnerInfo;
import org.egov.naljalcustomisation.web.model.Property;
import org.egov.naljalcustomisation.web.model.PropertyCriteria;
import org.egov.naljalcustomisation.web.model.RequestInfoWrapper;
import org.egov.naljalcustomisation.web.model.SearchCriteria;
import org.egov.naljalcustomisation.web.model.Status;
import org.egov.naljalcustomisation.web.model.WaterConnection;
import org.egov.naljalcustomisation.web.model.WaterConnectionResponse;
import org.egov.naljalcustomisation.web.model.users.User;
import org.egov.naljalcustomisation.web.model.users.UserDetailResponse;
import org.egov.naljalcustomisation.web.model.users.UserSearchRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
public class EnrichmentService {

    @Autowired
    private ObjectMapper mapper;

    @Autowired
    private CustomServiceUtil customServiceUtil;

    @Autowired
    private ServiceRequestRepository serviceRequestRepository;

    @Autowired
    private UserService userService;

    public List<WaterConnection> filterConnections(List<WaterConnection> connectionList) {
        HashMap<String, Connection> connectionHashMap = new HashMap<>();
        connectionList.forEach(connection -> {
            if (!StringUtils.isEmpty(connection.getConnectionNo())) {
                if (connectionHashMap.get(connection.getConnectionNo()) == null
                        && CustomConstants.FINAL_CONNECTION_STATES.contains(connection.getApplicationStatus())) {
                    connectionHashMap.put(connection.getConnectionNo(), connection);
                } else if (connectionHashMap.get(connection.getConnectionNo()) != null
                        && CustomConstants.FINAL_CONNECTION_STATES.contains(connection.getApplicationStatus())) {
                    if (connectionHashMap.get(connection.getConnectionNo()).getApplicationStatus()
                            .equals(connection.getApplicationStatus())) {
                        HashMap additionalDetail1 = new HashMap<>();
                        HashMap additionalDetail2 = new HashMap<>();
                        additionalDetail1 = mapper.convertValue(
                                connectionHashMap.get(connection.getConnectionNo()).getAdditionalDetails(),
                                HashMap.class);
                        additionalDetail2 = mapper.convertValue(connection.getAdditionalDetails(), HashMap.class);
                        BigDecimal creationDate1 = (BigDecimal) additionalDetail1.get(CustomConstants.APP_CREATED_DATE);
                        BigDecimal creationDate2 = (BigDecimal) additionalDetail2.get(CustomConstants.APP_CREATED_DATE);
                        if (creationDate1.compareTo(creationDate2) == -1) {
                            connectionHashMap.put(connection.getConnectionNo(), connection);
                        }
                    } else {
                        if (connection.getApplicationStatus().equals(CustomConstants.MODIFIED_FINAL_STATE)) {
                            connectionHashMap.put(connection.getConnectionNo(), connection);
                        }
                    }
                }
            }
        });
        return new ArrayList(connectionHashMap.values());
    }

    public List<WaterConnection> enrichPropertyDetails(List<WaterConnection> waterConnectionList, SearchCriteria criteria, RequestInfo requestInfo) {
        List<WaterConnection> finalConnectionList = new ArrayList<>();
        if (CollectionUtils.isEmpty(waterConnectionList))
            return finalConnectionList;

        Set<String> propertyIds = new HashSet<>();
        Map<String, List<OwnerInfo>> propertyToOwner = new HashMap<>();
        for (WaterConnection waterConnection : waterConnectionList) {
            if (!StringUtils.isEmpty(waterConnection.getPropertyId()))
                propertyIds.add(waterConnection.getPropertyId());
        }
        if (!CollectionUtils.isEmpty(propertyIds)) {
            PropertyCriteria propertyCriteria = new PropertyCriteria();
            if (!StringUtils.isEmpty(criteria.getTenantId())) {
                propertyCriteria.setTenantId(criteria.getTenantId());
            }
            propertyCriteria.setPropertyIds(propertyIds);
            List<Property> propertyList = customServiceUtil.getPropertyDetails(serviceRequestRepository.fetchResult(customServiceUtil.getPropertyURL(propertyCriteria),
                    RequestInfoWrapper.builder().requestInfo(requestInfo).build()));

            if (!CollectionUtils.isEmpty(propertyList)) {
                for (Property property : propertyList) {
                    propertyToOwner.put(property.getPropertyId(), property.getOwners());
                }
            }

            for (WaterConnection waterConnection : waterConnectionList) {
                HashMap<String, Object> additionalDetail = new HashMap<>();
                HashMap<String, Object> addDetail = mapper.convertValue(waterConnection.getAdditionalDetails(), HashMap.class);

                for (Map.Entry<String, Object> entry : addDetail.entrySet()) {
                    if (additionalDetail.getOrDefault(entry.getKey(), null) == null) {
                        additionalDetail.put(entry.getKey(), addDetail.get(entry.getKey()));
                    }
                }
                List<OwnerInfo> ownerInfoList = propertyToOwner.get(waterConnection.getPropertyId());
                if (!CollectionUtils.isEmpty(ownerInfoList)) {
                    additionalDetail.put("ownerName", ownerInfoList.get(0).getName());
                }
                waterConnection.setAdditionalDetails(additionalDetail);
                finalConnectionList.add(waterConnection);
            }
        }
        return finalConnectionList;
    }

    /**
     * Enrich
     *
     * @param waterConnectionList - List Of WaterConnectionObject
     * @param criteria            - Search Criteria
     * @param requestInfo         - RequestInfo Object
     */
    public void enrichConnectionHolderDeatils(List<WaterConnection> waterConnectionList, SearchCriteria criteria,
                                              RequestInfo requestInfo) {
        if (CollectionUtils.isEmpty(waterConnectionList))
            return;
        Set<String> connectionHolderIds = new HashSet<>();
        for (WaterConnection waterConnection : waterConnectionList) {
            if (!CollectionUtils.isEmpty(waterConnection.getConnectionHolders())) {
                connectionHolderIds.addAll(waterConnection.getConnectionHolders().stream()
                        .map(OwnerInfo::getUuid).collect(Collectors.toSet()));
            }
        }
        if (CollectionUtils.isEmpty(connectionHolderIds))
            return;
        UserSearchRequest userSearchRequest = userService.getBaseUserSearchRequest(criteria.getTenantId(), requestInfo, "CITIZEN");
        userSearchRequest.setUuid(connectionHolderIds);
        UserDetailResponse userDetailResponse = userService.getUser(userSearchRequest);
        enrichConnectionHolderInfo(userDetailResponse, waterConnectionList, requestInfo);
    }


    /**
     * Populates the owner fields inside of the water connection objects from the response got from calling user api
     *
     * @param userDetailResponse
     * @param waterConnectionList List of water connection whose owner's are to be populated from userDetailsResponse
     */
    public void enrichConnectionHolderInfo(UserDetailResponse userDetailResponse, List<WaterConnection> waterConnectionList, RequestInfo requestInfo) {
        List<OwnerInfo> connectionHolderInfos = userDetailResponse.getUser();
        Map<String, OwnerInfo> userIdToConnectionHolderMap = new HashMap<>();
        connectionHolderInfos.forEach(user -> userIdToConnectionHolderMap.put(user.getUuid(), user));
        waterConnectionList.forEach(waterConnection -> {
            if (!CollectionUtils.isEmpty(waterConnection.getConnectionHolders())) {
                waterConnection.getConnectionHolders().forEach(holderInfo -> {
                    if (userIdToConnectionHolderMap.get(holderInfo.getUuid()) == null)
                        throw new CustomException("OWNER_SEARCH_ERROR", "The owner of the water application"
                                + waterConnection.getApplicationNo() + " is not coming in user search");
                    else {
                        Boolean isOpenSearch = isSearchOpen(requestInfo.getUserInfo());
                        if (isOpenSearch)
                            holderInfo.addUserDetail(getMaskedOwnerInfo(userIdToConnectionHolderMap.get(holderInfo.getUuid())));
                        else
                            holderInfo.addUserDetail(userIdToConnectionHolderMap.get(holderInfo.getUuid()));

                    }

                });
            }
        });
    }

    public Boolean isSearchOpen(org.egov.common.contract.request.User userInfo) {

        return userInfo.getType().equalsIgnoreCase("SYSTEM")
                && userInfo.getRoles().stream().map(Role::getCode).collect(Collectors.toSet()).contains("ANONYMOUS");
    }

    private User getMaskedOwnerInfo(OwnerInfo info) {

        info.setMobileNumber(null);
        info.setUuid(null);
        info.setUserName(null);
        info.setGender(null);
        info.setAltContactNumber(null);
        info.setPwdExpiryDate(null);
        return info;
    }
}
