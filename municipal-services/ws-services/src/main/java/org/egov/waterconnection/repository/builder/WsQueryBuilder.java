package org.egov.waterconnection.repository.builder;

import static org.egov.waterconnection.constants.WCConstants.SEARCH_TYPE_CONNECTION;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.egov.common.contract.request.RequestInfo;
import org.egov.tracer.model.CustomException;
import org.egov.waterconnection.config.WSConfiguration;
import org.egov.waterconnection.service.UserService;
import org.egov.waterconnection.service.WaterService;
import org.egov.waterconnection.service.WaterServiceImpl;
import org.egov.waterconnection.util.WaterServicesUtil;
import org.egov.waterconnection.web.controller.WaterController;
import org.egov.waterconnection.web.models.FeedbackSearchCriteria;
import org.egov.waterconnection.web.models.Property;
import org.egov.waterconnection.web.models.SearchCriteria;
import org.egov.waterconnection.web.models.WaterConnectionResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

@Component
public class WsQueryBuilder {

	@Autowired
	private WaterServicesUtil waterServicesUtil;

	@Autowired
	private WSConfiguration config;

	@Autowired
	private UserService userService;
	
	@Autowired
	@Lazy
	WaterServiceImpl waterServiceImpl;

	private static final String INNER_JOIN_STRING = "INNER JOIN";
	private static final String LEFT_OUTER_JOIN_STRING = " LEFT OUTER JOIN ";

	private static final String UNION_STRING=" UNION ";
//	private static final String Offset_Limit_String = "OFFSET ? LIMIT ?";

//    private static String holderSelectValues = "{HOLDERSELECTVALUES}";

	private static final String WATER_SEARCH_QUERY = "SELECT count(*) OVER() AS full_count, conn.*, wc.*, document.*, plumber.*, wc.connectionCategory, wc.connectionType, wc.waterSource,"
			+ " wc.meterId, wc.meterInstallationDate, wc.pipeSize, wc.noOfTaps, wc.proposedPipeSize, wc.proposedTaps, wc.connection_id as connection_Id, wc.connectionExecutionDate, wc.initialmeterreading, wc.appCreatedDate,"
			+ " wc.detailsprovidedby, wc.estimationfileStoreId , wc.sanctionfileStoreId , wc.estimationLetterDate,"
			+ " conn.id as conn_id, conn.tenantid, conn.applicationNo, conn.applicationStatus, conn.status, conn.connectionNo, conn.oldConnectionNo, conn.property_id, conn.roadcuttingarea,"
			+ " conn.action, conn.adhocpenalty, conn.adhocrebate, conn.adhocpenaltyreason, conn.applicationType, conn.dateEffectiveFrom,"
			+ " conn.adhocpenaltycomment, conn.adhocrebatereason, conn.adhocrebatecomment, conn.createdBy as ws_createdBy, conn.lastModifiedBy as ws_lastModifiedBy,"
			+ " conn.createdTime as ws_createdTime, conn.lastModifiedTime as ws_lastModifiedTime,conn.additionaldetails, "
			+ " conn.locality, conn.isoldapplication, conn.roadtype, document.id as doc_Id, document.documenttype, document.filestoreid, document.active as doc_active, plumber.id as plumber_id,"
			+ " plumber.name as plumber_name, plumber.licenseno, roadcuttingInfo.id as roadcutting_id, roadcuttingInfo.roadtype as roadcutting_roadtype, roadcuttingInfo.roadcuttingarea as roadcutting_roadcuttingarea, roadcuttingInfo.roadcuttingarea as roadcutting_roadcuttingarea,"
			+ " roadcuttingInfo.active as roadcutting_active, plumber.mobilenumber as plumber_mobileNumber, plumber.gender as plumber_gender, plumber.fatherorhusbandname, plumber.correspondenceaddress,"
			+ " plumber.relationship, " + "{holderSelectValues}, " + "{pendingAmountValue}," + "(select sum(dd.taxamount) as taxamount from egbs_demand_v1 d join egbs_demanddetail_v1 dd on d.id=dd.demandid group by d.consumercode,d.status having d.status ='ACTIVE' and  d.consumercode=conn.connectionno ) as taxamount, "+ "{lastDemandDate}"
			+ " FROM eg_ws_connection conn " + INNER_JOIN_STRING + " eg_ws_service wc ON wc.connection_id = conn.id"
			+ LEFT_OUTER_JOIN_STRING + "eg_ws_applicationdocument document ON document.wsid = conn.id"
			+ LEFT_OUTER_JOIN_STRING + "eg_ws_plumberinfo plumber ON plumber.wsid = conn.id" + LEFT_OUTER_JOIN_STRING
			+ "eg_ws_connectionholder connectionholder ON connectionholder.connectionid = conn.id"
			+ LEFT_OUTER_JOIN_STRING + "eg_ws_roadcuttinginfo roadcuttingInfo ON roadcuttingInfo.wsid = conn.id";

	private static final String PAGINATION_WRAPPER = "{} {orderby} {pagination}";

	private static final String ORDER_BY_CLAUSE = " ORDER BY wc.appCreatedDate DESC";

	public static final String GET_BILLING_CYCLE = "select fromperiod,toperiod from egcl_billdetial where billid=(select billid from egcl_paymentdetail where paymentid=?)";

