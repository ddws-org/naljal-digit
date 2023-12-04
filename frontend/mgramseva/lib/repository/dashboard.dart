
import 'package:mgramseva/model/dashboard/revenue_dashboard.dart';
import 'package:mgramseva/model/dashboard/revenue_chart.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

class DashBoardRepository extends BaseService {

  Future<Map?> getMetricInformation(bool isExpenditure, Map<String, dynamic> query) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    Map? metricInformation;

    var res = await makeRequest(
        url: isExpenditure ? Url.EXPENDITURE_METRIC : Url.REVENUE_METRIC,
        method: RequestType.POST,
        queryParameters: query,
        body: {},
        requestInfo:  RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            commonProvider.userDetails?.accessToken,
            commonProvider.userDetails?.userRequest?.toJson()
        ));

    if (res != null) {
      metricInformation = res[isExpenditure ? 'ExpenseDashboard' : 'RevenueDashboard'];
    }
    return metricInformation;
  }

  Future<Map?> getUsersFeedBackByMonth(Map<String, dynamic> query) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    Map? feedBack;

    var res = await makeRequest(
        url: Url.GET_USERS_PAYMENT_FEEDBACK,
        method: RequestType.POST,
        queryParameters: query,
        body: {},
        requestInfo:  RequestInfo(
          APIConstants.API_MODULE_NAME,
          APIConstants.API_VERSION,
          APIConstants.API_TS,
          "_search",
          APIConstants.API_DID,
          APIConstants.API_KEY,
          APIConstants.API_MESSAGE_ID,
          commonProvider.userDetails!.accessToken,
        ));

    if (res != null) {
      feedBack = res['feedback'];
    }
    return feedBack;
  }

  Future<List<Revenue>?> fetchRevenueDetails(Map<String, dynamic> queryParams) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    late List<Revenue>? revenueList;

    var res = await makeRequest(
        url: Url.DASHBOARD_COLLECTION_TABLE_DATA,
        method: RequestType.POST,
        requestInfo:  RequestInfo(
          APIConstants.API_MODULE_NAME,
          APIConstants.API_VERSION,
          APIConstants.API_TS,
          "_search",
          APIConstants.API_DID,
          APIConstants.API_KEY,
          APIConstants.API_MESSAGE_ID,
          commonProvider.userDetails!.accessToken,
        ),
        body: {'userInfo': commonProvider.userDetails?.userRequest?.toJson()},
        queryParameters: queryParams
    );
    if(res!=null){
      revenueList = res['RevenueCollectionData']
          .map<Revenue>((e) => Revenue.fromJson(e))
          .toList();
    }
    return revenueList;
  }

  Future<List<Expense>?> fetchExpenseDetails(Map<String, dynamic> queryParams) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    late List<Expense>? expenseList;

    var res = await makeRequest(
        url: Url.DASHBOARD_EXPENSE_TABLE_DATA,
        method: RequestType.POST,
        requestInfo:  RequestInfo(
          APIConstants.API_MODULE_NAME,
          APIConstants.API_VERSION,
          APIConstants.API_TS,
          "_search",
          APIConstants.API_DID,
          APIConstants.API_KEY,
          APIConstants.API_MESSAGE_ID,
          commonProvider.userDetails!.accessToken,
        ),
        body: {'userInfo': commonProvider.userDetails?.userRequest?.toJson()},
        queryParameters: queryParams
    );
    if(res!=null){
      expenseList = res['ChallanCollectionData']
          .map<Expense>((e) => Expense.fromJson(e))
          .toList();
    }
    return expenseList;
  }

  Future<RevenueGraph?> getGraphicalDashboard(Map<dynamic, dynamic> body) async {
    RevenueGraph? revenueGraph;

    var res = await makeRequest(
      url: Url.GRAPHICAL_DASHBOARD,
      method: RequestType.POST,
      body: body,
    );
    if (res != null) {
      revenueGraph = RevenueGraph.fromJson(res['responseData']);
    }
    return revenueGraph;
  }

}
