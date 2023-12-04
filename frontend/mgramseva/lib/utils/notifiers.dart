import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/widgets/toast/toster.dart';

class Notifiers {
  static getToastMessage(BuildContext context, String message, type) {
    ToastUtils.showCustomToast(
        context, ApplicationLocalizations.of(context).translate(message), type);
  }

  static Widget networkErrorPage(context, VoidCallback callBack) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Unable to connect to the server",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(244, 119, 56, 0.7)
              ),
              onPressed: callBack,
              child: Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }
}