	public static final String FEEDBACK_BASE_QUERY = "select id,tenantid,connectionno,paymentid, billingcycle,additionaldetails,createdtime,lastmodifiedtime,createdby,lastmodifiedby from eg_ws_feedback where tenantid=?";

	public static final String TotalCollectionAmount = " select sum(payd.amountpaid)  from egcl_paymentdetail payd join egcl_bill payspay ON ( payd.billid = payspay.id) where payd.businessservice='WS' ";

	public static final String CollectionAmountList = " select sum(payd.amountpaid) from egcl_paymentdetail payd join egcl_bill payspay ON ( payd.billid = payspay.id) where payd.businessservice='WS' ";

	public static final String PROPERTY_COUNT = "select additionaldetails->>'propertyType' as propertytype,count(additionaldetails->>'propertyType') from eg_ws_connection as conn";

	public static final String COLLECTION_DATA_COUNT = "SELECT (select sum(dd.taxamount) - sum(dd.collectionamount) as pendingamount from egbs_demand_v1 d join egbs_demanddetail_v1 dd on d.id = dd.demandid group by d.consumercode, d.status having d.status = 'ACTIVE' and d.consumercode = conn.connectionno ) as pendingamount FROM eg_ws_connection conn INNER JOIN eg_ws_service wc ON wc.connection_id = conn.id";

	public static final String PENDINGCOLLECTION = "SELECT SUM(DMDL.TAXAMOUNT - DMDL.COLLECTIONAMOUNT) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID WHERE DMD.BUSINESSSERVICE = 'WS' and DMD.status = 'ACTIVE' ";

	private static final String TENANTIDS = "SELECT distinct(tenantid) FROM eg_ws_connection conn";

	public static final String PREVIOUSMONTHEXPENSE = " select sum(billdtl.totalamount) from eg_echallan challan, egbs_billdetail_v1 billdtl, egbs_bill_v1 bill  where challan.challanno= billdtl.consumercode  and billdtl.billid = bill.id and challan.isbillpaid ='true'  ";

	public static final String PREVIOUSDAYCASHCOLLECTION = "select count(*), sum(p.totalamountpaid) from egcl_payment p join egcl_paymentdetail pd on p.id = pd.paymentid where p.paymentmode='CASH' and pd.businessservice = 'WS' ";

	public static final String PREVIOUSDAYONLINECOLLECTION = "select count(*), sum(p.totalamountpaid) from egcl_payment p join egcl_paymentdetail pd on p.id = pd.paymentid where p.paymentmode='ONLINE' and pd.businessservice = 'WS' ";

	public static final String NEWDEMAND = "select sum(dmdl.taxamount) FROM egbs_demand_v1 dmd INNER JOIN egbs_demanddetail_v1 dmdl ON dmd.id=dmdl.demandid AND dmd.tenantid=dmdl.tenantid WHERE dmd.businessservice='WS' and dmd.status = 'ACTIVE' and dmdl.taxheadcode<>'WS_ADVANCE_CARRYFORWARD'";

	public static final String ACTUALCOLLECTION = " select sum(py.totalAmountPaid) FROM egcl_payment py INNER JOIN egcl_paymentdetail pyd ON pyd.paymentid = py.id where pyd.businessservice='WS' ";
	
	public static final String RESIDENTIALCOLLECTION = "select sum(py.totalAmountPaid) FROM egcl_payment py INNER JOIN egcl_paymentdetail pyd ON pyd.paymentid = py.id INNER JOIN egcl_bill bill ON bill.id = pyd.billid INNER JOIN eg_ws_connection wc ON wc.connectionno = bill.consumercode  where pyd.businessservice='WS' and wc.additionaldetails->>'propertyType' IN ('RESIDENTIAL') and wc.status='Active' ";
	
	public static final String COMMERCIALCOLLECTION = "select sum(py.totalAmountPaid) FROM egcl_payment py INNER JOIN egcl_paymentdetail pyd ON pyd.paymentid = py.id INNER JOIN egcl_bill bill ON bill.id = pyd.billid INNER JOIN eg_ws_connection wc ON wc.connectionno = bill.consumercode  where pyd.businessservice='WS' and wc.additionaldetails->>'propertyType' IN ('COMMERCIAL') and wc.status='Active' ";
	
	public static final String OTHERSCOLLECTION = "select sum(py.totalAmountPaid) FROM egcl_payment py INNER JOIN egcl_paymentdetail pyd ON pyd.paymentid = py.id INNER JOIN egcl_bill bill ON bill.id = pyd.billid INNER JOIN eg_ws_connection wc ON wc.connectionno = bill.consumercode  where pyd.businessservice='WS' and wc.additionaldetails->>'propertyType' not IN ('RESIDENTIAL','COMMERCIAL') and wc.status='Active' ";
	
	public static final String TOTALAPPLICATIONSPAID = "select count(*), ({paidCount}) as paid from eg_ws_connection where status='Active' ";

	public static final String RESIDENTIALSPAID = "select count(*), ({paidCount}) as paid from eg_ws_connection where additionaldetails->>'propertyType' IN ('RESIDENTIAL') and status='Active' ";

	public static final String COMMERCIALSPAID = "select count(*), ({paidCount}) as paid from eg_ws_connection where additionaldetails->>'propertyType' IN ('COMMERCIAL') and status='Active' ";

