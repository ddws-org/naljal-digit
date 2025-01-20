package org.egov.naljalcustomisation.repository.rowmapper;

import org.egov.naljalcustomisation.service.UserService;
import org.egov.naljalcustomisation.web.model.MonthReport;
import org.egov.naljalcustomisation.web.model.OwnerInfo;
import org.egov.naljalcustomisation.web.model.users.UserDetailResponse;
import org.egov.naljalcustomisation.web.model.users.UserSearchRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Component;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

@Component
public class ConsumerRowMapper implements RowMapper<MonthReport>
{
    @Autowired
    private UserService userService;

    @Override
    public MonthReport mapRow(ResultSet rs, int rowNum) throws SQLException
    {
        MonthReport monthReport= MonthReport.builder()
                .tenantName(rs.getString("tenantId"))
                .connectionNo(rs.getString("connectionNo"))
                .oldConnectionNo(rs.getString("oldConnectionNo"))
                .consumerCreatedOnDate(rs.getLong("consumerCreatedOnDate"))
                .userId(rs.getString("userId"))
                .build();

        enrichConsumerName(monthReport);
        return monthReport;
    }


    private void enrichConsumerName(MonthReport monthReport) {
        Set<String> connectionHolderIds = new HashSet<>();
        connectionHolderIds.add(monthReport.getUserId());
        UserSearchRequest userSearchRequest = new UserSearchRequest();
        userSearchRequest.setUuid(connectionHolderIds);
        UserDetailResponse userDetailResponse = userService.getUser(userSearchRequest);
        if (userDetailResponse != null && userDetailResponse.getUser() != null && !userDetailResponse.getUser().isEmpty()) {
            OwnerInfo ownerInfo = userDetailResponse.getUser().get(0);
            monthReport.setConsumerName(ownerInfo.getName());
        }
    }
}