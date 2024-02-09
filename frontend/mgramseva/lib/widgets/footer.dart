import 'package:flutter/material.dart';
import 'package:mgramseva/env/app_config.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:provider/provider.dart';

import '../providers/language.dart';
import '../utils/global_variables.dart';

class Footer extends StatelessWidget {
  final EdgeInsets? padding;
  Footer({this.padding});
  @override
  Widget build(BuildContext context) {
    var languageProvider =
    Provider.of<LanguageProvider>(navigatorKey.currentContext!, listen: false);
    return Container(
      padding: padding ?? EdgeInsets.all(25),
      child: Image(
          width: 140,
          image: NetworkImage(
            languageProvider.stateInfo?.digitFooterColor??'',
          )),
    );
  }
}
