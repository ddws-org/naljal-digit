class Url {
  static UserUrl user = UserUrl();

  static const String LOCALIZATION = 'localization/messages/v1/_search';

  static const String MDMS = 'mdms-v2/v1/_search';
  static const String FILE_UPLOAD = 'filestore/v1/files';
  static const String FILE_FETCH = 'filestore/v1/files/url';
  static const String URL_SHORTNER = 'eus/shortener';
  static const String FETCH_FILESTORE_ID_PDF_SERVICE = 'pdf-service/v1/_create';

  /// Expenses
  static const String ADD_EXPENSES = 'echallan-services/eChallan/v1/_create';
  static const String EXPENSE_SEARCH = 'echallan-services/eChallan/v1/_search';
  static const String UPDATE_EXPENSE = 'echallan-services/eChallan/v1/_update';

  // Proprety Create
  static const String ADD_PROPERTY = 'property-services/property/_create';
  //Property Fetch
  static const String GET_PROPERTY = 'property-services/property/_search';
  //Property  Update
  static const String UPDATE_PROPERTY = 'property-services/property/_update';
  // Connection Create
  static const String ADD_WC_CONNECTION = 'ws-services/wc/_create';

  // Connection Create
  static const String UPDATE_WC_CONNECTION = 'ws-services/wc/_update';

  //Demand Generation
  static const String METER_CONNECTION_DEMAND =
      'ws-calculator/meterConnection/_create';
  static const String BULK_DEMAND = 'ws-calculator/waterCalculator/_bulkDemand';
  static const String SEARCH_METER_CONNECTION_DEMAND =
      'ws-calculator/meterConnection/_search';

  //Fetch Events
  static const String FETCH_EVENTS = 'egov-user-event/v1/events/_search';

  //Update Events
  static const String UPDATE_EVENTS = 'egov-user-event/v1/events/_update';

  ///Fetch Demands
  static const String FETCH_DEMAND = 'billing-service/demand/_search';
  static const String FETCH_UPDATE_DEMAND =
      'ws-calculator/waterCalculator/_getPenaltyDetails';
  static const String FETCH_AGGREGATE_DEMAND =
      'billing-service/demand/_getAggregateDemandDetails';

  static const String FETCH_BILL = 'billing-service/bill/v2/_fetchbill';
  static const String SEARCH_BILL = 'billing-service/bill/v2/_search';
  // Connection Fetch
  static const String FETCH_WC_CONNECTION = 'ws-services/wc/_search';
  static const String VENDOR_SEARCH = 'vendor/v1/_search';
  static const String CREATE_VENDOR = 'vendor/v1/_create';
  static const String VENDOR_REPORT = 'vendor/v1/_vendorReport';
  static const String EGOV_LOCATIONS =
      'egov-location/location/v11/boundarys/_search';

  ///Name Fuzzy Search for Connection search screen
  static const String FETCH_CONNECTION_NAME = 'ws-services/wc/fuzzy/_search';

  /// Connection bill payment
  static const String COLLECT_PAYMENT = 'collection-services/payments/_create';

  static const String CREATE_TRANSACTION = 'pg-service/transaction/v1/_create';
  static const String UPDATE_TRANSACTION = 'pg-service/transaction/v1/_update';

  static const String FETCH_BILL_PAYMENTS =
      'collection-services/payments/WS/_search';

  /// user feed back
  static const String POST_PAYMENT_FEEDBACK = 'ws-services/wc/_submitfeedback';
  static const String GET_USERS_PAYMENT_FEEDBACK =
      'ws-services/wc/_getfeedback';

  /// Dashboard
  static const String EXPENDITURE_METRIC =
      'echallan-services/eChallan/v1/_expenseDashboard';
  static const String REVENUE_METRIC = 'ws-services/wc/_revenueDashboard';
  static const String GRAPHICAL_DASHBOARD =
      'dashboard-analytics/dashboard/getChartV2';
  static const String DASHBOARD_COLLECTION_TABLE_DATA =
      'ws-services/wc/_revenueCollectionData';
  static const String DASHBOARD_EXPENSE_TABLE_DATA =
      'echallan-services/eChallan/v1/_chalanCollectionData';

  /// GPWSC Details
  static const String IFIX_DEPARTMENT_ENTITY =
      'ifix-department-entity/departmentEntity/v1/_search';
  static const String ADAPTER_MASTER_DATA_PROJECT_SEARCH =
      'adapter-master-data/project/v1/_search';

  ///Reports
  static const String LEDGER_REPORT = 'ws-services/wc/ledger-report';
  static const String MONTHLY_LEDGER_REPORT = 'ws-services/wc/month-report';
  static const String BILL_REPORT = 'ws-services/wc/_billReport';
  static const String COLLECTION_REPORT = 'ws-services/wc/_collectionReport';
  static const String INACTIVE_CONSUMER_REPORT =
      'ws-services/wc/_inactiveConsumerReport';
  static const String EXPENSE_BILL_REPORT =
      'echallan-services/eChallan/v1/_expenseBillReport';
  static const String WATER_CONNECTION_COUNT =
      'ws-services/wc/_countWCbyDemandGenerationDate';
  static const String WATER_CONNECTION_DEMAND_NOT_GENERATED =
      'ws-services/wc/consumers/demand-not-generated';
}

class UserUrl {
  static const String RESET_PASSWORD = 'user/password/nologin/_update';
  static const String OTP_RESET_PASSWORD = 'user-otp/v1/_send';
  static const String AUTHENTICATE = 'user/oauth/token';
  static const String USER_PROFILE = 'user/_search';
  static const String EDIT_PROFILE = 'user/profile/_update';
  static const String CHANGE_PASSWORD = 'user/password/_update';
  static const String LOGOUT_USER = 'user/_logout';
}
