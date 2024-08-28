import 'package:flutter/material.dart';

class Keys {
  static LanguagePageKeys language = const LanguagePageKeys();
  static ForgotPasswordKeys forgotPassword = const ForgotPasswordKeys();
  static LoginKeys login = const LoginKeys();
  static EditProfileKeys editProfile = const EditProfileKeys();
  static ChangePasswordKeys changePassword = const ChangePasswordKeys();
  static CreateConsumerKeys createConsumer = const CreateConsumerKeys();
  static SearchConnectionKeys searchConnection = const SearchConnectionKeys();
  static GenerateBulkDemandKeys bulkDemand = const GenerateBulkDemandKeys();
  static CommonKeys common = const CommonKeys();
  static ExpenseKeys expense = const ExpenseKeys();
  static DashboardKeys dashboard = const DashboardKeys();
  static HouseholdKeys household = const HouseholdKeys();
  static BillReportKeys billReport = const BillReportKeys();
}

class LanguagePageKeys {
  const LanguagePageKeys();
  Key get LANGUAGE_PAGE_CONTINUE_BTN =>
      Key("language selected continue button");
}

class ForgotPasswordKeys {
  const ForgotPasswordKeys();
  Key get FORGOT_PASSWORD_BUTTON => Key("forgot Password Button");
  Key get FORGOT_PASSWORD_MOBILE_NO => Key("forgot Password Mobile");
  Key get FORGOT_PASSWORD_CONTINUE_BTN =>
      Key("forgot Password Continue button");
}

class LoginKeys {
  const LoginKeys();
  Key get LOGIN_PHONE_NUMBER_KEY => Key("PhoneNum");
  Key get LOGIN_PASSWORD_KEY => Key("Login Password");
  Key get LOGIN_BTN_KEY => Key("Login");
}

class EditProfileKeys {
  const EditProfileKeys();
  Key get SIDE_BAR_EDIT_PROFILE_TILE_KEY => Key("Edit Profile Side Bar");
  Key get EDIT_PROFILE_NAME_KEY => Key("Edit Profile Name");
  Key get EDIT_PROFILE_E_MAIL_KEY => Key("Edit Profile e-mail");
  Key get EDIT_PROFILE_SAVE_BTN_KEY => Key("Edit Profile Save");
}

class ChangePasswordKeys {
  const ChangePasswordKeys();
  Key get SIDE_BAR_CHANGE_PASSWORD_TILE_KEY => Key("Change Password Side Bar");
  Key get CURRENT_PASSWORD_KEY => Key("Current Password Key");
  Key get NEW_PASSWORD_KEY => Key("New Password Key");
  Key get CONFIRM_PASSWORD_KEY => Key("Confirm Password Key");
  Key get CHANGE_PASSWORD_BTN_KEY => Key("Change Password Button Key");
}

class CreateConsumerKeys {
  const CreateConsumerKeys();
  Key get CONSUMER_NAME_KEY => Key("consumerName");
  Key get CONSUMER_SPOUSE_PARENT_KEY => Key("spouse parentName");
  Key get CONSUMER_PHONE_NUMBER_KEY => Key("consumerPhone");
  Key get CONSUMER_OLD_ID_KEY => Key("consumerOldID");
  Key get CONSUMER_CATEORY_KEY => Key("consumerCategory");
  Key get CONSUMER_SUB_CATEORY_KEY => Key("consumerSubCategory");
  Key get CONSUMER_PROPERTY_KEY => Key("consumerProperty");
  Key get CONSUMER_SERVICE_KEY => Key("consumerService");
  Key get CONSUMER_LAST_BILLED_CYCLE => Key("consumerLastBilledCycle");
  Key get CONSUMER_PREVIOUS_READING_DATE_KEY =>
      Key("consumerPreviousReadingDatePicker");
  Key get CONSUMER_METER_NUMBER_KEY => Key("consumerMeterNumber");
  Key get CONSUMER_ARREARS_KEY => Key("consumerArrears");
  Key get CREATE_CONSUMER_BTN_KEY => Key("createConsumerBtn");
  Key get CONSUMER_REMARKS_KEY => Key("consumerRemarks");
}

