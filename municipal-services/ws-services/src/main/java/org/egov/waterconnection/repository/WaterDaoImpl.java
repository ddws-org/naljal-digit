package org.egov.waterconnection.repository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import jakarta.validation.Valid;

import org.apache.commons.lang3.StringUtils;
import org.egov.common.contract.request.RequestInfo;
import org.egov.common.contract.request.Role;
import org.egov.common.contract.request.User;
import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.config.WSConfiguration;
import org.egov.waterconnection.constants.WCConstants;
import org.egov.waterconnection.producer.WaterConnectionProducer;
import org.egov.waterconnection.repository.builder.WsQueryBuilder;
import org.egov.waterconnection.repository.rowmapper.*;
import org.egov.waterconnection.web.models.*;
import org.egov.waterconnection.repository.rowmapper.BillingCycleRowMapper;
import org.egov.waterconnection.repository.rowmapper.CollectionRowMapper;
import org.egov.waterconnection.repository.rowmapper.FeedbackRowMapper;
import org.egov.waterconnection.repository.rowmapper.OpenWaterRowMapper;
import org.egov.waterconnection.repository.rowmapper.ReportRowMapper;
import org.egov.waterconnection.repository.rowmapper.WaterRowMapper;
import org.egov.waterconnection.web.models.BillReportData;
import org.egov.waterconnection.web.models.BillingCycle;
import org.egov.waterconnection.web.models.CollectionReportData;
import org.egov.waterconnection.web.models.Feedback;
import org.egov.waterconnection.web.models.FeedbackSearchCriteria;
import org.egov.waterconnection.web.models.SearchCriteria;
import org.egov.waterconnection.web.models.WaterConnection;
import org.egov.waterconnection.web.models.WaterConnectionRequest;
import org.egov.waterconnection.web.models.WaterConnectionResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SingleColumnRowMapper;
import org.springframework.stereotype.Repository;
import org.springframework.util.CollectionUtils;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Repository
public class WaterDaoImpl implements WaterDao {

	@Autowired
	private ConsumerRowMapper consumerRowMapper;

	@Autowired
	private MonthReportRowMapper monthReportRowMapper;

	@Autowired
	private PaymentRowMapper paymentRowMapper;

	@Autowired
	private LedgerReportRowMapper ledgerReportRowMapper;
    @Autowired
	private DemandNotGeneratedRowMapper demandNotGeneratedRowMapper;

	@Autowired
	private InactiveConsumerReportRowMapper inactiveConsumerReportRowMapper;
	@Autowired
	private WaterConnectionProducer waterConnectionProducer;

	@Autowired
	private JdbcTemplate jdbcTemplate;

	@Autowired
	private WsQueryBuilder wsQueryBuilder;

	@Autowired
	private WaterRowMapper waterRowMapper;

	@Autowired
	private OpenWaterRowMapper openWaterRowMapper;

	@Autowired
	private WcbyDemandRowMapper wcbyDemandRowMapper;
	
	@Autowired
	private ReportRowMapper reportRowMapper;
	
	@Autowired
	private CollectionRowMapper collectionReportRowMapper;
	
	@Autowired
	private WSConfiguration wsConfiguration;

	@Value("${egov.waterservice.createwaterconnection.topic}")
	private String createWaterConnection;

	@Value("${egov.waterservice.updatewaterconnection.topic}")
	private String updateWaterConnection;
	
	@Autowired
	private BillingCycleRowMapper billingCycleRowMapper;

	@Autowired
    private FeedbackRowMapper feedbackRowMapper;
	
	@Override
	public void saveWaterConnection(WaterConnectionRequest waterConnectionRequest) {
		waterConnectionProducer.push(createWaterConnection, waterConnectionRequest);
	}

