import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class SubLabelText extends StatelessWidget {
  final input;
  SubLabelText(this.input);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
            child: Padding(
          padding: constraints.maxWidth > 760 ? const EdgeInsets.all(20.0) : const EdgeInsets.all(8.0),
          child: Text(
            ApplicationLocalizations.of(context).translate(input),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Theme.of(context).primaryColorLight),
            textAlign: TextAlign.left,
          ),
        )));
  });
  }
}
