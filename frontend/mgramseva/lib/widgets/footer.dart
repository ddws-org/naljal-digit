import 'package:flutter/material.dart';
import 'package:mgramseva/env/app_config.dart';
import 'package:mgramseva/utils/constants.dart';

class Footer extends StatelessWidget {
  final EdgeInsets? padding;
  Footer({this.padding});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(25),
      child: Image(
          width: 140,
          image: NetworkImage(
            "$apiBaseUrl${Constants.DIGIT_FOOTER_ENDPOINT}",
          )),
    );
  }
}
