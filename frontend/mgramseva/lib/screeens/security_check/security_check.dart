import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

class UnsafeDeviceDialog extends StatefulWidget {
  const UnsafeDeviceDialog({Key? key}) : super(key: key);

  @override
  _UnsafeDeviceDialogState createState() => _UnsafeDeviceDialogState();
}

class _UnsafeDeviceDialogState extends State<UnsafeDeviceDialog> {
  bool isDeviceSafe = true;
  bool? _jailbroken;

  @override
  void initState() {
    super.initState();

    if(!kIsWeb){
            rootcheck();
    _checkDeviceSafety();}
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


  

  Future<void> _checkDeviceSafety() async {
 bool isDeviceEmulator = false;
    var deviceInfo = DeviceInfoPlugin();

     if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      isDeviceEmulator = iosDeviceInfo.isPhysicalDevice; 
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
        isDeviceSafe = false;

      }
      else if(_jailbroken! == false){
        isDeviceSafe = true;
      }

    // Show the popup dialog if the device is unsafe
    if (isDeviceSafe) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Device Security Warning'),
          content:  Text(
              ' This device is not safe to use this app. It is either rooted, an emulator, or has been tampered with.'),
          actions: [
            TextButton(
              onPressed: () {

                if(Platform.isAndroid){
                  SystemNavigator.pop();
                }
                if(Platform.isIOS){
                  exit(0);
                }

              },
              child: const Text('Close App'),
            ),
          ],
        ),
      );
    }
    });
  }


  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Hide the dialog if the device is safe
  }
}


