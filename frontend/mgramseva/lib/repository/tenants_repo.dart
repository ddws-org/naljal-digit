import 'package:mgramseva/model/mdms/tenants.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

class TenantRepo extends BaseService {
  Future<Tenant> fetchTenants(Map body, [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    late Tenant tenant;
    final requestInfo = RequestInfo('mGramSeva', .01, "", "search", "", "", "",
       token ?? commonProvider.userDetails!.accessToken);
    var res = await makeRequest(
        url: Url.MDMS,
        body: body,
        requestInfo: requestInfo,
        method: RequestType.POST);
    if (res != null) {
      tenant = Tenant.fromJson(res['MdmsRes']['tenant']);
    }
    return tenant;
  }
}
