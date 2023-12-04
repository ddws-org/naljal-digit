package org.egov.wscalculation.service;


import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.UUID;

import org.egov.common.contract.request.RequestInfo;
import org.egov.common.contract.request.Role;
import org.egov.tracer.model.CustomException;
import org.egov.wscalculation.repository.ServiceRequestRepository;
import org.egov.wscalculation.web.models.SearchCriteria;
import org.egov.wscalculation.web.models.users.CreateUserRequest;
import org.egov.wscalculation.web.models.users.UserDetailResponse;
import org.egov.wscalculation.web.models.users.UserSearchRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import com.fasterxml.jackson.databind.ObjectMapper;

@Service
public class UserService {

	@Autowired
	private ObjectMapper mapper;

	@Autowired
	private ServiceRequestRepository serviceRequestRepository;
	
	@Value("${egov.user.host}")
	private String userHost;

	@Value("${egov.user.context.path}")
	private String userContextPath;

	@Value("${egov.user.search.path}")
	private String userSearchEndpoint;


	 
	 
	 @SuppressWarnings("unchecked")
		private UserDetailResponse userCall(Object userRequest, StringBuilder url) {
	    	
			String dobFormat = null;
			dobFormat = "yyyy-MM-dd";

			try{
	            LinkedHashMap responseMap = (LinkedHashMap)serviceRequestRepository.fetchResult(url, userRequest);
	            parseResponse(responseMap,dobFormat);
	            UserDetailResponse userDetailResponse = mapper.convertValue(responseMap,UserDetailResponse.class);
	            return userDetailResponse;
	        }
	        catch(IllegalArgumentException  e)
	        {
	            throw new CustomException("IllegalArgumentException","ObjectMapper not able to convertValue in userCall");
	        }
	    }
	 
	 @SuppressWarnings("unchecked")
		private void parseResponse(LinkedHashMap<String, Object> responeMap,String dobFormat) {
	        List<LinkedHashMap<String, Object>> users = (List<LinkedHashMap<String, Object>>)responeMap.get("user");
	        String format1 = "dd-MM-yyyy HH:mm:ss";
	        
	        if(null != users) {
	        	
	            users.forEach( map -> {
	            	
	                        map.put("createdDate",dateTolong((String)map.get("createdDate"),format1));
	                        if((String)map.get("lastModifiedDate")!=null)
	                            map.put("lastModifiedDate",dateTolong((String)map.get("lastModifiedDate"),format1));
	                        if((String)map.get("dob")!=null)
	                            map.put("dob",dateTolong((String)map.get("dob"),dobFormat));
	                        if((String)map.get("pwdExpiryDate")!=null)
	                            map.put("pwdExpiryDate",dateTolong((String)map.get("pwdExpiryDate"),format1));
	                    }
	            );
	        }
	    }
	 
	 
	    private Long dateTolong(String date,String format){
	        SimpleDateFormat f = new SimpleDateFormat(format);
	        Date d = null;
	        try {
	            d = f.parse(date);
	        } catch (ParseException e) {
	            e.printStackTrace();
	        }
	        return  d.getTime();
	    }
	 

		
	public UserDetailResponse getUserByRoleCodes(RequestInfo requestInfo, List<String> roleCodes, String tenantId) {

		UserSearchRequest userSearchRequest = new UserSearchRequest();
		userSearchRequest.setTenantId(tenantId);
		userSearchRequest.setRequestInfo(requestInfo);
		userSearchRequest.setActive(true);
		userSearchRequest.setRoleCodes(roleCodes);
		StringBuilder uri = new StringBuilder(userHost).append(userSearchEndpoint);
		return userCall(userSearchRequest, uri);
	}


	
	   
}
