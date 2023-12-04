import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class ListLabelText extends StatelessWidget {
  final input;
  final TextStyle? style;
  ListLabelText(this.input, {this.style});
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            ApplicationLocalizations.of(context).translate(input),
            style: style ?? TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            textAlign: TextAlign.left,
          ),
        )));
  }
}
