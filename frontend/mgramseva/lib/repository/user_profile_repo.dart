import 'package:mgramseva/model/user_profile/user_profile.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

class UserProfileRepository extends BaseService {
  Future<UserProfile> getProfile(Map body) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        "POST",
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails!.accessToken);
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
