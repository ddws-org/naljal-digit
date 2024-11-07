import 'dart:convert';
import 'dart:developer';

import 'package:mgramseva/model/reports/expense_bill_report_data.dart';
import 'package:mgramseva/model/reports/leadger_report.dart';
import 'package:mgramseva/model/reports/monthly_ledger_data.dart';
import 'package:mgramseva/model/reports/vendor_report_data.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:provider/provider.dart';

import '../model/reports/InactiveConsumerReportData.dart';
import '../model/reports/WaterConnectionCount.dart';
import '../model/reports/bill_report_data.dart';
import '../model/reports/collection_report_data.dart';
import '../providers/common_provider.dart';
import '../services/request_info.dart';
import '../utils/global_variables.dart';
import '../utils/models.dart';

class ReportsRepo extends BaseService {
  Future<List<BillReportData>?> fetchBillReport(Map<String, dynamic> params,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    List<BillReportData>? billreports;
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());

    var res = await makeRequest(
        url: Url.BILL_REPORT,
        queryParameters: params,
        requestInfo: requestInfo,
        body: {},
        method: RequestType.POST);
    if (res != null && res['BillReportData'] != null) {
      try {
        billreports = [];
        res['BillReportData'].forEach((val) {
          billreports?.add(BillReportData.fromJson(val));
        });
      } catch (e) {
        print(e);
        billreports = null;
      }
    }
    return billreports;
  }

  Future<List<LedgerData>?> fetchLedgerReport(Map<String, dynamic> params,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    List<LedgerData>? ledgerReports;
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());
    var res = await makeRequest(
        url: Url.LEDGER_REPORT,
        queryParameters: params,
        body: {"RequestInfo": requestInfo},
        method: RequestType.POST);

    if (res != null && res['ledgerReport'] != null) {
      try {
        ledgerReports = [];
        res['ledgerReport'].forEach((val) {
          ledgerReports?.add(LedgerData.fromJson(val));
        });
      } catch (e) {
        print(e);
        ledgerReports = null;
      }
    }
    return ledgerReports;
  }

  Future<List<CollectionReportData>?> fetchCollectionReport(
      Map<String, dynamic> params,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    List<CollectionReportData>? billreports;
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());

    var res = await makeRequest(
        url: Url.COLLECTION_REPORT,
        queryParameters: params,
        requestInfo: requestInfo,
        body: {},
        method: RequestType.POST);
    if (res != null && res['CollectionReportData'] != null) {
      try {
        billreports = [];
        res['CollectionReportData'].forEach((val) {
          billreports?.add(CollectionReportData.fromJson(val));
        });
      } catch (e) {
        print(e);
        billreports = null;
      }
    }
    return billreports;
  }

  Future<List<InactiveConsumerReportData>?> fetchInactiveConsumerReport(
      Map<String, dynamic> params,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    List<InactiveConsumerReportData>? inactiveConsumers;
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());

    var res = await makeRequest(
        url: Url.INACTIVE_CONSUMER_REPORT,
        queryParameters: params,
        requestInfo: requestInfo,
        body: {},
        method: RequestType.POST);
    if (res != null && res['InactiveConsumerReport'] != null) {
      try {
        inactiveConsumers = [];
        res['InactiveConsumerReport'].forEach((val) {
          inactiveConsumers?.add(InactiveConsumerReportData.fromJson(val));
        });
      } catch (e) {
        print(e);
        inactiveConsumers = null;
      }
    }
    return inactiveConsumers;
  }

  Future<List<ExpenseBillReportData>?> fetchExpenseBillReport(
      Map<String, dynamic> params,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    List<ExpenseBillReportData>? expenseBillReports;
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());

    var res = await makeRequest(
        url: Url.EXPENSE_BILL_REPORT,
        queryParameters: params,
        requestInfo: requestInfo,
        body: {},
        method: RequestType.POST);
    if (res != null && res['ExpenseBillReportData'] != null) {
      try {
        expenseBillReports = [];
        res['ExpenseBillReportData'].forEach((val) {
          expenseBillReports?.add(ExpenseBillReportData.fromJson(val));
        });
      } catch (e) {
        print(e);
        expenseBillReports = null;
      }
    }
    return expenseBillReports;
  }

  Future<List<VendorReportData>?> fetchVendorReport(Map<String, dynamic> params,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    List<VendorReportData>? vendorReports;
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());
    var res = await makeRequest(
        url: Url.VENDOR_REPORT,
        queryParameters: params,
        requestInfo: requestInfo,
        body: {},
        method: RequestType.POST);
    if (res != null && res['VendorReportData'] != null) {
      try {
        vendorReports = [];
        res['VendorReportData'].forEach((val) {
          vendorReports?.add(VendorReportData.fromJson(val));
        });
      } catch (e) {
        print(e);
        vendorReports = null;
      }
    }
    return vendorReports;
  }

  Future<MonthReport?> fetchMonthlyLedgerReport(Map<String, dynamic> params,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    MonthReport? monthlyLedgerReports;
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());
    var res = await makeRequest(
        url: Url.MONTHLY_LEDGER_REPORT,
        queryParameters: params,
        requestInfo: requestInfo,
        body: {},
        method: RequestType.POST);
    if (res != null && res['monthReport'] != null) {
      try {
        monthlyLedgerReports = null;
        monthlyLedgerReports = MonthReport.fromJson(res);
      } catch (e) {
        print(e);
        monthlyLedgerReports = null;
      }
    }
    return monthlyLedgerReports;
  }

  Future<WaterConnectionCountResponse?> fetchWaterConnectionsCount(
      Map<String, dynamic> params,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    WaterConnectionCountResponse? waterConnectionResponse =
        WaterConnectionCountResponse();
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        '_get',
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());
    var res = await makeRequest(
        url: Url.WATER_CONNECTION_COUNT,
        queryParameters: params,
        requestInfo: requestInfo,
        body: {},
        method: RequestType.POST);
    if (res != null) {
      try {
        waterConnectionResponse = WaterConnectionCountResponse.fromJson(res);
      } catch (e) {
        print(e);
        waterConnectionResponse = null;
      }
    }
    return waterConnectionResponse;
  }
}
