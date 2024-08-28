import 'package:mgramseva/model/transaction/transaction.dart';
import 'package:mgramseva/model/bill/bill_payments.dart';
import 'package:mgramseva/model/common/demand.dart';
import 'package:mgramseva/model/common/fetch_bill.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

class ConsumerRepository extends BaseService {
  getRequestInfo(String criteria) {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    return RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        criteria,
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails!.accessToken);
  }

  //Add Property API
  Future addProperty(Map body) async {
    var res = await makeRequest(
        url: Url.ADD_PROPERTY,
        body: {"Property": body},
        method: RequestType.POST,
        requestInfo: getRequestInfo('_create'));
    return res;
  }

  //Update Property API
  Future updateProperty(Map body) async {
    var res = await makeRequest(
        url: Url.UPDATE_PROPERTY,
        body: {"Property": body},
        method: RequestType.POST,
        requestInfo: getRequestInfo('_update'));
    return res;
  }

//Adding Water Connection
  Future addconnection(Map body) async {
    var res = await makeRequest(
        url: Url.ADD_WC_CONNECTION,
        body: {"WaterConnection": body},
        method: RequestType.POST,
        requestInfo: getRequestInfo('_create'));
    return res;
  }

  //Update Water Connection
  Future updateconnection(Map body) async {
    var res = await makeRequest(
        url: Url.UPDATE_WC_CONNECTION,
        body: {"WaterConnection": body},
        method: RequestType.POST,
        requestInfo: getRequestInfo('_update'));
    return res;
  }

//Fetching of Property
  Future getProperty(Map<String, dynamic> query) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    var body = {'userInfo': commonProvider.userDetails?.userRequest?.toJson()};

    var res = await makeRequest(
        url: Url.GET_PROPERTY,
        body: body,
        queryParameters: query,
        method: RequestType.POST,
        requestInfo: getRequestInfo('_search'));
    return res;
  }

  //Getting LocationDetails
  Future getLocations(Map body) async {
    var res = await makeRequest(
        url: Url.EGOV_LOCATIONS,
        queryParameters: body.map((key, value) =>
            MapEntry(key, value == null ? null : value.toString())),
        method: RequestType.POST,
        requestInfo: getRequestInfo('_search'));
    return res;
  }

  Future<List<FetchBill>?> getBillDetails(Map<String, dynamic> query) async {
    List<FetchBill>? fetchBill;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var body = {'userInfo': commonProvider.userDetails?.userRequest?.toJson()};

    var res = await makeRequest(
      url: Url.FETCH_BILL,
      method: RequestType.POST,
      queryParameters: query,
      body: {'RequestInfo': {}},
    );

    if (res != null) {
      fetchBill =
          res['Bill']?.map<FetchBill>((e) => FetchBill.fromJson(e)).toList();
    }
    return fetchBill;
  }

  Future<List<Demand>?> getDemandDetails(Map<String, dynamic> query) async {
    List<Demand>? demand;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var body = {'userInfo': commonProvider.userDetails?.userRequest?.toJson()};

    var res = await makeRequest(
        url: Url.FETCH_DEMAND,
        method: RequestType.POST,
        body: body,
        queryParameters: query,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            commonProvider.userDetails!.accessToken,
            {'userInfo': commonProvider.userDetails?.userRequest?.toJson()}));

    if (res != null) {
      demand = res['Demands']?.map<Demand>((e) => Demand.fromJson(e)).toList();
    }
    return demand;
  }

  Future<BillPayments?> collectPayment(Map body) async {
    BillPayments? response;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var res = await makeRequest(
        url: Url.COLLECT_PAYMENT,
        method: RequestType.POST,
        body: body,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            commonProvider.userDetails!.accessToken));

    if (res != null) {
      response = BillPayments.fromJson(res);
    }
    return response;
  }

  Future<TransactionDetails?> createTransaction(Map body) async {
    TransactionDetails? response;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var res = await makeRequest(
        url: Url.CREATE_TRANSACTION,
        method: RequestType.POST,
        body: body,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            null));

    if (res != null) {
      response = TransactionDetails.fromJson(res);
    }
    return response;
  }
}
