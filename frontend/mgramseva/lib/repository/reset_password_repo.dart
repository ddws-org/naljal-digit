import 'package:mgramseva/model/reset_password/reset_password.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

class ResetPasswordRepository extends BaseService {
  Future<ResetPasswordDetails> forgotPassword(Map body, context,
      [String? token]) async {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        "create",
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        token ?? commonProvider.userDetails?.accessToken);
    late ResetPasswordDetails resetPasswordDetails;
    var res = await makeRequest(
        url: UserUrl.RESET_PASSWORD,
        body: body,
        requestInfo: requestInfo,
        method: RequestType.POST);
    if (res != null) {
      resetPasswordDetails = ResetPasswordDetails.fromJson(res);
    }
    return resetPasswordDetails;
  }
}