	@Override
	public WaterConnectionResponse getWaterConnectionList(SearchCriteria criteria, RequestInfo requestInfo) {

		List<WaterConnection> waterConnectionList = new ArrayList<>();
		List<Object> preparedStatement = new ArrayList<>();
		Map<String, Long> collectionDataCount = null;
		List<Map<String, Object>> countData = null;
		Boolean flag = null;
		Set<String> consumerCodeSet = null;
		
		String query = wsQueryBuilder.getSearchQueryString(criteria, preparedStatement, requestInfo);

		if (query == null)
			return null;
		
		if(criteria.getIsCollectionCount() != null && criteria.getIsCollectionCount()) {
			List<Object> preparedStmntforCollectionDataCount = new ArrayList<>();
			StringBuilder collectionDataCountQuery = new StringBuilder(wsQueryBuilder.COLLECTION_DATA_COUNT);
			criteria.setIsCollectionDataCount(Boolean.TRUE);
			collectionDataCountQuery = wsQueryBuilder.applyFilters(collectionDataCountQuery, preparedStmntforCollectionDataCount, criteria);
//			collectionDataCountQuery.append(" ORDER BY wc.appCreatedDate  DESC");
		    countData = jdbcTemplate.queryForList(collectionDataCountQuery.toString(), preparedStmntforCollectionDataCount.toArray());
		    if(criteria.getIsBillPaid() != null)
		    	flag = criteria.getIsBillPaid();
		}

		Boolean isOpenSearch = isSearchOpen(requestInfo.getUserInfo());
		WaterConnectionResponse connectionResponse = new WaterConnectionResponse();
		if (isOpenSearch) {
			waterConnectionList = jdbcTemplate.query(query, preparedStatement.toArray(), openWaterRowMapper);
			connectionResponse = WaterConnectionResponse.builder().waterConnection(waterConnectionList)
					.totalCount(openWaterRowMapper.getFull_count()).build();
		} else {
                log.info("HouseHold Register Query",query);
				log.info("Prepared Statement of household register ",preparedStatement.toArray());
			waterConnectionList = jdbcTemplate.query(query, preparedStatement.toArray(), waterRowMapper);
			Map<String, Object> counter = new HashMap();
			if (criteria.getIsPropertyCount()!= null && criteria.getIsPropertyCount()) {
				List<Object> preparedStmnt = new ArrayList<>();
				StringBuilder propertyQuery = new StringBuilder(wsQueryBuilder.PROPERTY_COUNT);
				propertyQuery = wsQueryBuilder.applyFilters(propertyQuery, preparedStmnt, criteria);
				propertyQuery.append("GROUP BY additionaldetails->>'propertyType'");
				List<Map<String, Object>> data = jdbcTemplate.queryForList(propertyQuery.toString(),
						preparedStmnt.toArray());
				for (Map<String, Object> map : data) {
					if(map.get("propertytype")!=null) {
						counter.put(map.get("propertytype").toString(), map.get("count").toString()) ;
					}
				}
			}
			collectionDataCount =  getCollectionDataCounter(countData, flag);
			connectionResponse = WaterConnectionResponse.builder().waterConnection(waterConnectionList)
					.totalCount(waterRowMapper.getFull_count()).collectionDataCount(collectionDataCount).propertyCount(counter).build();
		}
		return connectionResponse;
	}

	@Override
	public void updateWaterConnection(WaterConnectionRequest waterConnectionRequest, boolean isStateUpdatable) {
		if (isStateUpdatable) {
			waterConnectionProducer.push(updateWaterConnection, waterConnectionRequest);
		} else {
			waterConnectionProducer.push(wsConfiguration.getWorkFlowUpdateTopic(), waterConnectionRequest);
		}
	}
	public WaterConnectionByDemandGenerationDateResponse getWaterConnectionByDemandDate (SearchCriteria criteria, RequestInfo requestInfo) {

		List<WaterConnectionByDemandGenerationDate> waterConnectionByPreviousReadingDateList = new ArrayList<>();
		List<WaterConnectionByDemandGenerationDate> waterConnectionByDemandGenerationDateList = new ArrayList<>();
		WaterConnectionByDemandGenerationDateResponse response = new WaterConnectionByDemandGenerationDateResponse();
		List<Object> preparedStatement = new ArrayList<>();
		String query1 = wsQueryBuilder.getQueryForWCCountForPreviousreadingdate(criteria, preparedStatement, requestInfo);
		if (query1 == null)
			return null;
		waterConnectionByPreviousReadingDateList = jdbcTemplate.query(query1, preparedStatement.toArray(), wcbyDemandRowMapper);
	    String query2 = wsQueryBuilder.getQueryForWCCountbyDemandDate(criteria, preparedStatement, requestInfo);

		if (query2 == null)
			return null;
		waterConnectionByDemandGenerationDateList = jdbcTemplate.query(query2, preparedStatement.toArray(), wcbyDemandRowMapper);
		response.setWaterConnectionByDemandGenerationDates(waterConnectionByDemandGenerationDateList);
		response.setWaterConnectionByDemandNotGeneratedDates(waterConnectionByPreviousReadingDateList);
		return response;
	}

	/**
	 * push object to create meter reading
	 * 
	 * @param waterConnectionRequest
	 */
	public void postForMeterReading(WaterConnectionRequest waterConnectionRequest) {
		log.info("Posting request to kafka topic - " + wsConfiguration.getCreateMeterReading());
		waterConnectionProducer.push(wsConfiguration.getCreateMeterReading(), waterConnectionRequest);
	}

	/**
	 * push object for edit notification
	 * 
	 * @param waterConnectionRequest
	 */
	public void pushForEditNotification(WaterConnectionRequest waterConnectionRequest) {
		if (!WCConstants.EDIT_NOTIFICATION_STATE
				.contains(waterConnectionRequest.getWaterConnection().getProcessInstance().getAction())) {
			waterConnectionProducer.push(wsConfiguration.getEditNotificationTopic(), waterConnectionRequest);
		}
	}
	
