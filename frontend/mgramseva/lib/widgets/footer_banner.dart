import 'package:flutter/material.dart';
import 'package:mgramseva/env/app_config.dart';
import 'package:mgramseva/utils/constants.dart';

class FooterBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 25),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Image(
            image: NetworkImage(
          "$apiBaseUrl${Constants.NALJAL_FOOTER_WHITE_ENDPOINT}",
        )),
      ),
    );
  }
}
