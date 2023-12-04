import 'package:flutter/material.dart';

import 'localization/application_localizations.dart';
import 'common_styles.dart';

class CommonWidgets {

  Widget buildHint(String? label, BuildContext context) {
    return Visibility(
        visible: label != null,
        child: Container(
             padding: EdgeInsets.symmetric(vertical: 5),
            alignment: Alignment.centerLeft,
            child: Text('${ApplicationLocalizations.of(context).translate(label ?? '')}', style: CommonStyles.hintStyle)));
  }

  static Widget buildEmptyMessage(String label, BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text('${ApplicationLocalizations.of(context).translate(label)}', style: Theme.of(context).textTheme.titleMedium),
    );
  }
}