	/**
	 * Enrich file store Id's
	 * 
	 * @param waterConnectionRequest
	 */
	public void enrichFileStoreIds(WaterConnectionRequest waterConnectionRequest) {
		try {
			log.info("ACTION "+waterConnectionRequest.getWaterConnection().getProcessInstance().getAction());
			log.info("ApplicationStatus "+waterConnectionRequest.getWaterConnection().getApplicationStatus());
			if (waterConnectionRequest.getWaterConnection().getApplicationStatus()
					.equalsIgnoreCase(WCConstants.PENDING_APPROVAL_FOR_CONNECTION_CODE)
					|| waterConnectionRequest.getWaterConnection().getProcessInstance().getAction()
					.equalsIgnoreCase(WCConstants.ACTION_PAY)) {
				waterConnectionProducer.push(wsConfiguration.getFileStoreIdsTopic(), waterConnectionRequest);
			}
		} catch (Exception ex) {
			log.debug(ex.toString());
		}
	}
	
	/**
	 * Save file store Id's
	 * 
	 * @param waterConnectionRequest
	 */
	public void saveFileStoreIds(WaterConnectionRequest waterConnectionRequest) {
		waterConnectionProducer.push(wsConfiguration.getSaveFileStoreIdsTopic(), waterConnectionRequest);
	}

	public Boolean isSearchOpen(User userInfo) {

		return userInfo.getType().equalsIgnoreCase("SYSTEM")
				&& userInfo.getRoles().stream().map(Role::getCode).collect(Collectors.toSet()).contains("ANONYMOUS");
	}
	
	public BillingCycle getBillingCycle(String paymentId) {

		String query = WsQueryBuilder.GET_BILLING_CYCLE;

		List<Object> prepareStatementList = new ArrayList<Object>();

		prepareStatementList.add(paymentId);

		List<BillingCycle> billingCycleList = jdbcTemplate.query(query, prepareStatementList.toArray(),
				billingCycleRowMapper);

		return billingCycleList.get(0);
	}

	public List<Feedback> getFeebback(FeedbackSearchCriteria feedbackSearchCriteria) {

		List<Object> preparedStamentValues = new ArrayList<Object>();
		String query = wsQueryBuilder.getFeedback(feedbackSearchCriteria, preparedStamentValues);
		List<Feedback> feedBackList = jdbcTemplate.query(query, preparedStamentValues.toArray(), feedbackRowMapper);
		return feedBackList;
	}
	
	public Map<String, Long> getCollectionDataCounter(List<Map<String, Object>> countDataMap, Boolean flag) {
		Map<String, Long> collectionDataCountMap = new HashMap<>();
		Long paidCount = 0L;
		Long pendingCount = 0L;
		
		if(!CollectionUtils.isEmpty(countDataMap)) {
			for(Map<String, Object> wc : countDataMap) {
				BigDecimal collectionPendingAmount = (BigDecimal)wc.get("pendingamount");
				if(collectionPendingAmount != null ) {
					if(collectionPendingAmount.compareTo(BigDecimal.ZERO) <= 0) {
						++paidCount;
					}
					else {
						++pendingCount;
					}
				}else {
					++paidCount;
				}
			}
			if(flag != null) {
				if(flag) 
					collectionDataCountMap.put("collectionPaid", paidCount);
				else if(!flag) 
					collectionDataCountMap.put("collectionPending", pendingCount);
			}else {
				collectionDataCountMap.put("collectionPaid", paidCount);
				collectionDataCountMap.put("collectionPending", pendingCount);
			}
		}
		return collectionDataCountMap;
	}