	public static final String RESIDENTIALSPAIDCOUNT = "select count(distinct consumercode)FROM egcl_payment py INNER JOIN egcl_paymentdetail pyd ON pyd.paymentid = py.id INNER JOIN egcl_bill bill ON bill.id = pyd.billid INNER JOIN eg_ws_connection wc ON wc.connectionno = bill.consumercode  where pyd.businessservice='WS' and wc.additionaldetails->>'propertyType' IN ('RESIDENTIAL') ";
	
	public static final String COMMERCIALSPAIDCOUNT = "select count(distinct consumercode)FROM egcl_payment py INNER JOIN egcl_paymentdetail pyd ON pyd.paymentid = py.id INNER JOIN egcl_bill bill ON bill.id = pyd.billid INNER JOIN eg_ws_connection wc ON wc.connectionno = bill.consumercode  where pyd.businessservice='WS' and wc.additionaldetails->>'propertyType' IN ('COMMERCIAL') ";

	public static final String TOTALAPPLICATIONSPAIDCOUNT = "select count(distinct consumercode)FROM egcl_payment py INNER JOIN egcl_paymentdetail pyd ON pyd.paymentid = py.id INNER JOIN egcl_bill bill ON bill.id = pyd.billid INNER JOIN eg_ws_connection wc ON wc.connectionno = bill.consumercode  where pyd.businessservice='WS' ";

	public static final String PENDINGCOLLECTIONTILLDATE = "SELECT SUM(DMDL.TAXAMOUNT - DMDL.COLLECTIONAMOUNT) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID WHERE DMD.BUSINESSSERVICE = 'WS' and DMD.status = 'ACTIVE' ";

	public static final String ADVANCEADJUSTED = "SELECT SUM(DMDL.COLLECTIONAMOUNT) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID WHERE DMD.BUSINESSSERVICE = 'WS' and DMD.status = 'ACTIVE' AND DMDL.TAXHEADCODE='WS_ADVANCE_CARRYFORWARD'";

	public static final String PENDINGPENALTY = "SELECT SUM(DMDL.TAXAMOUNT - DMDL.COLLECTIONAMOUNT) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID WHERE DMD.BUSINESSSERVICE = 'WS' and DMD.status = 'ACTIVE' AND DMDL.TAXHEADCODE='WS_TIME_PENALTY'";

	public static final String ADVANCECOLLECTION = "SELECT SUM(DMDL.TAXAMOUNT) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID WHERE DMD.BUSINESSSERVICE = 'WS' and DMD.status = 'ACTIVE' AND DMDL.TAXHEADCODE='WS_ADVANCE_CARRYFORWARD'";

	public static final String PENALTYCOLLECTION = "select sum(ddl.collectionamount) FROM egcl_payment py INNER JOIN egcl_paymentdetail pyd ON py.id = pyd.paymentid INNER JOIN egbs_billdetail_v1 bdl ON pyd.billid=bdl.billid INNER JOIN egbs_demanddetail_v1 ddl on  bdl.demandid = ddl.demandid where ddl.taxheadcode='WS_TIME_PENALTY' and pyd.businessservice='WS'";

	
	public static final String ID_QUERY = "select conn.id FROM eg_ws_connection conn " + INNER_JOIN_STRING
			+ " eg_ws_service wc ON wc.connection_id = conn.id" + LEFT_OUTER_JOIN_STRING
			+ "eg_ws_applicationdocument document ON document.wsid = conn.id" + LEFT_OUTER_JOIN_STRING
			+ "eg_ws_plumberinfo plumber ON plumber.wsid = conn.id" + LEFT_OUTER_JOIN_STRING
			+ "eg_ws_connectionholder connectionholder ON connectionholder.connectionid = conn.id"
			+ LEFT_OUTER_JOIN_STRING + "eg_ws_roadcuttinginfo roadcuttingInfo ON roadcuttingInfo.wsid = conn.id";

	public static final String DEMAND_DETAILS = "select d.consumercode from egbs_demand_v1 d join egbs_demanddetail_v1 dd on d.id = dd.demandid where d.status = 'ACTIVE' ";
	
	
	public static final String BILL_REPORT_QUERY = "SELECT conn.tenantId as tenantId,conn.connectionno as connectionNo,conn.oldConnectionno as oldConnectionNo,conn.createdTime as connCreatedDate,"
			+ "  connectionholder.userid as uuid,SUM(CASE WHEN dd.taxheadcode = 'WS_TIME_PENALTY' THEN dd.taxamount ELSE 0 END) as WS_TIME_PENALTY_DemandAmount,"
			+ "  SUM(CASE WHEN dd.taxheadcode = '10101' THEN dd.taxamount ELSE 0 END) as A10101_DemandAmount,"
			+ "  SUM(CASE WHEN dd.taxheadcode = 'WS_ADVANCE_CARRYFORWARD' THEN dd.taxamount ELSE 0 END) as WS_ADVANCE_CARRYFORWARD_DemandAmount "
			+ "  FROM eg_ws_connection conn " + INNER_JOIN_STRING + " eg_ws_connectionholder connectionholder ON connectionholder.connectionid = conn.id "
			+   INNER_JOIN_STRING + " egbs_demand_v1 dem ON dem.consumercode = conn.connectionno "
			+   INNER_JOIN_STRING + "  egbs_demanddetail_v1 dd on dd.demandid = dem.id WHERE dem.taxperiodfrom >= ? AND dem.taxperiodto <= ? "
			+ "  AND conn.tenantId = ? AND conn.status='Active' AND dem.status='ACTIVE' GROUP BY conn.connectionno,conn.tenantId,conn.oldConnectionno,conn.createdTime,connectionholder.userid ORDER BY conn.connectionno ";
	
