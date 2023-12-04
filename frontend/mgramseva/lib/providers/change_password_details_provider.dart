import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/change_password_details/change_password_details.dart';
import 'package:mgramseva/repository/change_password_details_repo.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';

class ChangePasswordProvider with ChangeNotifier {
  var formKey = GlobalKey<FormState>();
  var autoValidation = false;
  var changePasswordDetails = ChangePasswordDetails();

  Future<void> changePassword(body, BuildContext context) async {
    try {
      Loaders.showLoadingDialog(context);

      var changePasswordResponse = await ChangePasswordRepository().updatePassword(body);
      Navigator.pop(context);
      Notifiers.getToastMessage(
          context, i18.password.CHANGE_PASSWORD_SUCCESS, 'SUCCESS');
      new Future.delayed(const Duration(seconds: 5),
          () => Navigator.pop(context),
      );

        } catch (e, s) {
      Navigator.pop(context);
      ErrorHandler().allExceptionsHandler(context, e, s);
    }
  }

  callNotifier() {
    notifyListeners();
  }
}