	public BigDecimal getTotalDemandAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.NEWDEMAND);
		query.append(" and dmd.taxperiodto between " + criteria.getFromDate() + " and " + criteria.getToDate())
				.append(" and dmd.tenantId = '").append(criteria.getTenantId()).append("'");
		return jdbcTemplate.queryForObject(query.toString(), BigDecimal.class);
	}

	public BigDecimal getActualCollectionAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.ACTUALCOLLECTION);
		query.append(" and py.transactionDate  >= ").append(criteria.getFromDate()).append(" and py.transactionDate <= ")
				.append(criteria.getToDate()).append(" and py.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Actual Collection Final Query: " + query);
		return jdbcTemplate.queryForObject(query.toString(), BigDecimal.class);

	}

	public BigDecimal getPendingCollectionAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.PENDINGCOLLECTION);
		query.append(" and dmd.taxperiodto between " + criteria.getFromDate() + " and " + criteria.getToDate())
				.append(" and dmd.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Active Pending Collection Query : " + query);
		return jdbcTemplate.queryForObject(query.toString(), BigDecimal.class);

	}


	public Integer getResidentialCollectionAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.RESIDENTIALCOLLECTION);
		query.append(" and py.transactionDate  >= ").append(criteria.getFromDate()).append(" and py.transactionDate <= ")
				.append(criteria.getToDate()).append(" and py.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Residential Final Query: " + query);
		return jdbcTemplate.queryForObject(query.toString(), Integer.class);

	}


	public Integer getCommercialCollectionAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.COMMERCIALCOLLECTION);
		query.append(" and py.transactionDate  >= ").append(criteria.getFromDate()).append(" and py.transactionDate <= ")
				.append(criteria.getToDate()).append(" and py.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Comercial Final Query: " + query);
		return jdbcTemplate.queryForObject(query.toString(), Integer.class);

	}


	public Integer getOthersCollectionAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.OTHERSCOLLECTION);
		query.append(" and py.transactionDate  >= ").append(criteria.getFromDate()).append(" and py.transactionDate <= ")
				.append(criteria.getToDate()).append(" and py.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Others Final Query: " + query);
		return jdbcTemplate.queryForObject(query.toString(), Integer.class);

	}


	public Map<String, Object> getResidentialPaid(@Valid SearchCriteria criteria) {

		StringBuilder paidCountQuesry = new StringBuilder(wsQueryBuilder.RESIDENTIALSPAIDCOUNT);
		paidCountQuesry.append(" and py.transactionDate  >= ").append(criteria.getFromDate())
				.append(" and py.transactionDate <= ").append(criteria.getToDate()).append(" and py.tenantId = '")
				.append(criteria.getTenantId()).append("'");
		String finalQuery = wsQueryBuilder.RESIDENTIALSPAID;
		finalQuery = finalQuery.replace("{paidCount}", paidCountQuesry);
		StringBuilder query = new StringBuilder(finalQuery);
		query.append(" and tenantId = '").append(criteria.getTenantId()).append("'");
		System.out.println("Residential count Final Query: " + query);
		return jdbcTemplate.queryForMap(query.toString());

	}


	public Map<String, Object> getCommercialPaid(@Valid SearchCriteria criteria) {
		
		StringBuilder paidCountQuesry = new StringBuilder(wsQueryBuilder.COMMERCIALSPAIDCOUNT);
		paidCountQuesry.append(" and py.transactionDate  >= ").append(criteria.getFromDate())
				.append(" and py.transactionDate <= ").append(criteria.getToDate()).append(" and py.tenantId = '")
				.append(criteria.getTenantId()).append("'");
		String finalQuery = wsQueryBuilder.COMMERCIALSPAID;
		finalQuery = finalQuery.replace("{paidCount}", paidCountQuesry);
		StringBuilder query = new StringBuilder(finalQuery);
		query.append(" and tenantId = '").append(criteria.getTenantId()).append("'");
		System.out.println("Comercial count Final Query: " + query);
		return jdbcTemplate.queryForMap(query.toString());

	}


	public Map<String, Object> getAllPaid(@Valid SearchCriteria criteria) {
		StringBuilder paidCountQuesry = new StringBuilder(wsQueryBuilder.TOTALAPPLICATIONSPAIDCOUNT);
		paidCountQuesry.append(" and py.transactionDate  >= ").append(criteria.getFromDate())
				.append(" and py.transactionDate <= ").append(criteria.getToDate()).append(" and py.tenantId = '")
				.append(criteria.getTenantId()).append("'");
		String finalQuery = wsQueryBuilder.TOTALAPPLICATIONSPAID;
		finalQuery = finalQuery.replace("{paidCount}", paidCountQuesry);
		StringBuilder query = new StringBuilder(finalQuery);
		query.append(" and tenantId = '").append(criteria.getTenantId()).append("'");
		System.out.println("Total Count Final Query: " + query);
		return jdbcTemplate.queryForMap(query.toString());

	}

	
	@Override
	public List<String> getWCListFuzzySearch(SearchCriteria criteria) {
		List<Object> preparedStatementList = new ArrayList<>();

		String query = wsQueryBuilder.getIds(criteria, preparedStatementList);
		
		try {
			return jdbcTemplate.query(query, preparedStatementList.toArray(), new SingleColumnRowMapper<>());
		}catch (Exception e) {
			log.error("error while getting ids from db: "+e.getMessage());
			throw new CustomException("EG_WC_QUERY_EXCEPTION", "error while getting ids from db");
		}
		
	}
	
	@Override
	public WaterConnectionResponse getWaterConnectionListForPlaneSearch(SearchCriteria criteria, RequestInfo requestInfo) {

		List<WaterConnection> waterConnectionList = new ArrayList<>();
		List<Object> preparedStatement = new ArrayList<>();
		
		Set<String> ids = new HashSet<String>();
		List<String> connectionIds = null;
		if (criteria.getIds() != null && !criteria.getIds().isEmpty())
			ids = criteria.getIds();
		else
			connectionIds = fetchWaterConIds(criteria);

		if(connectionIds!=null && connectionIds.size()>0) {
//		for (String id : connectionIds) {
			ids.addAll(connectionIds);
//		}
		}
		if (ids.isEmpty())
			return new WaterConnectionResponse();

		criteria.setIds(ids);
		
		String query = wsQueryBuilder.getSearchQueryStringForPlaneSearch(criteria, preparedStatement, requestInfo);

		if (query == null)
			return null;
		
		Boolean isOpenSearch = isSearchOpen(requestInfo.getUserInfo());
		WaterConnectionResponse connectionResponse = new WaterConnectionResponse();
		if (isOpenSearch) {
			waterConnectionList = jdbcTemplate.query(query, preparedStatement.toArray(), openWaterRowMapper);
			connectionResponse = WaterConnectionResponse.builder().waterConnection(waterConnectionList)
					.totalCount(openWaterRowMapper.getFull_count()).build();
		} else {
			waterConnectionList = jdbcTemplate.query(query, preparedStatement.toArray(), waterRowMapper);
			connectionResponse = WaterConnectionResponse.builder().waterConnection(waterConnectionList)
					.totalCount(waterRowMapper.getFull_count()).build();
		}
		return connectionResponse;
	}
	
	

	public List<String> fetchWaterConIds(SearchCriteria criteria) {
		List<Object> preparedStmtList = new ArrayList<>();
		preparedStmtList.add(criteria.getOffset());
		preparedStmtList.add(criteria.getLimit());

		List<String> ids = jdbcTemplate.query("SELECT id from eg_ws_connection ORDER BY createdtime offset " +
						" ? " +
						"limit ? ",
				preparedStmtList.toArray(),
				new SingleColumnRowMapper<>(String.class));
		return ids;
	}


	public List<WaterConnection> getWSPlainSearch(SearchCriteria criteria, RequestInfo requestInfo) {
		if(criteria.getIds() == null || criteria.getIds().isEmpty())
			throw new CustomException("PLAIN_SEARCH_ERROR", "Search only allowed by ids!");

		List<WaterConnection> waterConnectionList = new ArrayList<>();

		List<Object> preparedStmtList = new ArrayList<>();
		String query = wsQueryBuilder.getSearchQueryStringForPlaneSearch(criteria, preparedStmtList, requestInfo);
		log.info("Query: "+query);
		log.info("PS: "+preparedStmtList);
		Boolean isOpenSearch = isSearchOpen(requestInfo.getUserInfo());
		WaterConnectionResponse connectionResponse = new WaterConnectionResponse();
		if (isOpenSearch) {
			waterConnectionList = jdbcTemplate.query(query, preparedStmtList.toArray(), openWaterRowMapper);
			connectionResponse = WaterConnectionResponse.builder().waterConnection(waterConnectionList)
					.totalCount(openWaterRowMapper.getFull_count()).build();
		} else {
			waterConnectionList = jdbcTemplate.query(query, preparedStmtList.toArray(), waterRowMapper);
			connectionResponse = WaterConnectionResponse.builder().waterConnection(waterConnectionList)
					.totalCount(waterRowMapper.getFull_count()).build();
		}
		
		return connectionResponse.getWaterConnection();
		
	}
	

	
	public Integer getPendingCollectionAmountTillDate(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.PENDINGCOLLECTIONTILLDATE);
		query.append(" and dmd.taxperiodto <= " +  criteria.getToDate())
				.append(" and dmd.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Active pending collection query : " + query);
		return jdbcTemplate.queryForObject(query.toString(), Integer.class);

	}
	
	public BigDecimal getArrearsAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.PENDINGCOLLECTION);
		long prevMonthEndDate =  criteria.getFromDate()-1;
		query.append(" and dmd.taxperiodto <= " + prevMonthEndDate)
				.append(" and dmd.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Arrears Amount Final Query : " + query);
		return jdbcTemplate.queryForObject(query.toString(), BigDecimal.class);

	}

	public BigDecimal getTotalAdvanceAdjustedAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.ADVANCEADJUSTED);
		query.append(" and dmd.taxperiodto between " + criteria.getFromDate() + " and " + criteria.getToDate())
		.append(" and dmd.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Active Advance Adjusted Query : " + query);
		return jdbcTemplate.queryForObject(query.toString(), BigDecimal.class);
	}

	public BigDecimal getTotalPendingPenaltyAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.PENDINGPENALTY);
		query.append(" and dmd.taxperiodto between " + criteria.getFromDate() + " and " + criteria.getToDate())
		.append(" and dmd.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Pending Penalty Query : " + query);
		return jdbcTemplate.queryForObject(query.toString(), BigDecimal.class);
	}

	public BigDecimal getAdvanceCollectionAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.ADVANCECOLLECTION);
		query.append(" and dmd.taxperiodto between " + criteria.getFromDate() + " and " + criteria.getToDate())
		.append(" and dmd.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Advance Collection Query : " + query);
		return jdbcTemplate.queryForObject(query.toString(), BigDecimal.class);
	}


	public BigDecimal getPenaltyCollectionAmount(@Valid SearchCriteria criteria) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.PENALTYCOLLECTION);
		query.append(" and py.transactionDate  >= ").append(criteria.getFromDate()).append(" and py.transactionDate <= ")
				.append(criteria.getToDate()).append(" and py.tenantId = '").append(criteria.getTenantId()).append("'");
		log.info("Penalty Collection Final Query: " + query);
		return jdbcTemplate.queryForObject(query.toString(), BigDecimal.class);
	}

	public List<BillReportData> getBillReportData(@Valid Long demandStartDate,@Valid Long demandEndDate, @Valid String tenantId, @Valid Integer offset, @Valid Integer limit, @Valid String sortOrder) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.BILL_REPORT_QUERY);
		List<Object> preparedStatement = new ArrayList<>();
        preparedStatement.add(demandStartDate);
		preparedStatement.add(demandEndDate);
		preparedStatement.add(tenantId);

        if(sortOrder.equals(SearchCriteria.SortOrder.DESC.name()))
           query.append(" DESC ");
		else
			query.append(" ASC ");

		Integer newlimit=wsConfiguration.getDefaultLimit();
		Integer newoffset= wsConfiguration.getDefaultOffset();
		if(limit==null && offset==null)
			newlimit=wsConfiguration.getMaxLimit();
		if(limit!=null && limit<=wsConfiguration.getMaxLimit())
			newlimit=limit;
		if(limit!=null && limit>=wsConfiguration.getMaxLimit())
			newlimit=wsConfiguration.getMaxLimit();

		if(offset!=null)
			newoffset=offset;

		if(newlimit > 0) {
				query.append(" offset ?  limit ? ;");
			preparedStatement.add(newoffset);
			preparedStatement.add(newlimit);
		}
		List<BillReportData> billReportList = new ArrayList<>();
		try {

			billReportList = jdbcTemplate.query(query.toString(), preparedStatement.toArray(), reportRowMapper);
		}
		catch(Exception e){
			Map<String,String> ex = new  HashMap<String,String>(){{
				put("DataIntegrityViolationException","e");
			}};
			throw new CustomException(ex);
		}
		return billReportList;
			
	}

	public List<CollectionReportData> getCollectionReportData(Long payStartDateTime, Long payEndDateTime,
			String tenantId,@Valid Integer offset, @Valid Integer limit, @Valid String sortOrder) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.COLLECTION_REPORT_QUERY);

		List<Object> preparedStatement = new ArrayList<>();
		             preparedStatement.add(tenantId);
                     preparedStatement.add(payStartDateTime);
					 preparedStatement.add(payEndDateTime);
					 preparedStatement.add(tenantId);
		             preparedStatement.add(tenantId);

		if(sortOrder.equals(SearchCriteria.SortOrder.DESC.name()))
			query.append(" DESC ");
		else
			query.append(" ASC ");

		Integer newlimit=wsConfiguration.getDefaultLimit();
		Integer newoffset= wsConfiguration.getDefaultOffset();
		if(limit==null && offset==null)
			newlimit=wsConfiguration.getMaxLimit();
		if(limit!=null && limit<=wsConfiguration.getMaxLimit())
			newlimit=limit;
		if(limit!=null && limit>=wsConfiguration.getMaxLimit())
			newlimit=wsConfiguration.getMaxLimit();

		if(offset!=null)
			newoffset=offset;

		if (newlimit>0){
			query.append(" offset ?  limit ? ;");
			preparedStatement.add(newoffset);
			preparedStatement.add(newlimit);
		}

		List<CollectionReportData> collectionReportList = new ArrayList<>();
		collectionReportList = jdbcTemplate.query(query.toString(), preparedStatement.toArray(), collectionReportRowMapper);
		return collectionReportList;
	}

    public List<InactiveConsumerReportData> getInactiveConsumerReport(Long monthStartDateTime, Long monthEndDateTime, @Valid String tenantId, @Valid Integer offset, @Valid Integer limit)
	{
         StringBuilder inactive_consumer_query=new StringBuilder(wsQueryBuilder.INACTIVE_CONSUMER_QUERY);

		 List<Object> preparedStatement=new ArrayList<>();
		preparedStatement.add(monthStartDateTime);
		preparedStatement.add(monthEndDateTime);
		preparedStatement.add(tenantId);
		preparedStatement.add(monthStartDateTime);
		preparedStatement.add(monthEndDateTime);
		preparedStatement.add(tenantId);

		Integer newlimit=wsConfiguration.getDefaultLimit();
		Integer newoffset= wsConfiguration.getDefaultOffset();
		if(limit==null && offset==null)
			newlimit=wsConfiguration.getMaxLimit();
		if(limit!=null && limit<=wsConfiguration.getMaxLimit())
			newlimit=limit;
		if(limit!=null && limit>=wsConfiguration.getMaxLimit())
			newlimit=wsConfiguration.getMaxLimit();

		if(offset!=null)
			newoffset=offset;

		if (newlimit>0){
			inactive_consumer_query.append(" offset ?  limit ? ;");
			preparedStatement.add(newoffset);
			preparedStatement.add(newlimit);
		}

		List<InactiveConsumerReportData> inactiveConsumerReportList=new ArrayList<>();
		log.info("Query of inactive consumer:"+ inactive_consumer_query.toString() +"prepared statement of inactive consumer"+ preparedStatement);
		inactiveConsumerReportList=jdbcTemplate.query(inactive_consumer_query.toString(), preparedStatement.toArray(),inactiveConsumerReportRowMapper);
         return inactiveConsumerReportList;
    }

	public List<ConsumersDemandNotGenerated> getConsumersByPreviousMeterReading(Long previousMeterReading, String tenantId) {
		StringBuilder query = new StringBuilder(wsQueryBuilder.DEMAND_NOT_GENERATED_QUERY);

		List<Object> preparedStatement = new ArrayList<>();
		preparedStatement.add(tenantId);
		preparedStatement.add(previousMeterReading);
		preparedStatement.add(tenantId);

		log.info("Query for consumer demand not generated " + query + " prepared statement " + preparedStatement);
		List<ConsumersDemandNotGenerated> consumersDemandNotGeneratedList = jdbcTemplate.query(query.toString(), preparedStatement.toArray(), demandNotGeneratedRowMapper);
		return consumersDemandNotGeneratedList;
	}

	public List<Map<String, Object>> getLedgerReport(String consumercode, String tenantId, Integer offset, Integer limit, String year,RequestInfoWrapper requestInfoWrapper) {
		String[] years = year.split("-");
		if (years.length != 2) {
			throw new IllegalArgumentException("Invalid fiscal year format");
		}
		int startYear = Integer.parseInt(years[0]);
		int endYear = Integer.parseInt(years[1]);

		LocalDate startDate = LocalDate.of(startYear, 4, 1);
		LocalDate endDate = LocalDate.of(startYear + 1, 3, 31);

		Long startDateTime = LocalDateTime.of(startDate.getYear(), startDate.getMonth(), startDate.getDayOfMonth(), 0, 0, 0)
				.atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();
		Long endDateTime = LocalDateTime.of(endDate, LocalTime.MAX).atZone(ZoneId.systemDefault()).toInstant().toEpochMilli();

		StringBuilder query = new StringBuilder(wsQueryBuilder.LEDGER_REPORT_QUERY);

		List<Object> preparedStatement = new ArrayList<>();
		preparedStatement.add(consumercode);
		preparedStatement.add(tenantId);
		preparedStatement.add(startDateTime);
		preparedStatement.add(endDateTime);

		Integer newlimit = wsConfiguration.getDefaultLimit();
		Integer newoffset = wsConfiguration.getDefaultOffset();
		if (limit == null && offset == null)
			newlimit = wsConfiguration.getMaxLimit();
		if (limit != null && limit <= wsConfiguration.getMaxLimit())
			newlimit = limit;
		if (limit != null && limit >= wsConfiguration.getMaxLimit())
			newlimit = wsConfiguration.getMaxLimit();
		if (limit != null && limit == -1) // Handling the case when limit is -1
			newlimit = -1;
		if (offset != null)
			newoffset = offset;

		if (newlimit > 0) {
			query.append(" offset ?  limit ? ;");
			preparedStatement.add(newoffset);
			preparedStatement.add(newlimit);
		}

		log.info("Query of ledger report:" + query + "and prepared statement" + preparedStatement);
		ledgerReportRowMapper.setTenantId(tenantId);
		ledgerReportRowMapper.setRequestInfo(requestInfoWrapper);
		ledgerReportRowMapper.setStartYear(startYear);
		ledgerReportRowMapper.setEndYear(endYear);
		ledgerReportRowMapper.setConsumerCode(consumercode);
		List<Map<String, Object>> ledgerReportList= jdbcTemplate.query(query.toString(), preparedStatement.toArray(), ledgerReportRowMapper);
		if (newlimit == -1) {
			return ledgerReportList;
		}
		int fromIndex = Math.min(newoffset, ledgerReportList.size());
		int toIndex = Math.min(fromIndex + newlimit, ledgerReportList.size());
		return ledgerReportList.subList(fromIndex, toIndex);
//		return ledgerReportList;
	}


	public List<MonthReport> getMonthReport(Long monthStartDateTime, Long monthEndDateTime, String tenantId, Integer offset, Integer limit,String sortOrder) {
		StringBuilder tillDateConsumerQuery = new StringBuilder(wsQueryBuilder.TILL_DATE_CONSUMER);

		List<Object> consumerPreparedStatement = new ArrayList<>();
		consumerPreparedStatement.add(monthEndDateTime);
		consumerPreparedStatement.add(tenantId);

		if(sortOrder.equals(SearchCriteria.SortOrder.DESC.name()))
			tillDateConsumerQuery.append(" DESC ");
		else
			tillDateConsumerQuery.append(" ASC ");

		Integer newlimit = wsConfiguration.getDefaultLimit();
		Integer newoffset = wsConfiguration.getDefaultOffset();
		if (limit == null && offset == null)
			newlimit = wsConfiguration.getMaxLimit();
		if (limit != null && limit <= wsConfiguration.getMaxLimit())
			newlimit = limit;
		if (limit != null && limit >= wsConfiguration.getMaxLimit())
			newlimit = wsConfiguration.getMaxLimit();
		if (limit != null && limit == -1) // Handling the case when limit is -1
			newlimit = -1;

		if (offset != null)
			newoffset = offset;

		if (newlimit > 0) {
			tillDateConsumerQuery.append(" offset ?  limit ? ;");
			consumerPreparedStatement.add(newoffset);
			consumerPreparedStatement.add(newlimit);
		}

		log.info("Query to fetch consumers: " + tillDateConsumerQuery + " and prepared statement: " + consumerPreparedStatement);
		List<MonthReport> consumerList = jdbcTemplate.query(tillDateConsumerQuery.toString(), consumerPreparedStatement.toArray(),consumerRowMapper);

		List<MonthReport> reportList = new ArrayList<>();

		if (!consumerList.isEmpty()) {
			for (MonthReport monthReport : consumerList) {
				List<Object> demandPreparedStatement = new ArrayList<>();
				demandPreparedStatement.add(monthStartDateTime);
				demandPreparedStatement.add(monthEndDateTime);
				demandPreparedStatement.add(tenantId);
				demandPreparedStatement.add(monthReport.getConnectionNo());

				StringBuilder month_demand_query = new StringBuilder(wsQueryBuilder.MONTH_DEMAND_QUERY);

				try{
					MonthReport demandReport=jdbcTemplate.queryForObject(month_demand_query.toString(), demandPreparedStatement.toArray(), monthReportRowMapper);
					if (demandReport != null) {
						monthReport.setDemandGenerationDate(demandReport.getDemandGenerationDate());
						monthReport.setPenalty(demandReport.getPenalty());
						monthReport.setDemandAmount(demandReport.getDemandAmount());
						monthReport.setAdvance(demandReport.getAdvance());
					}
				}catch (EmptyResultDataAccessException e) {
					log.info("No month report found for connection: " + monthReport.getConnectionNo());
				}
				BigDecimal taxAmountResult = getMonthlyTaxAmount(monthStartDateTime, monthReport.getConnectionNo());
				if(taxAmountResult==null)
				{
					taxAmountResult=BigDecimal.ZERO;
				}
				BigDecimal totalAmountPaidResult = getMonthlyTotalAmountPaid(monthStartDateTime, monthReport.getConnectionNo());
				if(totalAmountPaidResult==null)
				{
					totalAmountPaidResult=BigDecimal.ZERO;
				}

				if (monthReport != null) {
					monthReport.setConnectionNo(monthReport.getConnectionNo());
					monthReport.setArrears(taxAmountResult.subtract(totalAmountPaidResult));
					BigDecimal totalAmount = (monthReport.getPenalty() != null ? monthReport.getPenalty() : BigDecimal.ZERO)
							.add(monthReport.getDemandAmount() != null ? monthReport.getDemandAmount() : BigDecimal.ZERO)
							.add(monthReport.getAdvance() != null ? monthReport.getAdvance() : BigDecimal.ZERO)
							.add(monthReport.getArrears()!=null ? monthReport.getArrears():BigDecimal.ZERO);
					monthReport.setTotalAmount(totalAmount);
				}

				StringBuilder month_payment_query = new StringBuilder(wsQueryBuilder.MONTH_PAYMENT_QUERY);

				List<Object> paymentPreparedStatement = new ArrayList<>();
				paymentPreparedStatement.add(tenantId);
				paymentPreparedStatement.add(monthReport.getConnectionNo());
				paymentPreparedStatement.add(monthStartDateTime);
				paymentPreparedStatement.add(monthEndDateTime);
				paymentPreparedStatement.add(tenantId);
				paymentPreparedStatement.add(tenantId);

				PaymentMonthReport paymentMonthReport = jdbcTemplate.queryForObject(month_payment_query.toString(), paymentPreparedStatement.toArray(), paymentRowMapper);

				if (monthReport != null && paymentMonthReport != null) {
					monthReport.setPaid(paymentMonthReport.getTotalAmountPaid()!= null ? paymentMonthReport.getTotalAmountPaid() : BigDecimal.ZERO);
					monthReport.setPaidDate(paymentMonthReport.getFirstTransactionDate());
					BigDecimal totalAmount = monthReport.getTotalAmount() != null ? monthReport.getTotalAmount() : BigDecimal.ZERO;
					BigDecimal totalAmountPaid = paymentMonthReport.getTotalAmountPaid() != null ? paymentMonthReport.getTotalAmountPaid() : BigDecimal.ZERO;
					monthReport.setRemainingAmount(totalAmount.subtract(totalAmountPaid));
				}
				reportList.add(monthReport);
			}
		}
		return reportList;
	}

	private BigDecimal getMonthlyTaxAmount(Long startDate, String consumerCode) {
		StringBuilder taxAmountQuery = new StringBuilder(wsQueryBuilder.TAX_AMOUNT_QUERY);
		List<Object> taxAmountParams = new ArrayList<>();
		taxAmountParams.add(consumerCode);
		taxAmountParams.add(startDate);
		BigDecimal ans = jdbcTemplate.queryForObject(taxAmountQuery.toString(), taxAmountParams.toArray(), BigDecimal.class);
		if (ans != null)
			return ans;
		return BigDecimal.ZERO;
	}

	private BigDecimal getMonthlyTotalAmountPaid(Long startDate, String consumerCode) {
		StringBuilder totalAmountPaidQuery = new StringBuilder(wsQueryBuilder.TOTAL_AMOUNT_PAID_QUERY);
		List<Object> totalAmountPaidParams = new ArrayList<>();
		totalAmountPaidParams.add(consumerCode);
		totalAmountPaidParams.add(startDate);
		BigDecimal ans = jdbcTemplate.queryForObject(totalAmountPaidQuery.toString(), totalAmountPaidParams.toArray(), BigDecimal.class);
		if (ans != null)
			return ans;
		return BigDecimal.ZERO;
	}
}
