package org.egov.echallan.repository.rowmapper;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.egov.echallan.model.UserInfo;
import org.egov.echallan.service.UserService;
import org.egov.echallan.web.models.ExpenseBillReportData;
import org.egov.echallan.web.models.ExpenseBillReportResponse;
import org.egov.echallan.web.models.user.User;
import org.egov.echallan.web.models.user.UserDetailResponse;
import org.egov.echallan.web.models.user.UserSearchRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.stereotype.Component;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

@Component
@Slf4j
public class ExpenseBillReportRowMapper implements ResultSetExtractor<List<ExpenseBillReportData>>
{
    @Autowired
    private ObjectMapper mapper;

    @Autowired
    private UserService userService;

    @Override
    public List<ExpenseBillReportData> extractData(ResultSet resultSet) throws SQLException, DataAccessException {

        List<ExpenseBillReportData> expenseBillReportDataList=new ArrayList<>();

        while(resultSet.next())
        {
            ExpenseBillReportData expenseBillReportData=new ExpenseBillReportData();
            expenseBillReportData.setTypeOfExpense(resultSet.getString("typeofexpense"));
            expenseBillReportData.setVendorName(resultSet.getString("name"));
            expenseBillReportData.setAmount(resultSet.getLong("total_taxamount"));
            expenseBillReportData.setBillDate(resultSet.getLong("billdate"));
            expenseBillReportData.setTaxPeriodFrom(resultSet.getLong("taxperiodfrom"));
            expenseBillReportData.setTaxPeriodTo(resultSet.getLong("taxperiodto"));
            expenseBillReportData.setApplicationStatus(resultSet.getString("applicationstatus"));

            if(resultSet.getString("paiddate")!=null)
                expenseBillReportData.setPaidDate(resultSet.getLong("paiddate"));
            else
                expenseBillReportData.setPaidDate(0L);
            if(resultSet.getString("filestoreid")!=null)
                expenseBillReportData.setFilestoreid("Yes");
            else
                expenseBillReportData.setFilestoreid("No");
            if(Objects.equals(resultSet.getString("applicationstatus"), "CANCELLED")) {
                expenseBillReportData.setLastModifiedTime(resultSet.getLong("lastmodifiedtime"));
                expenseBillReportData.setLastModifiedByUuid(resultSet.getString("lastmodifiedbyUuid"));
                enrichExpenseHolderDetails(expenseBillReportData);
            }
            else
            {
                expenseBillReportData.setLastModifiedTime(0L);
                expenseBillReportData.setLastModifiedBy(null);
            }
            expenseBillReportDataList.add(expenseBillReportData);
        }
        return expenseBillReportDataList;
    }

    private void enrichExpenseHolderDetails(ExpenseBillReportData expenseBillReportData)
    {
        UserSearchRequest userSearchRequest=new UserSearchRequest();
        userSearchRequest.setUuid(Collections.singletonList(expenseBillReportData.getLastModifiedByUuid()));
        log.info("Uuid's for searching users"+userSearchRequest.getUuid().toString());

        UserDetailResponse userDetailResponse=userService.getUsers(userSearchRequest);
        log.info("User after searching"+userDetailResponse.getUser().toString());

        enrichConnectionHolderInfo(userDetailResponse,expenseBillReportData);
    }

    private void enrichConnectionHolderInfo(UserDetailResponse userDetailResponse, ExpenseBillReportData expenseBillReportData)
    {
          List<UserInfo> connectionHolderInfos= userDetailResponse.getUser();
        if (connectionHolderInfos.isEmpty()) {
            return;
        }
          log.info("Users in enrichConnectionHolderInfo method"+connectionHolderInfos.toString());
          expenseBillReportData.setLastModifiedBy(connectionHolderInfos.get(0).getName());
    }
}
