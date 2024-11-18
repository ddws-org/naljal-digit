package org.egov.naljalcustomisation.repository.builder;

import org.springframework.stereotype.Component;

@Component
public class CustomisationQueryBuilder {

    private static final String distinctTenantIdsCriteria = "SELECT distinct(tenantid) FROM eg_ws_connection ws";

    public static final String PENDINGCOLLECTION = "SELECT SUM(DMDL.TAXAMOUNT - DMDL.COLLECTIONAMOUNT) FROM EGBS_DEMAND_V1 DMD INNER JOIN EGBS_DEMANDDETAIL_V1 DMDL ON DMD.ID=DMDL.DEMANDID AND DMD.TENANTID=DMDL.TENANTID WHERE DMD.BUSINESSSERVICE = 'WS' and DMD.status = 'ACTIVE' ";

    public static final String PREVIOUSDAYCASHCOLLECTION = "select count(*), sum(p.totalamountpaid) from egcl_payment p join egcl_paymentdetail pd on p.id = pd.paymentid where p.paymentmode='CASH' and pd.businessservice = 'WS' ";

    public static final String PREVIOUSDAYONLINECOLLECTION = "select count(*), sum(p.totalamountpaid) from egcl_payment p join egcl_paymentdetail pd on p.id = pd.paymentid where p.paymentmode='ONLINE' and pd.businessservice = 'WS' ";

    public static final String PREVIOUSMONTHEXPPAYMENT = "SELECT coalesce(SUM(PAYMT.TOTALAMOUNTPAID),0) FROM EGCL_PAYMENT PAYMT JOIN EGCL_PAYMENTDETAIL PAYMTDTL ON (PAYMTDTL.PAYMENTID = PAYMT.ID) WHERE PAYMTDTL.BUSINESSSERVICE like '%EXPENSE%' ";

    public static final String PREVIOUSMONTHEXPENSE = " select coalesce(sum(billdtl.totalamount),0) from eg_echallan challan, egbs_billdetail_v1 billdtl, egbs_bill_v1 bill  where challan.referenceId= billdtl.consumercode  and billdtl.billid = bill.id and challan.isbillpaid ='true'  ";

    public static final String ACTIVEEXPENSECOUNTQUERY =  "select count(*) from eg_echallan  where applicationstatus ='ACTIVE' ";


    public String getDistinctTenantIds() {
        return distinctTenantIdsCriteria;
    }
}
