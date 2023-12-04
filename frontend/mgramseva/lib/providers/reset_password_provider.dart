import 'package:flutter/material.dart';
import 'package:mgramseva/repository/reset_password_repo.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/custom_exception.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:provider/provider.dart';

import 'common_provider.dart';

class ResetPasswordProvider with ChangeNotifier {
  resetpassword(BuildContext context, String otp1, String otp2, String otp3,
      String otp4, String newPassword) async {
    /// Unfocus the text field
    FocusScope.of(context).unfocus();
    Loaders.showLoadingDialog(context);

    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      var body = {
        "otpReference": otp1 + otp2 + otp3 + otp4,
        "userName": commonProvider.userDetails!.userRequest!.userName,
        "newPassword": newPassword,
        "tenantId": commonProvider.userDetails!.userRequest!.tenantId,
        "type": commonProvider.userDetails!.userRequest!.type
      };

          await ResetPasswordRepository().forgotPassword(body, context);
      Navigator.pushNamedAndRemoveUntil(
          context, Routes.LOGIN, (route) => false);
    } on CustomException catch (e, s) {
      Navigator.pop(context);

      if (ErrorHandler.handleApiException(context, e, s)) {
        Notifiers.getToastMessage(context, e.message, 'ERROR');
      }
    } catch (e, s) {
      Notifiers.getToastMessage(context, e.toString(), 'ERROR');
      ErrorHandler.logError(e.toString(), s);
      Navigator.pop(context);
    }
  }

  void callNotifyer() {
    notifyListeners();
  }
}
