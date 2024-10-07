import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_device/safe_device.dart';

class UnsafeDeviceDialog extends StatefulWidget {
  const UnsafeDeviceDialog({Key? key}) : super(key: key);

  @override
  _UnsafeDeviceDialogState createState() => _UnsafeDeviceDialogState();
}

class _UnsafeDeviceDialogState extends State<UnsafeDeviceDialog> {
  bool isDeviceSafe = true;

  @override
  void initState() {
    super.initState();
    if(!kIsWeb){
    _checkDeviceSafety();}
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
    });
    // Show the popup dialog if the device is unsafe
    if (isDeviceSafe) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Device Security Warning'),
          content: const Text(
              'This device is not safe to use this app. It is either rooted, an emulator, or has been tampered with.'),
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
  }


  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // Hide the dialog if the device is safe
  }
}


