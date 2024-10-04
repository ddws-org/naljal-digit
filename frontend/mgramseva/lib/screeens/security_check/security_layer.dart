import 'package:flutter/material.dart';
import 'package:mgramseva/screeens/security_check/security_check.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/widgets/footer_banner.dart';
import 'package:mgramseva/widgets/heading_text.dart';
import 'package:mgramseva/widgets/logo.dart';

class SecurityLayer extends StatefulWidget {
  const SecurityLayer({Key? key}) : super(key: key);

  @override
  State<SecurityLayer> createState() => _SecurityLayerState();
}

class _SecurityLayerState extends State<SecurityLayer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [                            
          UnsafeDeviceDialog(),        
        ],
      ),     
    );
  }
}