import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/routers/routers.dart';

import 'package:mgramseva/utils/custom_exception.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:provider/provider.dart';
import '../repository/authentication_repo.dart';
import 'language.dart';

import 'package:mgramseva/services/base_service.dart';

class AuthenticationProvider with ChangeNotifier, BaseService {
  validateLogin(BuildContext context, String userName, String password) async {
    /// Unfocus the text field
    FocusScope.of(context).unfocus();

    try {
      var languageProvider = Provider.of<LanguageProvider>(
          navigatorKey.currentContext!,
          listen: false);
      var body = {
        "username": userName,
        "password": password,
        "scope": "read",
        "grant_type": "password",
        "tenantId": languageProvider.stateInfo!.code,
        "userType": "EMPLOYEE"
      };

      var headers = {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
        "Access-Control-Allow-Origin": "*",
        "authorization": "Basic ZWdvdi11c2VyLWNsaWVudDo=",
      };

      Loaders.showLoadingDialog(context);

      var loginResponse =
          await AuthenticationRepository().validateLogin(body, headers);

      Navigator.pop(context);

      var userInfo = await AuthenticationRepository().getProfile({
        "tenantId": loginResponse.userRequest!.tenantId,
        "id": [loginResponse.userRequest!.id],
        "mobileNumber": loginResponse.userRequest!.mobileNumber
      }, loginResponse.accessToken!);
      var commonProvider = Provider.of<CommonProvider>(context, listen: false);
      loginResponse.isFirstTimeLogin = userInfo.user!.first.defaultPwdChgd;
      commonProvider.loginCredentials = loginResponse;
      if (userInfo.user!.first.defaultPwdChgd == false) {
        commonProvider.userProfile = userInfo;
        Navigator.pushNamed(context, Routes.UPDATE_PASSWORD,
            arguments: loginResponse);
        return;
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.HOME, (Route<dynamic> route) => false);
      }
    } on CustomException catch (e, s) {
      Navigator.pop(context);
      if (ErrorHandler.handleApiException(context, e, s)) {
        Notifiers.getToastMessage(context, e.message, 'ERROR');
      }
    } catch (e, s) {
      Navigator.pop(context);
      ErrorHandler.logError(e.toString(), s);
      Notifiers.getToastMessage(context, e.toString(), 'ERROR');
    }
  }

  void callNotifier() {
    notifyListeners();
  }
}
