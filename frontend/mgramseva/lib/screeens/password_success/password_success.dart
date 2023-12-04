import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/widgets/button.dart';
import 'package:mgramseva/widgets/desktop_view.dart';
import 'package:mgramseva/widgets/logo.dart';
import 'package:mgramseva/widgets/mobile_view.dart';
import 'package:mgramseva/widgets/success_page.dart';
import 'package:flutter/material.dart';

class PasswordSuccess extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _PasswordSuccessState();
  }
}

class _PasswordSuccessState extends State<PasswordSuccess> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 760) {
        return MobileView(getLoginCard());
      } else {
        return DesktopView(getLoginCard());
      }
    }));
  }

  Widget getLoginCard() {
    return Card(
        child: (Column(
      children: [
        Logo(),
        SuccessPage(
          i18.password.CHANGE_PASSWORD_SUCCESS,
        ),
        Align(
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.only(left: 20, bottom: 20, top: 20),
              child: Text(
                  ApplicationLocalizations.of(context)
                      .translate(i18.password.CHANGE_PASSWORD_SUCCESS_SUBTEXT),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            )),
        Padding(
            padding: EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 8),
            child: Button(
                i18.common.CONTINUE_TO_LOGIN,
                () => Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.LOGIN, (Route<dynamic> route) => false))),
      ],
    )));
  }
}
