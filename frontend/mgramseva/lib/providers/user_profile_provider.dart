import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/user_profile/user_profile.dart';
import 'package:mgramseva/repository/user_profile_repo.dart';
import 'package:mgramseva/utils/error_logging.dart';

class UserProfileProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();
  var formKey = GlobalKey<FormState>();
  var autoValidation = false;
  var profileDetails = User();

  dispose() {
    streamController.close();
    super.dispose();
  }

  Future<void> getUserProfileDetails(body, BuildContext context) async {
    try {
      var userResponse = await UserProfileRepository().getProfile(body);
      streamController.add(userResponse.user?.first);
      profileDetails = userResponse.user!.first;
        } catch (e, s) {
      ErrorHandler().allExceptionsHandler(context, e, s);
      streamController.addError('error');
    }
  }

  void onChangeOfGender(String gender, User user) {
    user.gender = gender;
    notifyListeners();
  }

  void callNotfyer() {
    notifyListeners();
  }
}
