package org.egov.echallan.repository.builder;

import java.util.Arrays;
import java.util.List;

import org.egov.echallan.config.ChallanConfiguration;
import org.egov.echallan.model.SearchCriteria;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class ChallanQueryBuilder {

    private ChallanConfiguration config;

    @Autowired
    public ChallanQueryBuilder(ChallanConfiguration config) {
        this.config = config;
    }

    private static final String INNER_JOIN_STRING = " INNER JOIN ";

   /* private static final String QUERY = "SELECT challan.*,chaladdr.*,challan.id as challan_id,challan.tenantid as challan_tenantId,challan.lastModifiedTime as " +
            "challan_lastModifiedTime,challan.createdBy as challan_createdBy,challan.lastModifiedBy as challan_lastModifiedBy,challan.createdTime as " +
            "challan_createdTime,chaladdr.id as chaladdr_id," +
            "challan.accountId as uuid,challan.description as description,challan.typeOfExpense as typeOfExpense, challan.billDate as billDate,  "
            + " challan.billIssuedDate as billIssuedDate, challan.paidDate as paidDate, challan.isBillPaid as isBillPaid , challan.vendor as vendor FROM eg_echallan challan"
            +" LEFT OUTER JOIN "
            +" eg_challan_address chaladdr ON chaladdr.echallanid = challan.id  ";*/
    
	private static final String QUERY = "SELECT count(*) OVER() AS full_count, challan.*,chaladdr.*,challan.id as challan_id,challan.tenantid as challan_tenantId,challan.lastModifiedTime as "
			+ "challan_lastModifiedTime,challan.createdBy as challan_createdBy,challan.lastModifiedBy as challan_lastModifiedBy,challan.createdTime as "
			+ "challan_createdTime,chaladdr.id as chaladdr_id,"
			+ "challan.accountId as uuid,challan.description as description,challan.typeOfExpense as typeOfExpense, challan.billDate as billDate,  "
			+ " challan.billIssuedDate as billIssuedDate, challan.paidDate as paidDate, challan.isBillPaid as isBillPaid , challan.vendor as vendor, vendor.name as vendorName "
			+ " FROM eg_echallan challan" + " LEFT OUTER JOIN "
			+ " eg_challan_address chaladdr ON chaladdr.echallanid = challan.id   INNER JOIN eg_vendor vendor on vendor.id = challan.vendor ";

      private final String paginationWrapper = "{} {orderby} {pagination}";

      public static final String FILESTOREID_UPDATE_SQL = "UPDATE eg_echallan SET filestoreid=? WHERE id=?";
      
      public static final String CANCEL_RECEIPT_UPDATE_SQL = "UPDATE eg_echallan SET applicationStatus='ACTIVE' WHERE referenceId=? and businessService=?";
      
      private static final String TENANTIDS = "SELECT distinct(tenantid) FROM eg_echallan challan";
      
      public static final String ACTIVEEXPENSECOUNTQUERY =  "select count(*) from eg_echallan  where applicationstatus ='ACTIVE' ";

	  public static final String PREVIOUSMONTHEXPENSE = " select coalesce(sum(billdtl.totalamount),0) from eg_echallan challan, egbs_billdetail_v1 billdtl, egbs_bill_v1 bill  where challan.referenceId= billdtl.consumercode  and billdtl.billid = bill.id and challan.isbillpaid ='true'  ";
	  
	  public static final String PREVIOUSMONTHEXPPAYMENT = "SELECT coalesce(SUM(PAYMT.TOTALAMOUNTPAID),0) FROM EGCL_PAYMENT PAYMT JOIN EGCL_PAYMENTDETAIL PAYMTDTL ON (PAYMTDTL.PAYMENTID = PAYMT.ID) WHERE PAYMTDTL.BUSINESSSERVICE like '%EXPENSE%' ";

	  public static final String PREVIOUSDAYCASHCOLLECTION = "select  count(*), sum(totalamountpaid) from egcl_payment where paymentmode='CASH' ";
	  
	  public static final String PREVIOUSDAYONLINECOLLECTION = "select  count(*), sum(totalamountpaid) from egcl_payment where paymentmode='ONLINE' ";

	  public static final String PREVIOUSMONTHNEWEXPENSE = " SELECT coalesce(SUM(DEMANDDTL.TAXAMOUNT),0) FROM EGBS_DEMANDDETAIL_V1 DEMANDDTL JOIN EGBS_DEMAND_V1 DEMAND ON(DEMANDDTL.DEMANDID = DEMAND.ID) JOIN EG_ECHALLAN CHALLAN ON(CHALLAN.referenceId = DEMAND.CONSUMERCODE  AND DEMAND.TENANTID=CHALLAN.TENANTID ) where DEMAND.status = 'ACTIVE' ";
	  
	  public static final String CUMULATIVEPENDINGEXPENSE = " SELECT coalesce(SUM(DEMANDDTL.TAXAMOUNT - DEMANDDTL.COLLECTIONAMOUNT),0) FROM EGBS_DEMANDDETAIL_V1 DEMANDDTL JOIN EGBS_DEMAND_V1 DEMAND ON(DEMANDDTL.DEMANDID = DEMAND.ID) JOIN EG_ECHALLAN CHALLAN ON(DEMAND.CONSUMERCODE = CHALLAN.referenceId AND DEMAND.TENANTID=CHALLAN.TENANTID) WHERE DEMANDDTL.COLLECTIONAMOUNT <= 0 and DEMAND.status = 'ACTIVE' ";

	  public static final String bill_count = " select count(*) from eg_echallan as challan INNER JOIN eg_vendor vendor on vendor.id = challan.vendor ";

	  public static final String NEWEXPDEMAND = "SELECT coalesce(SUM(DMDL.TAXAMOUNT),0) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID  INNER JOIN EG_ECHALLAN CH ON CH.referenceId=DMD.CONSUMERCODE AND DMD.TENANTID=CH.TENANTID WHERE DMD.BUSINESSSERVICE LIKE '%EXPENSE%' and DMD.status = 'ACTIVE' ";
	
	  public static final String PENDINGEXPCOLL = "SELECT coalesce(SUM(DMDL.TAXAMOUNT - DMDL.COLLECTIONAMOUNT),0) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID  INNER JOIN EG_ECHALLAN CH ON CH.referenceId=DMD.CONSUMERCODE AND DMD.TENANTID=CH.TENANTID WHERE DMD.BUSINESSSERVICE LIKE '%EXPENSE%' and DMD.status='ACTIVE' ";
	
	  public static final String ACTUALEXPCOLLECTION = " SELECT coalesce(SUM(PY.TOTALAMOUNTPAID),0) FROM EGCL_PAYMENT PY INNER JOIN EGCL_PAYMENTDETAIL PYD ON PYD.PAYMENTID = PY.ID WHERE PYD.BUSINESSSERVICE LIKE '%EXPENSE%' and py.paymentstatus not in ('CANCELLED') ";

	  public static final String TOTALBILLS = " select count(*) from eg_echallan where applicationstatus not in ('CANCELLED') ";

	  public static final String PAIDBILLS = " select count(*) from eg_echallan where isbillpaid = 'true' and applicationstatus not in ('CANCELLED') ";
	  
	  public static final String PENDINGBILLS = " select count(*) from eg_echallan where isbillpaid = 'false' and applicationstatus not in ('CANCELLED') ";
 
	  public static final String ELECTRICITYBILLS = "SELECT COALESCE(SUM(DMDL.TAXAMOUNT),0) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID  INNER JOIN EG_ECHALLAN CHALLAN ON CHALLAN.referenceId=DMD.CONSUMERCODE AND DMD.TENANTID=CHALLAN.TENANTID WHERE DMD.BUSINESSSERVICE IN ('EXPENSE.ELECTRICITY_BILL') AND DMD.STATUS = 'ACTIVE' AND CHALLAN.APPLICATIONSTATUS NOT IN ('CANCELLED') ";

	  public static final String OMMISCBILLS = "SELECT COALESCE(SUM(DMDL.TAXAMOUNT),0) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID  INNER JOIN EG_ECHALLAN CHALLAN ON CHALLAN.referenceId=DMD.CONSUMERCODE AND DMD.TENANTID=CHALLAN.TENANTID WHERE DMD.BUSINESSSERVICE NOT IN ('EXPENSE.ELECTRICITY_BILL' , 'EXPENSE.SALARY') AND DMD.STATUS = 'ACTIVE' AND CHALLAN.APPLICATIONSTATUS NOT IN ('CANCELLED') ";
	  
	  public static final String SALARYBILLS = "SELECT COALESCE(SUM(DMDL.TAXAMOUNT),0) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID  INNER JOIN EG_ECHALLAN CHALLAN ON CHALLAN.referenceId=DMD.CONSUMERCODE AND DMD.TENANTID=CHALLAN.TENANTID WHERE DMD.BUSINESSSERVICE IN ('EXPENSE.SALARY') AND DMD.STATUS = 'ACTIVE' AND CHALLAN.APPLICATIONSTATUS NOT IN ('CANCELLED') ";

	  public static final String PENDINGEXPCOLLTILLDATE = "SELECT coalesce(SUM(DMDL.TAXAMOUNT - DMDL.COLLECTIONAMOUNT),0) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID INNER JOIN EG_ECHALLAN CH ON CH.referenceId=DMD.CONSUMERCODE AND DMD.TENANTID=CH.TENANTID WHERE DMD.BUSINESSSERVICE LIKE '%EXPENSE%' and DMD.status='ACTIVE' ";


		public String getChallanSearchQuery(SearchCriteria criteria, List<Object> preparedStmtList) {

			StringBuilder builder = new StringBuilder(QUERY);

			addBusinessServiceClause(criteria, preparedStmtList, builder);

			if (criteria.getAccountId() != null) {
				addClauseIfRequired(preparedStmtList, builder);
				builder.append(" challan.accountid = ? ");
				preparedStmtList.add(criteria.getAccountId());

				List<String> ownerIds = criteria.getUserIds();
				if (!CollectionUtils.isEmpty(ownerIds)) {
					builder.append(" OR (challan.accountid IN (").append(createQuery(ownerIds)).append(")");
					addToPreparedStatement(preparedStmtList, ownerIds);
					addBusinessServiceClause(criteria, preparedStmtList, builder);
				}
			} else {

				builder = applyFilters(builder, preparedStmtList, criteria);

			}

			return addPaginationWrapper(builder.toString(), preparedStmtList, criteria);
		}


		public StringBuilder applyFilters(StringBuilder builder, List<Object> preparedStmtList,
				SearchCriteria criteria) {

			if (criteria.getTenantId() != null) {
				addClauseIfRequired(preparedStmtList, builder);
				builder.append(" challan.tenantid=? ");
				preparedStmtList.add(criteria.getTenantId());
			}
//			Adding reference id for collection service create payment criteria.

			if (criteria.getReferenceId() != null) {
				addClauseIfRequired(preparedStmtList, builder);
				builder.append(" challan.referenceid=? ");
				preparedStmtList.add(criteria.getReferenceId());
			}

			List<String> ids = criteria.getIds();
			if (!CollectionUtils.isEmpty(ids)) {
				addClauseIfRequired(preparedStmtList, builder);
				builder.append(" challan.id IN (").append(createQuery(ids)).append(")");
				addToPreparedStatement(preparedStmtList, ids);
			}

			List<String> ownerIds = criteria.getUserIds();
			if (!CollectionUtils.isEmpty(ownerIds)) {
				addClauseIfRequired(preparedStmtList, builder);
				builder.append(" challan.accountid IN (").append(createQuery(ownerIds)).append(")");
				addToPreparedStatement(preparedStmtList, ownerIds);
				// addClauseIfRequired(preparedStmtList, builder);
			}

			if (criteria.getFreeSearch()) {
				if (criteria.getChallanNo() != null || criteria.getVendorName() != null) {
					addClauseIfRequired(preparedStmtList, builder);
					builder.append(" (challan.challanno ~*  ?");
					preparedStmtList.add(criteria.getChallanNo());

					builder.append(" OR vendor.name ~*  ?)");
					preparedStmtList.add(criteria.getVendorName());
				}
			} else {
				if (criteria.getChallanNo() != null) {
					addClauseIfRequired(preparedStmtList, builder);
					builder.append("  challan.challanno ~*  ?");
					preparedStmtList.add(criteria.getChallanNo());
				}
				if (criteria.getVendorName() != null) {
					addClauseIfRequired(preparedStmtList, builder);
					builder.append(" vendor.name ~* ?");
					preparedStmtList.add(criteria.getVendorName());
				}
			}
			if (criteria.getStatus() != null) {
				addClauseIfRequired(preparedStmtList, builder);
				builder.append(" challan.applicationstatus IN (").append(createQuery(criteria.getStatus())).append(")");
				addToPreparedStatement(preparedStmtList, criteria.getStatus());
			}

			if (criteria.getExpenseType() != null) {
				addClauseIfRequired(preparedStmtList, builder);
				builder.append(" challan.typeOfExpense = ? ");
				preparedStmtList.add(criteria.getExpenseType());
			}

			if (criteria.getFromDate() != null && criteria.getToDate() != null) {
				addClauseIfRequired(preparedStmtList, builder);
				builder.append(
						" challan.billdate between " + criteria.getFromDate() + " and " + criteria.getToDate());
			}
			if (criteria.getIsBillPaid() != null) {
				addClauseIfRequired(preparedStmtList, builder);
				builder.append("  challan.isBillPaid = ? ");
				preparedStmtList.add(criteria.getIsBillPaid());
			}

			return builder;
		}


	private void addBusinessServiceClause(SearchCriteria criteria, List<Object> preparedStmtList,
			StringBuilder builder) {
		if (criteria.getBusinessService() != null) {
			List<String> businessServices = Arrays.asList(criteria.getBusinessService().split(","));
			addClauseIfRequired(preparedStmtList, builder);
			builder.append(" challan.businessservice IN (").append(createQuery(businessServices)).append(")");
			addToPreparedStatement(preparedStmtList, businessServices);
		}
	}

    private String createQuery(List<String> ids) {
        StringBuilder builder = new StringBuilder();
        int length = ids.size();
        for( int i = 0; i< length; i++){
            builder.append(" ?");
            if(i != length -1) builder.append(",");
        }
        return builder.toString();
    }

    private void addToPreparedStatement(List<Object> preparedStmtList,List<String> ids)
    {
        ids.forEach(id ->{ preparedStmtList.add(id);});
    }


    private String addPaginationWrapper(String query,List<Object> preparedStmtList,
                                      SearchCriteria criteria){
       String string = addOrderByClause(criteria);

        int limit = config.getDefaultLimit();
        int offset = config.getDefaultOffset();
        String finalQuery = paginationWrapper.replace("{}",query);

		finalQuery = finalQuery.replace("{orderby}", string);

//		finalQuery = finalQuery.replace("{amount}", " (select nullif(sum(bi.totalamount),0) from egbs_billdetail_v1 bi join egbs_bill_v1 b on bi.billid=b.id where bi.businessservice = challan.businessservice and bi.tenantid=challan.tenantid and bi.consumercode = challan.referenceId and b.status IN ('ACTIVE','PAID' ) group by bi.consumercode) as totalamount, ");
		
        if(criteria.getLimit()!=null && criteria.getLimit()<=config.getMaxSearchLimit())
            limit = criteria.getLimit();

        if(criteria.getLimit()!=null && criteria.getLimit()>config.getMaxSearchLimit())
            limit = config.getMaxSearchLimit();

        if(criteria.getOffset()!=null)
            offset = criteria.getOffset();
        
        finalQuery = finalQuery.replace("{pagination}", " offset ?  limit ?  ");
	    preparedStmtList.add(offset);
        preparedStmtList.add(limit);

       return finalQuery;
    }


    private static void addClauseIfRequired(List<Object> values, StringBuilder queryString) {
        if (values.isEmpty())
            queryString.append(" WHERE ");
        else {
            queryString.append(" AND");
        }
    }

	public String getDistinctTenantIds() {
		return TENANTIDS;
	}

	/**
	 * 
	 * @param builder
	 * @param criteria
	 */
	private String addOrderByClause(SearchCriteria criteria) {

        StringBuilder builder = new StringBuilder();
        
		if (StringUtils.isEmpty(criteria.getSortBy()))
			builder.append(" ORDER BY challan_lastModifiedTime ");

		else if (criteria.getSortBy() == SearchCriteria.SortBy.billDate)
			builder.append(" ORDER BY billDate ");

		else if (criteria.getSortBy() == SearchCriteria.SortBy.typeOfExpense)
			builder.append(" ORDER BY typeOfExpense ");

		else if (criteria.getSortBy() == SearchCriteria.SortBy.paidDate)
			builder.append(" ORDER BY paidDate ");
		
		else if (criteria.getSortBy() == SearchCriteria.SortBy.challanno)
			builder.append(" ORDER BY challanno ");

		else if (criteria.getSortBy() == SearchCriteria.SortBy.totalAmount)
			builder.append(" ORDER BY totalamount ");

		if (criteria.getSortOrder() == SearchCriteria.SortOrder.ASC)
			builder.append(" ASC ");
		else
			builder.append(" DESC ");

		if (criteria.getSortBy() == SearchCriteria.SortBy.totalAmount)
			builder.append(" NULLS LAST ");
		
		return builder.toString();
	}

	public String getChallanSearchQueryForPlaneSearch(SearchCriteria criteria, List<Object> preparedStmtList) {

		StringBuilder builder = new StringBuilder(QUERY);
		builder = applyFiltersForPlaneSearch(builder, preparedStmtList, criteria);
		return addPaginationWrapperPlainsearch(builder.toString(), preparedStmtList, criteria);
	}
	
	private String addPaginationWrapperPlainsearch(String query, List<Object> preparedStmtList,
			SearchCriteria criteria) {

		String string = addOrderByClause(criteria);

		String finalQuery = paginationWrapper.replace("{}", query);

		finalQuery = finalQuery.replace("{orderby}", string);

		finalQuery = finalQuery.replace("{amount}",
				" 0 as totalamount, ");

		if (criteria.getLimit() != null && criteria.getLimit() != 0) {
			int limit = 0, offset = 0;
			if (criteria.getLimit() != null && criteria.getLimit() <= config.getMaxSearchLimit())
				limit = criteria.getLimit();

			if (criteria.getLimit() != null && criteria.getLimit() > config.getMaxSearchLimit())
				limit = config.getMaxSearchLimit();

			if (criteria.getOffset() != null)
				offset = criteria.getOffset();

			finalQuery = finalQuery.replace("{pagination}", " offset ?  limit ?  ");
			preparedStmtList.add(offset);
			preparedStmtList.add(limit);

		} else {
			finalQuery = finalQuery.replace("{pagination}", " ");
		}

		return finalQuery;
	}
	


	public StringBuilder applyFiltersForPlaneSearch(StringBuilder builder, List<Object> preparedStmtList,
			SearchCriteria criteria) {

		if (criteria.getIds() != null) {
			List<String> ids = criteria.getIds();
			addClauseIfRequired(preparedStmtList, builder);
			builder.append(" challan.id IN (").append(createQuery(ids)).append(")");
			addToPreparedStatement(preparedStmtList, ids);
		}
		if (criteria.getTenantId() != null) {
			addClauseIfRequired(preparedStmtList, builder);
			builder.append(" challan.tenantid like ? ");
			preparedStmtList.add("%" + criteria.getTenantId() +"%");
		}
		if (criteria.getIsBillPaid() != null) {
			addClauseIfRequired(preparedStmtList, builder);
			builder.append("  challan.isBillPaid = ? ");
			preparedStmtList.add(criteria.getIsBillPaid());
		}
		return builder;
	}
	
}
