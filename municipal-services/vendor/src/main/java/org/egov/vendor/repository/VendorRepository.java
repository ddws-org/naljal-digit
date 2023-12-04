package org.egov.vendor.repository;

import java.util.ArrayList;
import java.util.List;

import javax.validation.Valid;

import org.egov.tracer.model.CustomException;
import org.egov.vendor.config.VendorConfiguration;
import org.egov.vendor.producer.Producer;
import org.egov.vendor.repository.querybuilder.VendorQueryBuilder;
import org.egov.vendor.repository.rowmapper.VendorReportRowMapper;
import org.egov.vendor.repository.rowmapper.VendorRowMapper;
import org.egov.vendor.web.model.Vendor;
import org.egov.vendor.web.model.VendorReportData;
import org.egov.vendor.web.model.VendorRequest;
import org.egov.vendor.web.model.VendorSearchCriteria;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Repository;

import lombok.extern.slf4j.Slf4j;

@Repository
@Slf4j
public class VendorRepository {

	@Autowired
	private Producer producer;

	@Autowired
	private VendorConfiguration configuration;

	@Autowired
	private VendorQueryBuilder vendorQueryBuilder;

	@Autowired
	private JdbcTemplate jdbcTemplate;

	@Autowired
	private VendorRowMapper vendorrowMapper;

	@Autowired
	private VendorReportRowMapper vendorReportRowMapper;

	public void save(VendorRequest vendorRequest) {
		producer.push(configuration.getSaveTopic(), vendorRequest);
	}

	public List<Vendor> getVendorData(VendorSearchCriteria vendorSearchCriteria) {
		List<Object> preparedStmtList = new ArrayList<>();
		String query = vendorQueryBuilder.getVendorSearchQuery(vendorSearchCriteria, preparedStmtList);
		List<Vendor> vendorData = jdbcTemplate.query(query, preparedStmtList.toArray(), vendorrowMapper);
		System.out.println("query is " + query);
		return vendorData;
	}

	public List<String> getDrivers(String id) {
		List<String> ids = null;
		List<Object> preparedStmtList = new ArrayList<>();
		preparedStmtList.add(id);
		ids = jdbcTemplate.queryForList(vendorQueryBuilder.getDriverSearchQuery(), preparedStmtList.toArray(),
				String.class);
		return ids;
	}

	public List<String> getVehicles(String id) {
		List<String> ids = null;
		List<Object> preparedStmtList = new ArrayList<>();
		preparedStmtList.add(id);
		ids = jdbcTemplate.queryForList(vendorQueryBuilder.getVehicleSearchQuery(), preparedStmtList.toArray(),
				String.class);
		return ids;
	}

	public List<String> getVendorWithVehicles(List<String> vehicleIds) {
		List<String> vendorIds = null;
		List<Object> preparedStmtList = new ArrayList<>();
		vendorIds = jdbcTemplate.queryForList(vendorQueryBuilder.vendorsForVehicles(vehicleIds, preparedStmtList),
				preparedStmtList.toArray(), String.class);
		return vendorIds;
	}

	public List<String> fetchVendorIds(@Valid VendorSearchCriteria criteria) {
		List<Object> preparedStmtList = new ArrayList<>();
		preparedStmtList.add(criteria.getOffset());
		preparedStmtList.add(criteria.getLimit());

		List<String> ids = jdbcTemplate.query(
				"SELECT id from eg_vendor ORDER BY createdtime offset " + " ? " + "limit ? ",
				preparedStmtList.toArray(), new SingleColumnRowMapper<>(String.class));
		return ids;
	}

	public List<Vendor> getVendorPlainSearch(VendorSearchCriteria criteria) {

		if (criteria.getIds() == null || criteria.getIds().isEmpty())
			throw new CustomException("PLAIN_SEARCH_ERROR", "Search only allowed by ids!");

		List<Object> preparedStmtList = new ArrayList<>();
		String query = vendorQueryBuilder.getVendorLikeQuery(criteria, preparedStmtList);
		log.info("Query: " + query);
		log.info("PS: " + preparedStmtList);
		return jdbcTemplate.query(query, preparedStmtList.toArray(), vendorrowMapper);
	}

	public int getExistingVenodrsCount(List<String> ownerIdList, String tenantId) {
		List<Object> preparedStmtList = new ArrayList<>();

		String query = vendorQueryBuilder.getvendorCount(ownerIdList, tenantId,preparedStmtList);

		log.info("vendor exists query ===="+tenantId+"----"+ownerIdList.toString()+query);
		log.debug("vendor exists query ===="+tenantId+"----"+ownerIdList.toString()+query);
		return jdbcTemplate.queryForObject(query, preparedStmtList.toArray(), Integer.class);

	}

	public List<VendorReportData> getVendorReportData(Long monthStartDateTime, String tenantId, Integer offset, Integer limit)
	{
		StringBuilder vendor_report_query=new StringBuilder(vendorQueryBuilder.VENDOR_REPORT_QUERY);

		List<Object> preparedStatement=new ArrayList<>();
		preparedStatement.add(tenantId);
		preparedStatement.add(monthStartDateTime);
//		preparedStatement.add(monthEndDateTime);


		Integer newlimit=configuration.getDefaultLimit();
		Integer newoffset= configuration.getDefaultOffset();

		if(limit==null && offset==null)
			newlimit=configuration.getMaxSearchLimit();
		if(limit!=null && limit<=configuration.getMaxSearchLimit())
			newlimit=limit;
		if(limit!=null && limit>=configuration.getMaxSearchLimit())
			newlimit=configuration.getMaxSearchLimit();

		if(offset!=null)
			newoffset=offset;

		if (newlimit>0){
			vendor_report_query.append(" offset ?  limit ? ;");
			preparedStatement.add(newoffset);
			preparedStatement.add(newlimit);
		}

		log.info("Query of vendor report : "+vendor_report_query.toString()+" prepared statement of vendor report "+ preparedStatement);

		List<VendorReportData> vendorReportDataList=jdbcTemplate.query(vendor_report_query.toString() , preparedStatement.toArray(), vendorReportRowMapper);

		return vendorReportDataList;
	}
}
