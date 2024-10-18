import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/screeens/select_language/language_selection_desktop_view.dart';
import 'package:mgramseva/screeens/select_language/language_select_mobile_view.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class SelectLanguage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SelectLanguage();
}

class _SelectLanguage extends State<SelectLanguage> {
  bool isDeviceSafe = true;
  bool? _jailbroken;

  @override
  void initState() {
    super.initState();
    
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.getLocalizationData(context);
     WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(!kIsWeb){
        rootcheck();
      _checkDeviceSafety();
      }

    });
  }

    // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> rootcheck() async {
    bool jailbroken;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
    } on PlatformException {
      jailbroken = true;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _jailbroken = jailbroken;
    });
  }


   _checkDeviceSafety() async {
    bool isDeviceEmulator = false;
    bool isDeviceRooted  = false;
    var deviceInfo = DeviceInfoPlugin();

     if (Platform.isIOS) {
      isDeviceRooted = await FlutterJailbreakDetection.jailbroken;
      var iosDeviceInfo = await deviceInfo.iosInfo;
      isDeviceEmulator =iosDeviceInfo.isPhysicalDevice; 
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      isDeviceEmulator =androidDeviceInfo.isPhysicalDevice;
    }

    setState(() {
      if(isDeviceEmulator){
        isDeviceSafe = false;
      }
      if(_jailbroken == null){
        // UNKNOWN      
      }
      else if(_jailbroken!){
        isDeviceRooted = true;
        isDeviceSafe = false;

      }
      else if(_jailbroken! == false){
        isDeviceRooted = false;
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
