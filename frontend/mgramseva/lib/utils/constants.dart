import 'package:flutter/material.dart';
import 'package:mgramseva/icons/home_icons_icons.dart';
import 'package:mgramseva/icons/home_icons_modified_icons.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/models.dart';

// ignore: non_constant_identifier_names
class Constants {
  static const int PAGINATION_LIMIT = 75;
  static const int MAX_PDF_PAGES = 100;
  static const String HOME_NOTIFICATIONS_LIMIT = "50";

  /// Package Name
  static const String PACKAGE_NAME = "com.dwss.mgramseva";

  static const String DIGIT_FOOTER_ENDPOINT =
      'mgramseva-dev-assets/logo/digit-footer.png';
  static const String DIGIT_FOOTER_WHITE_ENDPOINT =
      'mgramseva-dev-assets/logo/digit-footer-bw.png';
  static const String LOGIN_KEY = 'login_key';
  static const String LANGUAGE_KEY = 'language_key';
  static const String STATES_KEY = 'states_key';
  static const String USER_PROFILE_KEY = 'user_profile_key';
  static const String CREATE_CONSUMER_KEY = 'create_consumer_key';
  static const String ADD_EXPENSE_KEY = 'add_expense_key';
  static const String HOME_KEY = 'home_key';
  static const String APP_VERSION = 'appversion';
  static const String BUILD_NUMBER = 'buildNumber';

  static List<KeyValue> GENDER = [
    KeyValue('CORE_COMMON_GENDER_MALE', 'MALE'),
    KeyValue('CORE_COMMON_GENDER_FEMALE', 'FEMALE'),
    KeyValue('CORE_COMMON_GENDER_TRANSGENDER', 'TRANSGENDER'),
  ];

  static List<KeyValue> EXPENSESTYPE = [
    KeyValue(i18.common.YES, true),
    KeyValue(i18.common.NO, false),
  ];
  static List<KeyValue> AMOUNTTYPE = [
    KeyValue('FULL', 'Full'),
    KeyValue('PARTIAL', 'Partial'),
  ];

  static List<HomeItem> HOME_ITEMS = [
    HomeItem(
      "CORE_HOUSEHOLD_REGISTER",
      (i18.homeWalkThroughMSg.HOUSEHOLD_REGISTER_MSG),
      HomeIcons.hhregister,
      Routes.HOUSEHOLD_REGISTER,
      {},
    ),
    HomeItem(
        "CORE_COLLECT_PAYMENTS",
        (i18.homeWalkThroughMSg.COLLECT_PAYMENTS_MSG),
        HomeIcons.collectpayment,
        Routes.HOUSEHOLD,
        {'Mode': "collect"}),
    HomeItem(
        "DOWNLOAD_BILLS_AND_RECEIPTS",
        (i18.homeWalkThroughMSg.DOWNLOAD_BILLS_AND_RECEIPTS_MSG),
        HomeIcons.printreciept,
        Routes.HOUSEHOLDRECEIPTS,
        {'Mode': "receipts"}),
    HomeItem(
        "ADD_EXPENSES_RECORD",
        (i18.homeWalkThroughMSg.ADD_EXPENSE_RECORD_MSG),
        HomeIconsModified.vector_1,
        Routes.EXPENSES_ADD, {}),
    HomeItem(
        "CORE_UPDATE_EXPENSES",
        (i18.homeWalkThroughMSg.UPDATE_EXPENSE_MSG),
        HomeIconsModified.vector,
        Routes.EXPENSE_SEARCH, {}),
    HomeItem(
        "CORE_GENERATE_DEMAND",
        (i18.homeWalkThroughMSg.GENERATE_DEMAND_MSG),
        HomeIcons.generaedemand,
        Routes.MANUAL_BILL_GENERATE, {}),
    HomeItem(
        "CORE_CONSUMER_CREATE",
        (i18.homeWalkThroughMSg.CREATE_CONSUMER_MSG),
        HomeIcons.createconsumer,
        Routes.CONSUMER_CREATE, {}),
    HomeItem(
        "CORE_UPDATE_CONSUMER_DETAILS",
        (i18.homeWalkThroughMSg.UPDATE_CONSUMER_DETAILS_MSG),
        HomeIcons.updateconsumer,
        Routes.CONSUMER_SEARCH_UPDATE,
        {'Mode': "update"}),
    HomeItem(
        "CORE_GPWSC_DASHBOARD",
        (i18.homeWalkThroughMSg.GPWSC_DASHBOARD_MSG),
        HomeIcons.dashboard,
        Routes.DASHBOARD, {}),
    HomeItem(
        "CORE_GPWSC_DETAILS_AND_RATE_INFO",
        (i18.dashboard.CORE_GPWSC_DETAILS_AND_RATE_INFO),
        HomeIcons.gpwscdetails,
        Routes.GPWSC_DETAILS_AND_RATE_INFO, {}),
    HomeItem(
        "CORE_REPORTS",
        (i18.dashboard.CORE_REPORTS),
        Icons.assessment,
        Routes.REPORTS, {}),
  ];