	public static final String COLLECTION_REPORT_QUERY = "SELECT c.connectionno as connectionNo,p.tenantid as tenantId,c.oldconnectionno as oldConnectionNo," +
			" p.paymentmode,ch.userid as uuid,SUM(p.totalamountpaid) AS totalAmountPaid FROM egcl_payment p " + INNER_JOIN_STRING +
			" eg_ws_connection c ON p.tenantid = c.tenantid " + INNER_JOIN_STRING + " eg_ws_connectionholder ch " +
			" ON c.id = ch.connectionid WHERE p.tenantid = ? AND p.transactiondate BETWEEN ? AND ? AND " +
			" p.id IN ( SELECT paymentid FROM egcl_paymentdetail pd WHERE pd.tenantid =? and " +
			" pd.billid IN ( SELECT bd.billid FROM egbs_billdetail_v1 bd WHERE bd.consumercode = c.connectionno " +
			" and bd.tenantid = ?)) AND p.instrumentstatus = 'APPROVED' AND p.paymentstatus NOT IN ('CANCELLED') " +
			" GROUP BY c.connectionno, p.tenantid, c.oldconnectionno, p.paymentmode, ch.userid ORDER BY c.connectionno ";

	public static final String INACTIVE_CONSUMER_QUERY= "SELECT connectionno AS connectionno,status AS status,lastmodifiedby "
			+ " AS lastmodifiedbyUuid,lastmodifiedtime AS lastmodifiedtime FROM eg_ws_connection_audit WHERE connectionno "
			+ " IN (SELECT distinct connectionno FROM eg_ws_connection_audit WHERE status='Inactive' AND lastmodifiedtime >= ? AND"
			+ " lastmodifiedtime <= ? AND tenantid=?) " + UNION_STRING + " SELECT connectionno,status,lastmodifiedby,lastmodifiedtime FROM eg_ws_connection WHERE"
			+ " connectionno IN (SELECT distinct connectionno FROM eg_ws_connection WHERE status='Inactive' AND"
			+ " lastmodifiedtime >= ? AND lastmodifiedtime <= ? AND tenantid=?) "
			+ " order by connectionno,lastmodifiedtime desc";
			
	/**
	 * 
	 * @param criteria          The WaterCriteria
	 * @param preparedStatement The Array Of Object
	 * @param requestInfo       The Request Info
	 * @return query as a string
	 */
	public String getSearchQueryString(SearchCriteria criteria, List<Object> preparedStatement,
			RequestInfo requestInfo) {
		if (criteria.isEmpty())
			return null;
		StringBuilder query = new StringBuilder(WATER_SEARCH_QUERY);

		boolean propertyIdsPresent = false;

		Set<String> propertyIds = new HashSet<>();
		String propertyIdQuery = " (conn.property_id in (";

		if (!StringUtils.isEmpty(criteria.getMobileNumber()) || !StringUtils.isEmpty(criteria.getPropertyId())) {
			List<Property> propertyList = waterServicesUtil.propertySearchOnCriteria(criteria, requestInfo);
			propertyList.forEach(property -> propertyIds.add(property.getPropertyId()));
			criteria.setPropertyIds(propertyIds);
			if (!propertyIds.isEmpty()) {
				addClauseIfRequired(preparedStatement, query);
				query.append(propertyIdQuery).append(createQuery(propertyIds)).append(" )");
				addToPreparedStatement(preparedStatement, propertyIds);
				propertyIdsPresent = true;
			} else {
				throw new CustomException("INVALID_SEARCH_USER_PROP_NOT_FOUND",
						"Could not find user or property details !");
			}
		}

		Set<String> uuids = null;
		if (!StringUtils.isEmpty(criteria.getMobileNumber()) || !StringUtils.isEmpty(criteria.getName())) {
			uuids = userService.getUUIDForUsers(criteria.getMobileNumber(), criteria.getName(), criteria.getTenantId(),
					requestInfo);
			boolean userIdsPresent = false;
			criteria.setUserIds(uuids);
			if (!CollectionUtils.isEmpty(uuids)) {
				addORClauseIfRequired(preparedStatement, query);
				if (!propertyIdsPresent)
					query.append("(");
				query.append(" connectionholder.userid in (").append(createQuery(uuids)).append(" ))");
				addToPreparedStatement(preparedStatement, uuids);
				userIdsPresent = true;
			} else if (criteria.mobileNumberOny()) {
				throw new CustomException("INVALID_SEARCH_USER_PROP_NOT_FOUND",
						"Could not find user or property details !");
			}
			if (propertyIdsPresent && !userIdsPresent) {
				query.append(")");
			}
		}

		/*
		 * to return empty result for mobilenumber empty result
		 */
		if (!StringUtils.isEmpty(criteria.getMobileNumber()) && CollectionUtils.isEmpty(criteria.getPropertyIds())
				&& CollectionUtils.isEmpty(criteria.getUserIds())
				&& StringUtils.isEmpty(criteria.getApplicationNumber()) && StringUtils.isEmpty(criteria.getPropertyId())
				&& StringUtils.isEmpty(criteria.getConnectionNumber()) && CollectionUtils.isEmpty(criteria.getIds())) {
			throw new CustomException("INVALID_SEARCH_CRITERIA", "Invalid serach criteria!");
		}

		if (!StringUtils.isEmpty(criteria.getPropertyId()) && StringUtils.isEmpty(criteria.getMobileNumber())) {
			if (propertyIdsPresent)
				query.append(")");
			else {
				addClauseIfRequired(preparedStatement, query);
				query.append(" conn.property_id = ? ");
				preparedStatement.add(criteria.getPropertyId());
			}
		}
		if(!StringUtils.isEmpty(criteria.getTextSearch()) && !StringUtils.isEmpty(criteria.getTenantId())) {
			WaterConnectionResponse response = waterServiceImpl.getWCListFuzzySearch(criteria, requestInfo);

			if(!CollectionUtils.isEmpty(response.getWaterConnectionData())) {
				Set<String> connectionNoSet = response.getWaterConnectionData().stream().map(data -> (String)data.get("connectionNo")).collect(Collectors.toSet());			
				criteria.setConnectionNoSet(connectionNoSet);
			}
		}

		query = applyFilters(query, preparedStatement, criteria);

//		query.append(ORDER_BY_CLAUSE);
		return addPaginationWrapper(query.toString(), preparedStatement, criteria);
	}

