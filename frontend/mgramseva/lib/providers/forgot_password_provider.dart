import 'package:flutter/material.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/repository/forgot_password_repo.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:provider/provider.dart';

class ForgotPasswordProvider with ChangeNotifier {
  otpForResetPassword(BuildContext context, String mobileNumber) async {
    /// Unfocus the text field
    FocusScope.of(context).unfocus();

    try {
      var languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      var body = {
        "otp": {
          "mobileNumber": mobileNumber,
          "tenantId": languageProvider.stateInfo!.code,
          "type": "passwordreset",
          "locale": languageProvider.selectedLanguage?.value,
          "userType": "Employee"
        }
      };

      Loaders.showLoadingDialog(context);

      var otpResponse =
          await ForgotPasswordRepository().forgotPassword(body, context);
      Navigator.pop(context);

      Navigator.of(context)
          .pushNamed(Routes.RESET_PASSWORD, arguments: {"id": mobileNumber});
        } catch (e, s) {
      Navigator.pop(context);
      ErrorHandler().allExceptionsHandler(context, e, s);
    }
  }

  void callNotifier() {
    notifyListeners();
  }
}
