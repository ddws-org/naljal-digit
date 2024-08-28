import 'dart:typed_data';

import 'package:mgramseva/utils/printer/image_utils.dart';

import 'package:flutter/material.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:mgramseva/utils/printer/esc_pos_utils_platform/esc_pos_utils_platform.dart';

import 'localization/application_localizations.dart';

class PrintBluetooth {
  static bool connected = false;

  static setConnect(String mac, value, context) async {
    if (connected) {
      PrintBluetooth.printTicket(value, context);
      Navigator.of(context).pop();
    } else {
      final result =
          await PrintBluetoothThermal.connect(macPrinterAddress: mac);

      if (result) {
        connected = true;
        PrintBluetooth.printTicket(value, context);
        Navigator.of(context).pop();
      }
    }
  }

  static Future<void> showMyDialog(context, value) async {
    connected = false;
    Widget setupAlertDialogContainer(
        List<BluetoothInfo> availableBluetoothDevices, context) {
      return Container(
        height: 300.0, // Change as per your requirement
        width: 300.0,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: availableBluetoothDevices.length > 0
              ? availableBluetoothDevices.length
              : 0,
          itemBuilder: (context, index) {
            return ListTile(
              onTap: () {
                String select = availableBluetoothDevices[index].macAdress;
                setConnect(select, value, context);
              },
              title: Text('${availableBluetoothDevices[index].name}'),
              subtitle: Text(ApplicationLocalizations.of(context)
                  .translate(i18.consumerReciepts.CLICK_TO_CONNECT)),
            );
          },
        ),
      );
    }

    final List<BluetoothInfo> availableBluetoothDevices =
        await PrintBluetoothThermal.pairedBluetooths;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(ApplicationLocalizations.of(context)
              .translate(i18.consumerReciepts.CONNECT_TO_DEVICE)),
          content:
              setupAlertDialogContainer(availableBluetoothDevices, context),
          actions: <Widget>[
            TextButton(
              child: Text(ApplicationLocalizations.of(context)
                  .translate(i18.consumerReciepts.CLOSE)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> printTicket(value, context) async {
    bool? isPermissionGranted =
        await PrintBluetoothThermal.isPermissionBluetoothGranted;
    print(isPermissionGranted);
    if (!isPermissionGranted) {
      await Permission.bluetooth.request();
      await Permission.bluetoothScan.request();
      await Permission.location.request();
      await Permission.bluetoothConnect.request();
    }
    bool? isConnected = await PrintBluetoothThermal.connectionStatus;
    if (isConnected) {
      List<int> bytes = await getTicket(value);
      final result = await PrintBluetoothThermal.writeBytes(bytes);
    } else {
      PrintBluetooth.showMyDialog(context, value);
      print(ApplicationLocalizations.of(context)
          .translate(i18.consumerReciepts.CONNECTION_NOT_ESTABLISHED));
    }
  }

  static Future<List<int>> getTicket(value) async {

    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    final Uint8List imageBytes = value;
    final decodedImage = img.decodeImage(imageBytes)!;
    img.Image thumbnail = img.copyResize(decodedImage,width: PaperSize.mm58.width,maintainAspect: false,);
    // creates a copy of the original image with set dimensions
    img.Image originalImg = img.copyResize(decodedImage, width: PaperSize.mm58.width,maintainAspect: false, );
    // fills the original image with a white background
    img.fill(originalImg, color: img.ColorRgb8(255, 255, 255));
    // var padding = (originalImg.width - thumbnail.width) / 2;
    //
    // //insert the image inside the frame and center it
    drawImage(originalImg, thumbnail, dstX: 0);
    // ticket.feed(2);
    bytes += generator.feed(1);
    bytes += generator.imageRaster(originalImg, align: PosAlign.center);
    bytes += generator.feed(1);
    bytes += generator.cut();
    return bytes;
  }
}
