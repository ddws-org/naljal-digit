import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class BuildTableText extends StatelessWidget {
  final labelText;
  final labelValue;
  BuildTableText(this.labelText, this.labelValue);
  @override
  Widget build(BuildContext context) {
    var textLabelWidget = Text(
        '${ApplicationLocalizations.of(context).translate(labelText)}',
        textAlign: TextAlign.left,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColorDark));
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
          margin:
              const EdgeInsets.only(top: 5.0, bottom: 5, right: 20, left: 20),
          child: Row(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width / 3,
                  padding: EdgeInsets.only(top: 18, bottom: 3),
                  child: new Align(
                      alignment: Alignment.centerLeft, child: textLabelWidget)),
              Container(
                  width: MediaQuery.of(context).size.width / 2.2,
                  padding: EdgeInsets.only(top: 18, bottom: 3),
                  child: Column(
                    children: [
                      new Align(
                          alignment: Alignment.centerLeft,
                          child: Text(labelValue,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColorDark))),
                    ],
                  )),
            ],
          ));
    });
  }
}
