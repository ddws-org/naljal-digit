package org.egov.waterconnection.repository.rowmapper;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.egov.waterconnection.service.UserService;
import org.egov.waterconnection.web.models.CollectionReportData;
import org.egov.waterconnection.web.models.InactiveConsumerReportData;
import org.egov.waterconnection.web.models.OwnerInfo;
import org.egov.waterconnection.web.models.users.UserDetailResponse;
import org.egov.waterconnection.web.models.users.UserSearchRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.stereotype.Component;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
@Component
public class InactiveConsumerReportRowMapper implements ResultSetExtractor<List<InactiveConsumerReportData>> {
    @Autowired
    private ObjectMapper mapper;

    @Autowired
    private UserService userService;

    @Override
    public List<InactiveConsumerReportData> extractData(ResultSet resultSet) throws SQLException, DataAccessException {
        List<InactiveConsumerReportData> inactiveConsumerReportList=new ArrayList<>();
        while(resultSet.next())
        {
           InactiveConsumerReportData inactiveConsumerReportData=new InactiveConsumerReportData();
            inactiveConsumerReportData.setConnectionno(resultSet.getString("connectionno"));
            inactiveConsumerReportData.setStatus(resultSet.getString("status"));
            inactiveConsumerReportData.setInactiveDate(resultSet.getLong("lastmodifiedtime"));
            inactiveConsumerReportData.setInactivatedByUuid(resultSet.getString("lastmodifiedbyUuid"));
            inactiveConsumerReportList.add(inactiveConsumerReportData);
        }
        if(!inactiveConsumerReportList.isEmpty()) {
            enrichConnectionHolderDetails(inactiveConsumerReportList);
        }
        return inactiveConsumerReportList;
    }
     public void enrichConnectionHolderDetails(List<InactiveConsumerReportData> inactiveConsumerReportList)
     {
         Set<String> lastModifiedByUuid= new HashSet<>();
         for(InactiveConsumerReportData inactiveConsumerReportData:inactiveConsumerReportList)
         {
             lastModifiedByUuid.add(inactiveConsumerReportData.getInactivatedByUuid());
         }
         UserSearchRequest userSearchRequest=new UserSearchRequest();
         userSearchRequest.setUuid(lastModifiedByUuid);
         UserDetailResponse userDetailResponse = userService.getUser(userSearchRequest);
         enrichConnectionHolderInfo(userDetailResponse, inactiveConsumerReportList);

     }

    private void enrichConnectionHolderInfo(UserDetailResponse userDetailResponse,
                                            List<InactiveConsumerReportData> inactiveConsumerReportList) {
        List<OwnerInfo> connectionHolderInfos = userDetailResponse.getUser();
        Map<String, OwnerInfo> userIdToConnectionHolderMap = new HashMap<>();
        connectionHolderInfos.forEach(user -> userIdToConnectionHolderMap.put(user.getUuid(), user));
        inactiveConsumerReportList.forEach(inactiveConsumerReportData-> inactiveConsumerReportData.setInactivatedByName(userIdToConnectionHolderMap.get(inactiveConsumerReportData.getInactivatedByUuid()).getName()));
    }
}