	public StringBuilder applyFilters(StringBuilder query, List<Object> preparedStatement, SearchCriteria criteria) {
		if (!StringUtils.isEmpty(criteria.getTenantId())) {
			addClauseIfRequired(preparedStatement, query);
			if (criteria.getTenantId().equalsIgnoreCase(config.getStateLevelTenantId())) {
				query.append(" conn.tenantid LIKE ? ");
				preparedStatement.add('%' + criteria.getTenantId() + '%');
			} else {
				query.append(" conn.tenantid = ? ");
				preparedStatement.add(criteria.getTenantId());
			}
		}

		if (!CollectionUtils.isEmpty(criteria.getIds())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.id in (").append(createQuery(criteria.getIds())).append(" )");
			addToPreparedStatement(preparedStatement, criteria.getIds());
		}
		if (!StringUtils.isEmpty(criteria.getOldConnectionNumber())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.oldconnectionno = ? ");
			preparedStatement.add(criteria.getOldConnectionNumber());
		}

		if (!StringUtils.isEmpty(criteria.getImisNumber())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.imisnumber = ? ");
			preparedStatement.add(criteria.getImisNumber());
		}

		if (!StringUtils.isEmpty(criteria.getConnectionNumber()) || !StringUtils.isEmpty(criteria.getTextSearch())) {
			addClauseIfRequired(preparedStatement, query);
			
			if(!StringUtils.isEmpty(criteria.getConnectionNumber())) {
				query.append(" conn.connectionno ~*  ? ");
				preparedStatement.add(criteria.getConnectionNumber());
			}
			else {
				query.append(" conn.connectionno ~*  ? ");
				preparedStatement.add(criteria.getTextSearch());
			}
			

			if(!CollectionUtils.isEmpty(criteria.getConnectionNoSet())) {
				query.append(" or conn.connectionno in (").append(createQuery(criteria.getConnectionNoSet())).append(" )");
				addToPreparedStatement(preparedStatement, criteria.getConnectionNoSet());
			}
		}

		if (!StringUtils.isEmpty(criteria.getStatus())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.status = ? ");
			preparedStatement.add(criteria.getStatus());
		}
		if (!StringUtils.isEmpty(criteria.getApplicationNumber())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.applicationno = ? ");
			preparedStatement.add(criteria.getApplicationNumber());
		}
		if (!StringUtils.isEmpty(criteria.getApplicationStatus())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.applicationStatus = ? ");
			preparedStatement.add(criteria.getApplicationStatus());
		}
		if (!StringUtils.isEmpty(criteria.getApplicationType())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.applicationType = ? ");
			preparedStatement.add(criteria.getApplicationType());
		}
		if (!StringUtils.isEmpty(criteria.getPropertyType())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.additionaldetails->>'propertyType' = ? ");
			preparedStatement.add(criteria.getPropertyType());
		}
		if (!StringUtils.isEmpty(criteria.getSearchType())
				&& criteria.getSearchType().equalsIgnoreCase(SEARCH_TYPE_CONNECTION)) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.isoldapplication = ? ");
			preparedStatement.add(Boolean.FALSE);
		}
		if (!StringUtils.isEmpty(criteria.getLocality())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.locality = ? ");
			preparedStatement.add(criteria.getLocality());
		}
		if(criteria.getIsCollectionCount() != null && criteria.getIsCollectionDataCount() != null) {
			if((criteria.getIsCollectionCount() && criteria.getIsBillPaid() != null) && criteria.getIsCollectionDataCount() == false) {
				StringBuilder paidOrPendingQuery = new StringBuilder("with td as (");
				paidOrPendingQuery.append(query).append("{orderby}").append(") ").append("select count(*) OVER() AS full_count, * from td where ");
			
				if(criteria.getIsBillPaid()) {
					paidOrPendingQuery.append(" pendingamount <= ? ").append(" or pendingamount is null");
					preparedStatement.add(0);
				}else {
					paidOrPendingQuery.append(" pendingamount > ? ");
					preparedStatement.add(0);
				}
				query = paidOrPendingQuery.append("{pagination}");
			}
		}

