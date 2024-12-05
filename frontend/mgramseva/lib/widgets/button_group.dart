import 'package:flutter/material.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

import 'short_button.dart';

class ButtonGroup extends StatelessWidget {
  final String label;
  final VoidCallback? callBack;
  final VoidCallback callBackIcon;
  ButtonGroup(
    this.label,
    this.callBackIcon,
    this.callBack,
  );
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,
            width: constraints.maxWidth > 760
                ? MediaQuery.of(context).size.width / 2
                : MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          height: 48,
                            child: OutlinedButton.icon(
                          onPressed: callBackIcon,
                          style: ElevatedButton.styleFrom(padding:EdgeInsets.symmetric(vertical: 5),alignment: Alignment.center,side:BorderSide(
                              width: 1,
                              color: Theme.of(context).disabledColor),
                            ),
                          icon: (Image.asset('assets/png/whats_app.png', fit: BoxFit.fitHeight,)),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Text(
                                ApplicationLocalizations.of(context)
                                    .translate(i18.common.SHARE_BILL_PDF),
                                style: Theme.of(context).textTheme.titleSmall)),
                        )),
                      ),
                      Expanded(child: ShortButton(label, callBack))
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      );
    });
  }
}
