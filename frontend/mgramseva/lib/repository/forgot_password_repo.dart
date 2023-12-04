import 'package:mgramseva/model/forgot_password/forgot_password.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';

class ForgotPasswordRepository extends BaseService {
  Future<ForgotPasswordOTP> forgotPassword(
    Map body,
    context,
  ) async {
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        "_search",
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        null);
    late ForgotPasswordOTP forgotPasswordOTP;
    var res = await makeRequest(
        url: UserUrl.OTP_RESET_PASSWORD,
        body: body,
        requestInfo: requestInfo,
        method: RequestType.POST);
    if (res != null) {
      forgotPasswordOTP = ForgotPasswordOTP.fromJson(res);
    }
    return forgotPasswordOTP;
  }
}
