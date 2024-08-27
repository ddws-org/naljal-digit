import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_styles.dart';

class Button extends StatelessWidget {
  final String label;
  final Function()? widgetFunction;
  final Key? key;
  Button(this.label, this.widgetFunction, {this.key});

  @override
  Widget build(BuildContext context) {
    return new FractionallySizedBox(
        child: Container(
          decoration: CommonStyles.buttonBottomDecoration,
          child: new ElevatedButton(
              style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), backgroundColor: widgetFunction != null ? Color.fromRGBO(244, 119, 56, 1) : Color.fromRGBO(244, 119, 56, 0.7)
                // padding: EdgeInsets.all(15),
              ),
              child: new Text(ApplicationLocalizations.of(context).translate(label),
                  style: Theme.of(context).textTheme.labelLarge),
              onPressed: () => widgetFunction != null ? widgetFunction!() : null
          ),
        ));
  }
}