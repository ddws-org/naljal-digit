import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';

class Info extends StatelessWidget {
  final subtext;
  Info(this.subtext);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: Theme.of(context).highlightColor),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(0),
      padding: EdgeInsets.all(5),
      child: (Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Theme.of(context).hintColor),
              Text(ApplicationLocalizations.of(context).translate(i18.generateBillDetails.INFO),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).hintColor))
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Wrap(
              children: [
                Text(
                  subtext,
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).hintColor),
                ),
              ])
        ],
      )),
    );
  }
}
