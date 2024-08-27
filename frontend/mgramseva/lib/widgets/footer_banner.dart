import 'package:flutter/material.dart';
import 'package:mgramseva/env/app_config.dart';
import 'package:mgramseva/utils/constants.dart';

class FooterBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Image(
            width: 140,
            image: NetworkImage(
              "$apiBaseUrl${Constants.DIGIT_FOOTER_WHITE_ENDPOINT}",
            )),
      ),
    );
  }
}