class SearchConnectionKeys {
  const SearchConnectionKeys();
  Key get SEARCH_PHONE_NUMBER_KEY => Key("phoneSearch");
  Key get SEARCH_NAME_KEY => Key("nameSearch");
  Key get SEARCH_OLD_ID_KEY => Key("old Connection  Search");
  Key get SEARCH_NEW_ID_KEY => Key("new Connection Search");
  Key get SHOW_MORE_BTN => Key("Show more");
  Key get SEARCH_BTN_KEY => Key("Search Connection Btn");
}

class GenerateBulkDemandKeys {
  const GenerateBulkDemandKeys();
  Key get BULK_DEMAND_BILLING_YEAR => Key('Bulk Demand billingYear');
  Key get BULK_DEMAND_BILLING_CYCLE => Key('Bulk Demand billingCycle');
  Key get GENERATE_BILL_BTN => Key('Generate Bill button');
}

class CommonKeys {
  const CommonKeys();
  Key get LOGOUT_TILE_KEY => Key('Log out Side Bar');
  Key get CONSUMER_PREVIOUS_READING_DATE_KEY =>
      Key("consumerPreviousReadingDatePicker");
  Key get PAGINATION_DROPDOWN => Key("drop_down");
  Key get PAGINATION_COUNT => Key("20");
  Key get SHARE => Key("Share Whatsapp");
}

class ExpenseKeys {
  const ExpenseKeys();
  Key get VENDOR_NAME => Key("expense_vendor_name");
  Key get VENDOR_MOBILE_NUMBER => Key("expense_mobile_number");
  Key get EXPENSE_TYPE => Key("expense_type");
  Key get EXPENSE_AMOUNT => Key("expense_amount");
  Key get EXPENSE_BILL_DATE => Key("expense_bill_date");
  Key get EXPENSE_PARTY_DATE => Key("expense_party_date");
  Key get EXPENSE_SUBMIT => Key("expense_submit");
  Key get BACK_BTN => Key("back_home");

  Key get SEARCH_VENDOR_NAME => Key("search_vendor_name");
  Key get SEARCH_EXPENSES => Key("search_expenses_btn");
  Key get UPDATE_EXPNEDITURE => Key("update_expenditure");
  Key get SEARCH_EXPENSE_TYPE => Key("search_expense_type");
  Key get SEARCH_EXPENSE_SHOW => Key("search_expense_show");
  Key get SEARCH_EXPENSE_BILL_ID => Key("search_expense_billId");
}

class DashboardKeys {
  const DashboardKeys();
  Key get DASHBOARD_SEARCH => Key("dashboard_search");
  Key get DASHBOARD_DATE_PICKER => Key("dashboard_date_picker");
  Key get SECOND_TAB => Key("1");
  Key get THIRD_TAB => Key("2");
}

class HouseholdKeys {
  const HouseholdKeys();
  Key get HOUSEHOLD_SEARCH => Key("household_search");
}

class BillReportKeys {
  const BillReportKeys();
  Key get BILL_REPORT_VIEW_BUTTON => Key("bill_report_view_button");
  Key get LEDGER_REPORT_VIEW_BUTTON => Key("bill_report_view_button");
  Key get BILL_REPORT_DOWNLOAD_BUTTON => Key("bill_report_download_button");
  Key get COLLECTION_REPORT_VIEW_BUTTON => Key("collection_report_view_button");
  Key get INACTIVE_CONSUMER_REPORT_VIEW_BUTTON =>
      Key("inactive_consumer_report_view_button");
  Key get COLLECTION_REPORT_DOWNLOAD_BUTTON =>
      Key("collection_report_download_button");
  Key get BILL_REPORT_BILLING_YEAR => Key("bill_report_billing_year");
  Key get BILL_REPORT_BILLING_CYCLE => Key("bill_report_billing_cycle");
  Key get EXPENSE_BILL_REPORT_VIEW_BUTTON =>
      Key("expense_bill_report_view_button");
  Key get VENDOR_REPORT_VIEW_BUTTON => Key("vendor_report_view_button");
  Key get MONTHLY_LEDGER_REPORT_VIEW_BUTTON =>
      Key("monthly_ledger_report_view_button");
}
