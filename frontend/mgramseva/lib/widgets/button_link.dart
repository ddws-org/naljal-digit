import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class ButtonLink extends StatelessWidget {
  final String label;
  final Function()? widgetFunction;
  ButtonLink(this.label, this.widgetFunction);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: widgetFunction,
      child: Padding(
          padding: const EdgeInsets.only(
              left: 8, top: 10, bottom: 10, right: 25),
          child: new Align(
              alignment: Alignment.centerLeft,
              child: Text(
                ApplicationLocalizations.of(context)
                    .translate(label),
                style: TextStyle(
                    color: Theme.of(context).primaryColor),
              ))),
    );
  }
}
