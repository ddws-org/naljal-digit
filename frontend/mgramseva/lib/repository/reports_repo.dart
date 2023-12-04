import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:provider/provider.dart';

import '../model/reports/InactiveConsumerReportData.dart';
import '../model/reports/bill_report_data.dart';
import '../model/reports/collection_report_data.dart';
import '../providers/common_provider.dart';
import '../services/request_info.dart';
import '../utils/global_variables.dart';
import '../utils/models.dart';

class ReportsRepo extends BaseService{
  Future<List<BillReportData>?> fetchBillReport(Map<String,dynamic> params,
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
        res['BillReportData'].forEach((val){
          billreports?.add(BillReportData.fromJson(val));
        });
      } catch (e) {
        print(e);
        billreports = null;
      }
    }
    return billreports;
  }

  Future<List<CollectionReportData>?> fetchCollectionReport(Map<String,dynamic> params,
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
        res['CollectionReportData'].forEach((val){
          billreports?.add(CollectionReportData.fromJson(val));
        });
      } catch (e) {
        print(e);
        billreports = null;
      }
    }
    return billreports;
  }

  Future<List<InactiveConsumerReportData>?> fetchInactiveConsumerReport(Map<String,dynamic> params,
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
        res['InactiveConsumerReport'].forEach((val){
          inactiveConsumers?.add(InactiveConsumerReportData.fromJson(val));
        });
      } catch (e) {
        print(e);
        inactiveConsumers = null;
      }
    }
    return inactiveConsumers;
  }
}