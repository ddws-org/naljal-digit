import 'dart:async';
import 'package:mgramseva/model/user_profile/user_profile.dart';
import 'package:mgramseva/repository/user_edit_profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:provider/provider.dart';

import 'common_provider.dart';

class UserEditProfileProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();

  dispose() {
    streamController.close();
    super.dispose();
  }

  Future<void> editUserProfileDetails(body, BuildContext context) async {
    try {
      Loaders.showLoadingDialog(context);

      var edituserResponse =
          await UserEditProfileRepository().editProfile(body);
      Navigator.pop(context);
      Notifiers.getToastMessage(
          context, i18.profileEdit.PROFILE_EDIT_SUCCESS, 'SUCCESS');
      streamController.add(edituserResponse);
      if(edituserResponse.user?.isNotEmpty ?? false) {
        Provider.of<CommonProvider>(context, listen: false)
          ..userDetails?.userRequest?.name = edituserResponse.user?.first.name
          ..userDetails?.userRequest?.emailId = edituserResponse.user?.first
              .emailId
        ..loginCredentials = Provider.of<CommonProvider>(context, listen: false).userDetails;
      }
      Navigator.pop(context);
        } catch (e, s) {
      Navigator.pop(context);
      ErrorHandler().allExceptionsHandler(context, e, s);
    }
  }

  Future<void> getEditUser() async {
    try {
      streamController.add(User());
    } catch (e) {
      streamController.addError('error');
    }
  }

  void onChangeOfGender(String gender, User user) {
    user.gender = gender;
    notifyListeners();
  }
}
