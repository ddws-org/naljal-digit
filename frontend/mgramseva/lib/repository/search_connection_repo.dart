import 'package:mgramseva/model/connection/water_connections.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

class SearchConnectionRepository extends BaseService {
  late WaterConnections waterConnections;
  Future<WaterConnections> getconnection(Map<String, dynamic> query) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    final requestInfo = RequestInfo(
      APIConstants.API_MODULE_NAME,
      APIConstants.API_VERSION,
      APIConstants.API_TS,
      "_search",
      APIConstants.API_DID,
      APIConstants.API_KEY,
      APIConstants.API_MESSAGE_ID,
      commonProvider.userDetails!.accessToken,
      commonProvider.userDetails?.userRequest?.toJson(),
    );
    var res = await makeRequest(
        url: Url.FETCH_WC_CONNECTION,
        queryParameters: query,
        method: RequestType.POST,
        body: {},
        requestInfo: requestInfo);

    if (res != null) {
      waterConnections = WaterConnections.fromJson(res);
    }
    return waterConnections;
  }

  Future<WaterConnections> getConnectionName(Map<String, dynamic> query) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    final requestInfo = RequestInfo(
      APIConstants.API_MODULE_NAME,
      APIConstants.API_VERSION,
      APIConstants.API_TS,
      "_search",
      APIConstants.API_DID,
      APIConstants.API_KEY,
      APIConstants.API_MESSAGE_ID,
      commonProvider.userDetails!.accessToken,
      commonProvider.userDetails?.userRequest?.toJson(),
    );
    var res = await makeRequest(
        url: Url.FETCH_CONNECTION_NAME,
        queryParameters: query,
        method: RequestType.POST,
        body: {},
        requestInfo: requestInfo);

    if (res != null) {
      waterConnections = WaterConnections.fromJson(res);
    }
    return waterConnections;
  }

  Future<WaterConnections> getNonDemandGeneratedWC(Map<String, dynamic> query) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    final requestInfo = RequestInfo(
      APIConstants.API_MODULE_NAME,
      APIConstants.API_VERSION,
      APIConstants.API_TS,
      "_search",
      APIConstants.API_DID,
      APIConstants.API_KEY,
      APIConstants.API_MESSAGE_ID,
      commonProvider.userDetails!.accessToken,
      commonProvider.userDetails?.userRequest?.toJson(),
    );
    var res = await makeRequest(
        url: Url.WATER_CONNECTION_DEMAND_NOT_GENERATED,
        queryParameters: query,
        method: RequestType.POST,
        body: {},
        requestInfo: requestInfo);

    if (res != null) {
      waterConnections = WaterConnections.fromJson(res);
    }
    return waterConnections;
  }



}
