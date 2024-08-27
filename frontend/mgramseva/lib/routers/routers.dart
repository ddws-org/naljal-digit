class Routes {
  ///Authentication
  static const String LANDING_PAGE = '/';

  static const String DEFAULT_PASSWORD_UPDATE = '/passwordupdated';

  static const String SELECT_LANGUAGE = '/selectLanguage';
  static const String LOGIN = '$SELECT_LANGUAGE/login';

  static const String HOME = '/home';

  static const String FORGOT_PASSWORD = '$LOGIN/forgotPassword';

  // static const String HOUSE_HOLD = 'household/search';

  static const String HOUSEHOLD = '/home/householdSearch';
  static const String HOUSEHOLDRECEIPTS = '/home/householdReceiptsSearch';
  static const String HOUSEHOLD_REGISTER = '/home/householdRegister';

  static const String UPDATE_PASSWORD = '$LOGIN/updatepassword';

  static const String RESET_PASSWORD = '$FORGOT_PASSWORD/resetPassword';

  static const String CONSUMER_SEARCH = 'home/consumerSearch';

  /// Profile
  static const String EDIT_PROFILE = '/home/editProfile';

  static const String CHANGE_PASSWORD = '/home/changepassword';

  static const String CHANGE_PASSWORD_SUCCESS = '$CHANGE_PASSWORD/success';

  static const String EDIT_PROFILE_SUCCESS = '$EDIT_PROFILE/success';

  /// Expense
  static const String EXPENSES_ADD = '/home/addExpense';

  static const String EXPENSES_ADD_SUCCESS = '/home/addExpense/success';

  static const String EXPENSE_SEARCH = '/home/searchExpense';

  static const String EXPENSE_RESULT = '/home/searchExpense/result';

  static const String EXPENSE_UPDATE =
      '/home/searchExpense/result/updateExpense';

  static const String HOUSEHOLD_DETAILS = '/home/householddetails';

  static const String HOUSEHOLD_DETAILS_COLLECT_PAYMENT =
      '/household/details/collectPayment';

  static const String HOUSEHOLD_DETAILS_SUCCESS =
      '$HOUSEHOLD_DETAILS_COLLECT_PAYMENT/success';

  static const String DASHBOARD = '/home/dashboard';
  static const String GPWSC_DETAILS_AND_RATE_INFO = '/home/villagedetails';

  static const String BILL_GENERATE = '/home/householddetails/billgenerate';

  static const String MANUAL_BILL_GENERATE = '/home/billmanualgenerate';

  ///  Consumer
  static const String CONSUMER_CREATE = '/home/consumercreate';

  static const String CONSUMER_SEARCH_UPDATE = '/home/consumersearchupdate';
  static const String CONSUMER_UPDATE = '/home/consumerupdate';

  static const String SEARCH_CONSUMER_RESULT = '/home/consumersearchresult';

  static const String PAYMENT_SUCCESS = '/paymentSuccess';
  static const String PAYMENT_FAILURE = '/paymentFailure';

  static const String SUCCESS_VIEW = '/success';

  static const String POST_PAYMENT_FEED_BACK = '/feedBack';

  static const String COMMON_PAYMENT = '/commonPayment';

  static const String FEED_BACK_SUBMITTED_SUCCESSFULLY =
      '/feedBack/submittedSuccessfully';

  static const String COMMON_DOWNLOAD = '/withoutAuth/mgramseva-common';

  static const String NOTIFICATIONS = '/home/notifications';
  static const String REPORTS = '/home/reports';
  static const String LEDGER_REPORTS = '/home/leadger/reports';
  static const String PRIVACY_POLICY = '/privacy';
  static const String TERMS_OF_USE = '/terms';
  static const String PRIVACY_POLICY_S = '/privacy/';
  static const String TERMS_OF_USE_S = '/terms/';
}