		return query;
	}

	public StringBuilder applyFiltersForFuzzySearch(StringBuilder query, List<Object> preparedStatement,
			SearchCriteria criteria) {
		if (!StringUtils.isEmpty(criteria.getTenantId())) {
			addClauseIfRequired(preparedStatement, query);
			if (criteria.getTenantId().equalsIgnoreCase(config.getStateLevelTenantId())) {
				query.append(" conn.tenantid LIKE ? ");
				preparedStatement.add('%' + criteria.getTenantId() + '%');
			} else {
				query.append(" conn.tenantid = ? ");
				preparedStatement.add(criteria.getTenantId());
			}
		}

		if (!CollectionUtils.isEmpty(criteria.getIds())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.id in (").append(createQuery(criteria.getIds())).append(" )");
			addToPreparedStatement(preparedStatement, criteria.getIds());
		}
		if (!StringUtils.isEmpty(criteria.getStatus())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.status = ? ");
			preparedStatement.add(criteria.getStatus());
		}
		if (!StringUtils.isEmpty(criteria.getApplicationNumber())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.applicationno = ? ");
			preparedStatement.add(criteria.getApplicationNumber());
		}
		if (!StringUtils.isEmpty(criteria.getApplicationStatus())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.applicationStatus = ? ");
			preparedStatement.add(criteria.getApplicationStatus());
		}
		if (criteria.getFromDate() != null) {
			addClauseIfRequired(preparedStatement, query);
			query.append("  conn.createdTime >= ? ");
			preparedStatement.add(criteria.getFromDate());
		}
		if (criteria.getToDate() != null) {
			addClauseIfRequired(preparedStatement, query);
			query.append("  conn.createdTime <= ? ");
			preparedStatement.add(criteria.getToDate());
		}
		if (!StringUtils.isEmpty(criteria.getApplicationType())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.applicationType = ? ");
			preparedStatement.add(criteria.getApplicationType());
		}
		if (!StringUtils.isEmpty(criteria.getPropertyType())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.additionaldetails->>'propertyType' = ? ");
			preparedStatement.add(criteria.getPropertyType());
		}
		if (!StringUtils.isEmpty(criteria.getSearchType())
				&& criteria.getSearchType().equalsIgnoreCase(SEARCH_TYPE_CONNECTION)) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.isoldapplication = ? ");
			preparedStatement.add(Boolean.FALSE);
		}
		if (!StringUtils.isEmpty(criteria.getLocality())) {
			addClauseIfRequired(preparedStatement, query);
			query.append(" conn.locality = ? ");
			preparedStatement.add(criteria.getLocality());
		}
		return query;
	}

	private void addClauseIfRequired(List<Object> values, StringBuilder queryString) {
		if (values.isEmpty())
			queryString.append(" WHERE ");
		else {
			queryString.append(" AND");
		}
	}

	private String createQuery(Set<String> ids) {
		StringBuilder builder = new StringBuilder();
		int length = ids.size();
		for (int i = 0; i < length; i++) {
			builder.append(" ?");
			if (i != length - 1)
				builder.append(",");
		}
		return builder.toString();
	}

	private void addToPreparedStatement(List<Object> preparedStatement, Set<String> ids) {
		preparedStatement.addAll(ids);
	}

	/**
	 * 
	 * @param query            Query String
	 * @param preparedStmtList Array of object for preparedStatement list
	 * @param criteria         SearchCriteria
	 * @return It's returns query
	 */
	private String addPaginationWrapper(String query, List<Object> preparedStmtList, SearchCriteria criteria) {
		String string = addOrderByClause(criteria);
		Integer limit = config.getDefaultLimit();
		Integer offset = config.getDefaultOffset();
		String finalQuery = null;

		if(criteria.getIsBillPaid() != null && (criteria.getIsCollectionCount() != null && criteria.getIsCollectionCount())) {
			finalQuery = query;
		} else {
			finalQuery = PAGINATION_WRAPPER.replace("{}", query);
		}
		finalQuery = finalQuery.replace("{orderby}", string);
		
		finalQuery = finalQuery.replace("{holderSelectValues}",
				"(select nullif(sum(payd.amountpaid),0) from egcl_paymentdetail payd join egcl_bill payspay on (payd.billid = payspay.id) where payd.businessservice = 'WS' and payspay.consumercode = conn.connectionno" +" {fromToDateHolder} "+ "group by payspay.consumercode) as collectionamount, connectionholder.tenantid as holdertenantid, connectionholder.connectionid as holderapplicationId, userid, connectionholder.status as holderstatus, isprimaryholder, connectionholdertype, holdershippercentage, connectionholder.relationship as holderrelationship, connectionholder.createdby as holdercreatedby, connectionholder.createdtime as holdercreatedtime, connectionholder.lastmodifiedby as holderlastmodifiedby, connectionholder.lastmodifiedtime as holderlastmodifiedtime");
		
		if((criteria.getIsCollectionCount() != null && criteria.getIsCollectionCount())) {
			finalQuery = finalQuery.replace("{fromToDateHolder}", " ");
		}else {
			if(criteria.getFromDate() != null && criteria.getToDate() != null) {
				finalQuery = finalQuery.replace("{fromToDateHolder}", " and payd.receiptdate between "+criteria.getFromDate()+" AND "+criteria.getToDate()+" ");
			}else {
				finalQuery = finalQuery.replace("{fromToDateHolder}", " ");
			}
		}
		finalQuery = finalQuery.replace("{pendingAmountValue}",
				"(select sum(dd.taxamount) - sum(dd.collectionamount) as pendingamount from egbs_demand_v1 d join egbs_demanddetail_v1 dd on d.id = dd.demandid group by d.consumercode, d.status having d.status = 'ACTIVE' and d.consumercode = conn.connectionno ) as pendingamount");

//		finalQuery=finalQuery.replace("{taxamount}",
//				"(select sum(dd.taxamount) as taxamount from egbs_demand_v1 d join egbs_demanddetail_v1 dd on d.id=dd.demandid group by d.consumercode,d.status having d.status ='ACTIVE' and  d.consumercode=conn.connectionno ) as taxamount");

		finalQuery = finalQuery.replace("{lastDemandDate}",
				"(select d.taxperiodto as taxperiodto from egbs_demand_v1 d where d.consumercode = conn.connectionno order by d.createdtime desc limit 1) as taxperiodto");
		if (criteria.getLimit() == null && criteria.getOffset() == null)
			limit = config.getMaxLimit();

		if (criteria.getLimit() != null && criteria.getLimit() <= config.getMaxLimit())
			limit = criteria.getLimit();

		if (criteria.getLimit() != null && criteria.getLimit() > config.getMaxLimit()) {
			limit = config.getMaxLimit();
		}

		if (criteria.getOffset() != null)
			offset = criteria.getOffset();

		if (limit == -1) {
			finalQuery = finalQuery.replace("{pagination}", "");
		} else {
			finalQuery = finalQuery.replace("{pagination}", " offset ?  limit ?  ");
			preparedStmtList.add(offset);
			preparedStmtList.add(limit);
		}
		System.out.println("Final Query ::" + finalQuery);
		return finalQuery;
	}

	private String addOrderByClause(SearchCriteria criteria) {
		StringBuilder builder = new StringBuilder();

		if (StringUtils.isEmpty(criteria.getSortBy()))
			builder.append(" ORDER BY wc.appCreatedDate ");

		else if (criteria.getSortBy() == SearchCriteria.SortBy.connectionNumber)
			builder.append(" ORDER BY connectionno ");

		else if (criteria.getSortBy() == SearchCriteria.SortBy.name)
			builder.append(" ORDER BY name ");

		else if (criteria.getSortBy() == SearchCriteria.SortBy.collectionAmount)
			builder.append(" ORDER BY collectionamount ");

		else if (criteria.getSortBy() == SearchCriteria.SortBy.collectionPendingAmount)
			builder.append(" ORDER BY pendingamount ");
		
		else if (criteria.getSortBy() == SearchCriteria.SortBy.lastDemandGeneratedDate)
			builder.append(" ORDER BY taxperiodto ");

		if (criteria.getSortOrder() == SearchCriteria.SortOrder.ASC)
			builder.append(" ASC ");
		else
			builder.append(" DESC ");
		
		builder.append(" , ").append("conn.id");
		
		if (criteria.getSortOrder() == SearchCriteria.SortOrder.ASC)
			builder.append(" ASC ");
		else
			builder.append(" DESC ");

		if (criteria.getSortBy() == SearchCriteria.SortBy.collectionAmount
				|| criteria.getSortBy() == SearchCriteria.SortBy.collectionPendingAmount)
			builder.append(" NULLS LAST ");

		return builder.toString();
	}

	private void addORClauseIfRequired(List<Object> values, StringBuilder queryString) {
		if (values.isEmpty())
			queryString.append(" WHERE ");
		else {
			queryString.append(" OR");
		}
	}

	public String getFeedback(FeedbackSearchCriteria feedBackSearchCriteira, List<Object> preparedStatementValues) {

		StringBuilder query = new StringBuilder(FEEDBACK_BASE_QUERY);
		preparedStatementValues.add(feedBackSearchCriteira.getTenantId());

		if (feedBackSearchCriteira.getId() != null) {
			addClauseIfRequired(preparedStatementValues, query);
			query.append(" id = ? ");
			preparedStatementValues.add(feedBackSearchCriteira.getId());
		}

		if (feedBackSearchCriteira.getBillingCycle() != null) {

			addClauseIfRequired(preparedStatementValues, query);
			query.append(" billingcycle = ? ");
			preparedStatementValues.add(feedBackSearchCriteira.getBillingCycle());
		}

		if (feedBackSearchCriteira.getPaymentId() != null) {

			addClauseIfRequired(preparedStatementValues, query);
			query.append(" paymentid = ? ");
			preparedStatementValues.add(feedBackSearchCriteira.getPaymentId());
		}

		if (feedBackSearchCriteira.getConnectionNo() != null) {

			addClauseIfRequired(preparedStatementValues, query);
			query.append(" connectionno = ? ");
			preparedStatementValues.add(feedBackSearchCriteira.getConnectionNo());
		}

		if (feedBackSearchCriteira.getFromDate() != null) {
			addClauseIfRequired(preparedStatementValues, query);
			query.append(" createdTime >= ? ");
			preparedStatementValues.add(feedBackSearchCriteira.getFromDate());
		}
		if (feedBackSearchCriteira.getToDate() != null) {
			addClauseIfRequired(preparedStatementValues, query);
			query.append(" createdTime <= ? ");
			preparedStatementValues.add(feedBackSearchCriteira.getToDate());
		}

		if (feedBackSearchCriteira.getOffset() != null) {

			query.append(" offset ? ");
			preparedStatementValues.add(feedBackSearchCriteira.getOffset());

		}

		if (feedBackSearchCriteira.getLimit() != null) {

			query.append(" limit ? ");

			preparedStatementValues.add(feedBackSearchCriteira.getLimit());

		}

		return query.toString();

	}

	public String getDistinctTenantIds() {
		return TENANTIDS;
	}

	public String getIds(SearchCriteria criteria, List<Object> preparedStatementList) {

		if (criteria.isEmpty())
			throw new CustomException("EG_WC_SEARCH_CRITERIA_EMPTY_ERROR", "criteria should not be null");

		StringBuilder query = new StringBuilder(ID_QUERY);

		query = applyFiltersForFuzzySearch(query, preparedStatementList, criteria);

		return query.toString();
	}
	
	public String getSearchQueryStringForPlaneSearch(SearchCriteria criteria, List<Object> preparedStatement,
			RequestInfo requestInfo) {
		if (criteria.isEmpty())
			return null;
		StringBuilder query = new StringBuilder(WATER_SEARCH_QUERY);
		query = applyFiltersForPlaneSearch(query, preparedStatement, criteria);
		return addPaginationWrapperForPlaneSearch(query.toString(), preparedStatement, criteria);
	}
	
	public StringBuilder applyFiltersForPlaneSearch(StringBuilder query, List<Object> preparedStatement, SearchCriteria criteria) {
		if (!StringUtils.isEmpty(criteria.getTenantId())) {
			addClauseIfRequired(preparedStatement, query);
			if (criteria.getTenantId().equalsIgnoreCase(config.getStateLevelTenantId())) {
				query.append(" conn.tenantid LIKE ? ");
				preparedStatement.add('%' + criteria.getTenantId() + '%');
			} else {
				query.append(" conn.tenantid = ? ");
				preparedStatement.add(criteria.getTenantId());
			}
		}
		return query;
	}
	
	private String addPaginationWrapperForPlaneSearch(String query, List<Object> preparedStmtList, SearchCriteria criteria) {
		String string = addOrderByClauseForPlaneSearch(criteria);
		Integer limit = config.getDefaultLimit();
		Integer offset = config.getDefaultOffset();
		String finalQuery = null;
		
		finalQuery = PAGINATION_WRAPPER.replace("{}", query);
		
		finalQuery = finalQuery.replace("{orderby}", string);
		
		finalQuery = finalQuery.replace("{holderSelectValues}",
				"(select nullif(sum(payd.amountpaid),0) from egcl_paymentdetail payd join egcl_bill payspay on (payd.billid = payspay.id) where payd.businessservice = 'WS' and payspay.consumercode = conn.connectionno group by payspay.consumercode) as collectionamount, connectionholder.tenantid as holdertenantid, connectionholder.connectionid as holderapplicationId, userid, connectionholder.status as holderstatus, isprimaryholder, connectionholdertype, holdershippercentage, connectionholder.relationship as holderrelationship, connectionholder.createdby as holdercreatedby, connectionholder.createdtime as holdercreatedtime, connectionholder.lastmodifiedby as holderlastmodifiedby, connectionholder.lastmodifiedtime as holderlastmodifiedtime");
		
		finalQuery = finalQuery.replace("{pendingAmountValue}",
				"(select sum(dd.taxamount) - sum(dd.collectionamount) as pendingamount from egbs_demand_v1 d join egbs_demanddetail_v1 dd on d.id = dd.demandid group by d.consumercode, d.status having d.status = 'ACTIVE' and d.consumercode = conn.connectionno ) as pendingamount");
		
		finalQuery = finalQuery.replace("{lastDemandDate}",
				"(select d.taxperiodto as taxperiodto from egbs_demand_v1 d where d.consumercode = conn.connectionno order by d.createdtime desc limit 1) as taxperiodto");
		
		if (criteria.getLimit() == null && criteria.getOffset() == null)
			limit = config.getMaxLimit();

		if (criteria.getLimit() != null && criteria.getLimit() <= config.getMaxLimit())
			limit = criteria.getLimit();

		if (criteria.getLimit() != null && criteria.getLimit() > config.getMaxLimit()) {
			limit = config.getMaxLimit();
		}

		if (criteria.getOffset() != null)
			offset = criteria.getOffset();

		if (limit == -1) {
			finalQuery = finalQuery.replace("{pagination}", "");
		} else {
			finalQuery = finalQuery.replace("{pagination}", " offset ?  limit ?  ");
			preparedStmtList.add(offset);
			preparedStmtList.add(limit);
		}
		System.out.println("Final Query ::" + finalQuery);
		return finalQuery;
	}
	
	private String addOrderByClauseForPlaneSearch(SearchCriteria criteria) {
		StringBuilder builder = new StringBuilder();
		builder.append(" ORDER BY wc.appCreatedDate ");
		if (criteria.getSortOrder() == SearchCriteria.SortOrder.ASC)
			builder.append(" ASC ");
		else
			builder.append(" DESC ");

		return builder.toString();
	}

}
