package org.egov.naljalcustomisation.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.egov.common.contract.request.RequestInfo;
import org.egov.naljalcustomisation.web.model.users.UserSearchRequest;
import org.egov.naljalcustomisation.config.CustomisationConfiguration;
import org.egov.naljalcustomisation.repository.ServiceRequestRepository;
import org.egov.naljalcustomisation.web.model.OwnerInfo;
import org.egov.naljalcustomisation.web.model.users.UserDetailResponse;
import org.egov.tracer.model.CustomException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
public class UserService {

    @Autowired
    private ObjectMapper mapper;

    @Autowired
    private CustomisationConfiguration configuration;

    @Autowired
    private ServiceRequestRepository serviceRequestRepository;

    @Value("${egov.user.host}")
    private String userHost;

    @Value("${egov.user.search.path}")
    private String userSearchEndpoint;


    public UserDetailResponse getUserByRoleCodes(RequestInfo requestInfo, String tenantId, List<String> roleCodes) {

        UserSearchRequest userSearchRequest = new UserSearchRequest();
        userSearchRequest.setTenantId(tenantId);
        userSearchRequest.setRequestInfo(requestInfo);
        userSearchRequest.setActive(true);
        userSearchRequest.setRoleCodes(roleCodes);
        StringBuilder uri = new StringBuilder(userHost).append(userSearchEndpoint);
        return userCall(userSearchRequest, uri);
    }

    /**
     * Returns UserDetailResponse by calling user service with given uri and object
     *
     * @param userRequest Request object for user service
     * @param uri         The address of the endpoint
     * @return Response from user service as parsed as userDetailResponse
     */
    @SuppressWarnings("unchecked")
    private UserDetailResponse userCall(Object userRequest, StringBuilder uri) throws CustomException {
        String dobFormat = null;
        if (uri.toString().contains(configuration.getUserSearchEndpoint())
                || uri.toString().contains(configuration.getUserUpdateEndPoint()))
            dobFormat = "yyyy-MM-dd";
        else if (uri.toString().contains(configuration.getUserCreateEndPoint()))
            dobFormat = "dd/MM/yyyy";
        try {
            LinkedHashMap<String, Object> responseMap = (LinkedHashMap<String, Object>) serviceRequestRepository.fetchResult(uri, userRequest);
            if (!CollectionUtils.isEmpty(responseMap)) {
                parseResponse(responseMap, dobFormat);
                return mapper.convertValue(responseMap, UserDetailResponse.class);
            } else {
                return new UserDetailResponse();
            }
        }
        // Which Exception to throw?
        catch (IllegalArgumentException e) {
            throw new CustomException("IllegalArgumentException", "ObjectMapper not able to convertValue in userCall");
        }
    }

    /**
     * Parses date formats to long for all users in responseMap
     *
     * @param responeMap LinkedHashMap got from user api response
     * @param dobFormat  dob format (required because dob is returned in different
     *                   format's in search and create response in user service)
     */
    @SuppressWarnings("unchecked")
    private void parseResponse(LinkedHashMap<String, Object> responeMap, String dobFormat) {
        List<LinkedHashMap<String, Object>> users = (List<LinkedHashMap<String, Object>>) responeMap.get("user");
        String format1 = "dd-MM-yyyy HH:mm:ss";
        if (null != users) {
            users.forEach(map -> {
                map.put("createdDate", dateTolong((String) map.get("createdDate"), format1));
                if ((String) map.get("lastModifiedDate") != null)
                    map.put("lastModifiedDate", dateTolong((String) map.get("lastModifiedDate"), format1));
                if ((String) map.get("dob") != null)
                    map.put("dob", dateTolong((String) map.get("dob"), dobFormat));
                if ((String) map.get("pwdExpiryDate") != null)
                    map.put("pwdExpiryDate", dateTolong((String) map.get("pwdExpiryDate"), format1));
            });
        }
    }

    /**
     * Converts date to long
     *
     * @param date   date to be parsed
     * @param format Format of the date
     * @return Long value of date
     */
    private Long dateTolong(String date, String format) {
        SimpleDateFormat f = new SimpleDateFormat(format);
        Date d = null;
        try {
            d = f.parse(date);
        } catch (ParseException e) {
            log.error("Failed to parse date: {} with format: {}", date, format, e);
            throw new CustomException("INVALID_DATE_FORMAT","Failed to parse date format in user");
        }
        return d.getTime();
    }

    /**
     *
     * @param userSearchRequest
     * @return serDetailResponse containing the user if present and the responseInfo
     */
    public UserDetailResponse getUser(UserSearchRequest userSearchRequest) {
        StringBuilder uri = new StringBuilder(configuration.getUserHost())
                .append(configuration.getUserSearchEndpoint());
        UserDetailResponse userDetailResponse = userCall(userSearchRequest, uri);
        return userDetailResponse;
    }

    /**
     * provides a user search request with basic mandatory parameters
     *
     * @param tenantId
     * @param requestInfo
     * @return
     */
    public UserSearchRequest getBaseUserSearchRequest(String tenantId, RequestInfo requestInfo,String userType) {
        return UserSearchRequest.builder().requestInfo(requestInfo).userType(userType).tenantId(tenantId).active(true)
                .build();
    }

    /**
     *
     * @param mobileNumber
     * @param tenantId
     * @param requestInfo
     * @return
     */
    public Set<String> getUUIDForUsers(String mobileNumber, String name, String tenantId, RequestInfo requestInfo) {
        //TenantId is not mandatory when Citizen searches. So it can be empty. Refer the value from UserInfo
        tenantId = StringUtils.isEmpty(tenantId) ? requestInfo.getUserInfo().getTenantId() : tenantId;
        UserSearchRequest userSearchRequest = UserSearchRequest.builder()
                .requestInfo(requestInfo).userType("CITIZEN")
                .tenantId(tenantId).mobileNumber(mobileNumber).name(name).build();
        return getUsersUUID(userSearchRequest);
    }

    /**
     * Get user based on given property
     * @param userSearchRequest
     * @return combination of uuid given in search criteria
     */
    private Set<String> getUsersUUID(UserSearchRequest userSearchRequest) {
        StringBuilder uri = new StringBuilder(configuration.getUserHost())
                .append(configuration.getUserSearchEndpoint());
        UserDetailResponse userDetailResponse = userCall(userSearchRequest, uri);
        if (CollectionUtils.isEmpty(userDetailResponse.getUser()))
            return Collections.emptySet();
        return userDetailResponse.getUser().stream().map(OwnerInfo::getUuid).collect(Collectors.toSet());
    }
}
