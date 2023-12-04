import 'package:mgramseva/model/user/user_details.dart';
import 'package:mgramseva/model/user_profile/user_profile.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';

class AuthenticationRepository extends BaseService {
  Future<UserDetails> validateLogin(
      Map body, Map<String, String> headers) async {
    late UserDetails loginResponse;

    var res = await makeRequest(
        url: UserUrl.AUTHENTICATE,
        body: body,
        headers: headers,
        method: RequestType.POST);
    if (res != null) {
      loginResponse = UserDetails.fromJson(res);
    }
    return loginResponse;
  }

  Future<UserProfile> getProfile(Map body, String token) async {
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        "POST",
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        token);
    late UserProfile userProfile;
    var res = await makeRequest(
        url: UserUrl.USER_PROFILE,
        body: body,
        requestInfo: requestInfo,
        method: RequestType.POST);
    if (res != null) {
      userProfile = UserProfile.fromJson(res);
      userProfile.user![0].setText();
    }
    return userProfile;
  }
}
