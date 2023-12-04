import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/providers/language.dart';

import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' hide Text;

class LanguageCard extends StatelessWidget {
  // final String text;
  // final String value;
  final Languages language;
  final List<Languages> languages;
  final double widthRect;
  final double cPadding;
  final double cMargin;

  LanguageCard(this.language, this.languages, this.widthRect, this.cPadding,
      this.cMargin);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      var value = window.localStorage['SelectedLocal'];
      if (value == language.value) {
        this.language.isSelected = true;
      }
    }
    return Consumer<LanguageProvider>(
      builder: (_, languageProvider, child) => GestureDetector(
        onTap: () {
          languageProvider.onSelectionOfLanguage(language, languages);
        },
        child: Container(
            margin: new EdgeInsets.all(cMargin),
            width: widthRect,
            padding: new EdgeInsets.all(cPadding),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: language.isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.white),
            child: Center(
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
              '${language.label}',
              style: new TextStyle(
                    fontWeight: FontWeight.w400,
                    color: language.isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColorDark),
            )))),
      ),
    );
  }
}
