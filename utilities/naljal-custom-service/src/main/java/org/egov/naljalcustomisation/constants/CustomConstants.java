package org.egov.naljalcustomisation.constants;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class CustomConstants {

    public static final String MDMS_EGFFINACIALYEAR_PATH = "$.MdmsRes.egf-master.FinancialYear[?(@.code==\"{}\")]";
    public static final String PENDING_COLLECTION_SMS = "mGram.GPUser.CollectionReminder";;
    public static final String USREVENTS_EVENT_POSTEDBY = "SYSTEM-CHALLAN";
    public static final String PENDING_COLLECTION_EVENT = "PENDING_COLLECTION_EN_REMINDER";
    public static final String USREVENTS_EVENT_TYPE = "SYSTEMGENERATED";
    public static final String PENDING_COLLECTION_USEREVENT = "PENDING_COLLECTION_USEREVENT";
    public static final String TODAY_CASH_COLLECTION_SMS = "TODAY_COLLECTION_FROM_CASH";
    public static final String TODAY_ONLINE_COLLECTION_SMS = "TODAY_COLLECTION_FROM_ONLINE";
    public static final String TODAY_CASH_COLLECTION = "TODAY_COLLECTION_AS_CASH_SMS";
    public static final String TODAY_COLLECTION = "TODAY_COLLECTION";
    public static final String TODAY_ONLINE_COLLECTION = "TODAY_COLLECTION_FROM_ONLINE_SMS";
    public static final String MONTHLY_SUMMARY_SMS = "mGram.GPUser.PreviousMonthSummary";
    public static final String MONTHLY_SUMMARY_EVENT = "MONTHLY_SUMMARY_EN_REMINDER";
    public static final String MONTHLY_SUMMARY = "MONTHLY_SUMMARY";
    public static final String NEW_EXPENDITURE_EVENT = "NEW_ENPENDITURE_EN_REMINDER";
    public static final String NEW_EXPENDITURE_SMS = "mGram.GPUser.EnterExpense";
    public static final String NEW_EXPENSE_ENTRY = "NEW_EXPENSE_ENTRY";
    public static final String MARK_PAID_BILL_EVENT = "MARK_PAID_BILL_EN_REMINDER";
    public static final String EXPENSE_PAYMENT = "EXPENSE_PAYMENT";
    public static final String MARK_PAID_BILL_SMS = "mGram.GPUser.MarkExpense";
    public static final String SEARCH_TYPE_CONNECTION = "CONNECTION";
    public static final String MODIFIED_FINAL_STATE = "APPROVED";
    public static final String STATUS_APPROVED = "CONNECTION_ACTIVATED";
    public static final List<String> FINAL_CONNECTION_STATES = Collections
            .unmodifiableList(Arrays.asList(MODIFIED_FINAL_STATE, STATUS_APPROVED));
    public static final String APP_CREATED_DATE = "appCreatedDate";
    public static final String INITIAL_METER_READING_CONST = "initialMeterReading";
    public static final String LOCALITY = "locality";
    public static final String ADHOC_PENALTY = "adhocPenalty";
    public static final String ADHOC_REBATE = "adhocRebate";
    public static final String ADHOC_PENALTY_REASON = "adhocPenaltyReason";
    public static final String ADHOC_PENALTY_COMMENT = "adhocPenaltyComment";
    public static final String ADHOC_REBATE_REASON = "adhocRebateReason";
    public static final String ADHOC_REBATE_COMMENT = "adhocRebateComment";
    public static final String DETAILS_PROVIDED_BY = "detailsProvidedBy";
    public static final String ESTIMATION_FILESTORE_ID = "estimationFileStoreId";
    public static final String SANCTION_LETTER_FILESTORE_ID = "sanctionFileStoreId";
    public static final String ESTIMATION_DATE_CONST = "estimationLetterDate";
    public static final String ES_DATA_PATH = "$..Data";



}
