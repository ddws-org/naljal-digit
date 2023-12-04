import 'package:mgramseva/model/expenses_details/expenses_details.dart';
import 'package:mgramseva/model/expenses_details/vendor.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

class ExpensesRepository extends BaseService {
  Future<Map> addExpenses(Map body, bool isUpdate) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var res = await makeRequest(
        url: isUpdate ? Url.UPDATE_EXPENSE : Url.ADD_EXPENSES,
        body: body,
        method: RequestType.POST,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "create",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            commonProvider.userDetails!.accessToken,
            commonProvider.userDetails?.userRequest?.toJson()));
    return res;
  }

  Future<List<Vendor>?> getVendor(Map<String, dynamic> query) async {
    List<Vendor>? vendorList;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var body = {'userInfo': commonProvider.userDetails?.userRequest?.toJson()};

    var res = await makeRequest(
        url: Url.VENDOR_SEARCH,
        body: body,
        queryParameters: query,
        method: RequestType.POST,
        requestInfo: RequestInfo(
          APIConstants.API_MODULE_NAME,
          APIConstants.API_VERSION,
          APIConstants.API_TS,
          "create",
          APIConstants.API_DID,
          APIConstants.API_KEY,
          APIConstants.API_MESSAGE_ID,
          commonProvider.userDetails!.accessToken,
        ));

    if (res != null && res['vendor'] != null) {
      vendorList =
          res['vendor'].map<Vendor>((e) {
            if(e!=null){
              if(e['owner']==null){
                e['owner']={
                  'mobileNumber':''
                };
              }
            }
            return Vendor.fromJson(e);
          }).toList();
    }
    return vendorList;
  }

  Future<List<ExpensesDetailsModel>?> searchExpense(
      Map<String, dynamic> query) async {
    List<ExpensesDetailsModel>? expenseResult;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var body = {'userInfo': commonProvider.userDetails?.userRequest?.toJson()};

    var res = await makeRequest(
        url: Url.EXPENSE_SEARCH,
        queryParameters: query,
        body: body,
        method: RequestType.POST,
        requestInfo: RequestInfo(
          APIConstants.API_MODULE_NAME,
          APIConstants.API_VERSION,
          APIConstants.API_TS,
          "create",
          APIConstants.API_DID,
          APIConstants.API_KEY,
          APIConstants.API_MESSAGE_ID,
          commonProvider.userDetails!.accessToken,
        ));

    if (res != null) {
      expenseResult = res['challans']
          ?.map<ExpensesDetailsModel>((e) => ExpensesDetailsModel.fromJson(e))
          .toList();
    }
    return expenseResult;
  }

  Future<Map?> createVendor(Map body) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var res = await makeRequest(
        url: Url.CREATE_VENDOR,
        body: body,
        method: RequestType.POST,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "create",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            commonProvider.userDetails!.accessToken,
            commonProvider.userDetails?.userRequest?.toJson()));

    if (res != null && res['vendor'] != null && res['vendor'].isNotEmpty) {
      return res['vendor'][0];
    }
    return null;
  }

  Future<ExpensesDetailsWithPagination?> expenseDashboard(
      Map<String, dynamic> query) async {
    ExpensesDetailsWithPagination? expenseResult;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var body = {'userInfo': commonProvider.userDetails?.userRequest?.toJson()};

    var res = await makeRequest(
        url: Url.EXPENSE_SEARCH,
        queryParameters: query,
        body: body,
        method: RequestType.POST,
        requestInfo: RequestInfo(
          APIConstants.API_MODULE_NAME,
          APIConstants.API_VERSION,
          APIConstants.API_TS,
          "create",
          APIConstants.API_DID,
          APIConstants.API_KEY,
          APIConstants.API_MESSAGE_ID,
          commonProvider.userDetails!.accessToken,
        ));

    if (res != null) {
      expenseResult = ExpensesDetailsWithPagination.fromJson(res);
    }
    return expenseResult;
  }
}
