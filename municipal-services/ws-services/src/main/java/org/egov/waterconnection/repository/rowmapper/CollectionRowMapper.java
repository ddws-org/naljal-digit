package org.egov.waterconnection.repository.rowmapper;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.egov.waterconnection.service.UserService;
import org.egov.waterconnection.web.models.CollectionReportData;
import org.egov.waterconnection.web.models.OwnerInfo;
import org.egov.waterconnection.web.models.users.UserDetailResponse;
import org.egov.waterconnection.web.models.users.UserSearchRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.ResultSetExtractor;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.ObjectMapper;

@Component
public class CollectionRowMapper implements ResultSetExtractor<List<CollectionReportData>> {

	@Autowired
	private ObjectMapper mapper;
	
	@Autowired
	private UserService userService;
	
	@Override
	public List<CollectionReportData> extractData(ResultSet rs) throws SQLException, DataAccessException {
		List<CollectionReportData> collectionReportDataList = new ArrayList<>();
		while (rs.next()) {
			        CollectionReportData collectionReportData = new CollectionReportData();
			    	collectionReportData.setTenantName(rs.getString("tenantId"));
			    	collectionReportData.setConnectionNo(rs.getString("connectionNo"));
			    	collectionReportData.setOldConnectionNo(rs.getString("oldConnectionNo"));
			    	collectionReportData.setUserId(rs.getString("uuid"));
			    	collectionReportData.setPaymentMode(rs.getString("paymentmode"));
			    	collectionReportData.setPaymentAmount(rs.getBigDecimal("totalAmountPaid"));
                    collectionReportDataList.add(collectionReportData);
		}
		if(!collectionReportDataList.isEmpty()){
			enrichConnectionHolderDetails(collectionReportDataList);
		}
		return collectionReportDataList;
	}

	private void setPayments(ResultSet rs, CollectionReportData collectionReportData, Map<String, CollectionReportData> reportData)
			throws SQLException {
		
		collectionReportData.getPaymentAmount().add(rs.getBigDecimal("amountpaid"));
		reportData.put(rs.getString("connectionNo"), collectionReportData);
	}

	private void enrichConnectionHolderDetails(List<CollectionReportData> collectionReportDataList) {
		Set<String> connectionHolderIds = new HashSet<>();
		for (CollectionReportData collectionReportData : collectionReportDataList) {
				connectionHolderIds.add(collectionReportData.getUserId());
		}
		UserSearchRequest userSearchRequest = new UserSearchRequest();
		userSearchRequest.setUuid(connectionHolderIds);
		UserDetailResponse userDetailResponse = userService.getUser(userSearchRequest);
		enrichConnectionHolderInfo(userDetailResponse, collectionReportDataList);
		
	}

	private void enrichConnectionHolderInfo(UserDetailResponse userDetailResponse,
			List<CollectionReportData> collectionReportDataList) {
		List<OwnerInfo> connectionHolderInfos = userDetailResponse.getUser();
		Map<String, OwnerInfo> userIdToConnectionHolderMap = new HashMap<>();
		connectionHolderInfos.forEach(user -> userIdToConnectionHolderMap.put(user.getUuid(), user));
		collectionReportDataList.forEach(collectionReportData-> collectionReportData.setConsumerName(userIdToConnectionHolderMap.get(collectionReportData.getUserId()).getName()));
		}
	
	
}