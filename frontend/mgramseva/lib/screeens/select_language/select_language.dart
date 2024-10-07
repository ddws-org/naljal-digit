import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/screeens/select_language/language_selection_desktop_view.dart';
import 'package:mgramseva/screeens/select_language/language_select_mobile_view.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:provider/provider.dart';
import 'package:safe_device/safe_device.dart';

// ignore: must_be_immutable
class SelectLanguage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SelectLanguage();
}

class _SelectLanguage extends State<SelectLanguage> {
  bool isDeviceSafe = true;

  @override
  void initState() {
    super.initState();
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.getLocalizationData(context);
     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(!kIsWeb){
      _checkDeviceSafety();
      }

    });
  }


  Future<void> _checkDeviceSafety() async {
    bool isDeviceRooted = await SafeDevice.isJailBroken;
    bool isDeviceEmulator = await SafeDevice.isRealDevice;


    setState(() {
      if(isDeviceEmulator){
        isDeviceSafe = false;
      }else if(isDeviceRooted){
        isDeviceSafe = false;
      }else{
        isDeviceSafe = true;
      }

      log("${isDeviceEmulator} isDeviceEmulator");
      log("${isDeviceSafe} isDeviceSafe");
      log("${isDeviceRooted} isDeviceRooted");

      if(isDeviceSafe){      
        Navigator.of(context)
    .pushNamedAndRemoveUntil(Routes.SECURITY_CHECK, (Route<dynamic> route) => false);
      }
    });
    
  }


  @override
  Widget build(BuildContext context) {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return Scaffold(
        body: StreamBuilder(
            stream: languageProvider.streamController.stream,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return _buildView(snapshot.data);
              } else if (snapshot.hasError) {
                return Notifiers.networkErrorPage(context,
                    () => languageProvider.getLocalizationData(context));
              } else {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Loaders.circularLoader();
                  case ConnectionState.active:
                    return Loaders.circularLoader();
                  default:
                    return Container();
                }
              }
            }));
  }

  Widget _buildView(List<StateInfo> stateList) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 760) {
        return LanguageSelectMobileView(stateList.first);
      } else {
        return LanguageSelectionDesktopView(stateList.first, () {});
      }
    });
  }
}