  static List<KeyValue> SERVICECATEGORY = [
    KeyValue("Billing Service", "BILLING SERVICE"),
    KeyValue("Property Service", "PROPERTY SERVICE"),
    KeyValue("Rental Service", "RENTAL SERVICE"),
  ];

  static List<KeyValue> PROPERTYTYPE = [
    KeyValue("Residential", "RESIDENTIAL"),
    KeyValue("Non Residential", "NON RESIDENTIAL"),
  ];

  static List<KeyValue> PAYMENT_AMOUNT = [
    KeyValue(i18.common.FULL_AMOUNT, 'fullAmount'),
    KeyValue(i18.common.CUSTOM_AMOUNT, 'customAmount'),
  ];

  static List<KeyValue> CONSUMER_PAYMENT_METHOD = [
    KeyValue(i18.common.PAYGOV, 'PAYGOV'),
    KeyValue(i18.common.OFFLINE_NEFT, 'OFFLINE_NEFT'),
    KeyValue(i18.common.OFFLINE_RTGS, 'OFFLINE_RTGS'),
    KeyValue(i18.common.POSTAL_ORDER, 'POSTAL_ORDER'),
  ];

  static List<KeyValue> EMPLOYEE_PAYMENT_METHOD = [
    KeyValue(i18.common.CASH, 'CASH'),
    KeyValue(i18.common.OFFLINE_NEFT, 'OFFLINE_NEFT'),
    KeyValue(i18.common.OFFLINE_RTGS, 'OFFLINE_RTGS'),
    KeyValue(i18.common.POSTAL_ORDER, 'POSTAL_ORDER'),
  ];

  static List<String> MONTHS = [
    i18.common.JAN,
    i18.common.FEB,
    i18.common.MAR,
    i18.common.APR,
    i18.common.MAY,
    i18.common.JUN,
    i18.common.JULY,
    i18.common.AUG,
    i18.common.SEP,
    i18.common.OCT,
    i18.common.NOV,
    i18.common.DEC,
  ];

  /// Tabs
  static const ALL = 'ALL';
  static const PENDING = 'PENDING';
  static const PAID = 'PAID';

  static const List<String> CONNECTION_STATUS = ['Inactive', 'Active'];

  static const String INVALID_EXCEPTION_CODE = 'InvalidAccessTokenException';

  static List<KeyValue> CONSUMER_PAYMENT_TYPE = [
    KeyValue(i18.common.ARREARS, 'arrears'),
    KeyValue(i18.common.CORE_ADVANCE, 'advance'),
  ];

  static List<String> DOWNLOAD_OPTIONS = [
    i18.householdRegister.PDF,
    i18.householdRegister.EXCEL
  ];
}
