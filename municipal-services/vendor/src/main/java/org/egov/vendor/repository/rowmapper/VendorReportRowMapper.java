package org.egov.vendor.repository.rowmapper;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.egov.vendor.service.UserService;
import org.egov.vendor.web.model.VendorReportData;
import org.egov.vendor.web.model.user.User;
import org.egov.vendor.web.model.user.UserDetailResponse;
import org.egov.vendor.web.model.user.UserSearchRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.stereotype.Component;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

@Component
@Slf4j
public class VendorReportRowMapper implements ResultSetExtractor<List<VendorReportData>>
{
    @Autowired
    private ObjectMapper mapper;
    @Autowired
    private UserService userService;

    @Override
    public List<VendorReportData> extractData(ResultSet resultSet) throws SQLException, DataAccessException {
        List<VendorReportData> vendorReportDataList=new ArrayList<>();

        while(resultSet.next())
        {
             VendorReportData vendorReportData=new VendorReportData();
             vendorReportData.setVendor_name(resultSet.getString("name"));
             vendorReportData.setBill_id(resultSet.getString("challanno"));
             vendorReportData.setUuid(resultSet.getString("owner_uuid"));
             vendorReportData.setType_of_expense(resultSet.getString("type_of_expense"));
             vendorReportDataList.add(vendorReportData);
        }
         if(!vendorReportDataList.isEmpty())
         {
           enrichVendorHolderDetails(vendorReportDataList);
         }
        return vendorReportDataList;
    }

    private void enrichVendorHolderDetails(List<VendorReportData> vendorReportDataList)
    {
        Set<String> lastModifiedByUuid= new HashSet<>();

        for(VendorReportData vendorReportData:vendorReportDataList)
        {
              lastModifiedByUuid.add(vendorReportData.getUuid());
        }

        UserSearchRequest userSearchRequest=new UserSearchRequest();
        userSearchRequest.setUuid((new ArrayList<>(lastModifiedByUuid)));

        log.info(userSearchRequest.getUuid().toString());

        UserDetailResponse userDetailResponse = userService.getUser(userSearchRequest);

        log.info(userDetailResponse.getUser().toString());

        enrichConnectionHolderInfo(userDetailResponse, vendorReportDataList);

    }

    private void enrichConnectionHolderInfo(UserDetailResponse userDetailResponse, List<VendorReportData> vendorReportDataList)
    {
        List<User> connectionHolderInfos = userDetailResponse.getUser();
        Map<String, User> userIdToConnectionHolderMap = new HashMap<>();
        if(connectionHolderInfos.isEmpty())
        {
            return;
        }
        connectionHolderInfos.forEach(user -> userIdToConnectionHolderMap.put(user.getUuid(), user));

        log.info(userIdToConnectionHolderMap.toString());

//        vendorReportDataList.forEach(vendorReportData-> vendorReportData.setMobile_no(userIdToConnectionHolderMap.get(vendorReportData.getUuid()).getMobileNumber()));

        vendorReportDataList.forEach(vendorReportData -> {
            User connection = userIdToConnectionHolderMap.get(vendorReportData.getUuid());
            if (connection != null) {
                vendorReportData.setMobile_no(connection.getMobileNumber());
            } else {
                log.warn("User not found for UUID: " + vendorReportData.getUuid());
            }
        });

    }
}
