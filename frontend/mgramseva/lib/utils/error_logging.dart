import 'package:flutter/cupertino.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/custom_exception.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:provider/provider.dart';

import 'global_variables.dart';
import 'models.dart';

class ErrorHandler {
  static void logError(String error, [StackTrace? stackTrace]) {
    print(error);
  }

  static bool handleApiException(BuildContext context, CustomException e,
      [StackTrace? stackTrace]) {
    switch (e.exceptionType) {
      case ExceptionType.UNAUTHORIZED:
        if (currentRoute == Routes.LOGIN) {
          return true;
        }
        var commonProvider = Provider.of<CommonProvider>(context,
            listen: false);
        commonProvider.onLogout();
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil(Routes.LOGIN, (route) => false);
        return true;
      case ExceptionType.INVALIDINPUT:
      case ExceptionType.OTHER:
      case ExceptionType.FETCHDATA:
      case ExceptionType.BADREQUEST:
        logError(e.message, stackTrace);
        return true;
      case ExceptionType.CONNECTIONISSUE:
        Notifiers.getToastMessage(context, e.message, 'ERROR');
        return false;
      default:
        return true;
    }
  }

  bool allExceptionsHandler(BuildContext context, dynamic e,
      [StackTrace? stackTrace]) {
    var status = false;
    if (e is CustomException) {
      if (ErrorHandler.handleApiException(context, e, stackTrace)) {
        Notifiers.getToastMessage(context, e.message, 'ERROR');
      }
      status = false;
    } else {
      ErrorHandler.logError(e.toString(), stackTrace);
      Notifiers.getToastMessage(context, e.toString(), 'ERROR');
      status = false;
    }
    return status;
  }
}
