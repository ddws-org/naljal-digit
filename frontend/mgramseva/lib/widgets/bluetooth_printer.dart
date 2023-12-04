import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thermal_printer/esc_pos_utils_platform/esc_pos_utils_platform.dart';
import 'package:thermal_printer/thermal_printer.dart';
import 'package:image/image.dart' as img;
import '../utils/printer/image_utils.dart';


class BluetoothPrinterScreen extends StatefulWidget {
  final Uint8List imageData;
  const BluetoothPrinterScreen({Key? key, required this.imageData}) : super(key: key);

  @override
  State<BluetoothPrinterScreen> createState() => _BluetoothPrinterScreenState();
}

class _BluetoothPrinterScreenState extends State<BluetoothPrinterScreen> {
  // Printer Type [bluetooth, usb, network]
  var defaultPrinterType = PrinterType.bluetooth;
  var _isBle = false;
  var _reconnect = false;
  var _isConnected = false;
  var printerManager = PrinterManager.instance;
  var devices = <BluetoothPrinter>[];
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<USBStatus>? _subscriptionUsbStatus;
  StreamSubscription<TCPStatus>? _subscriptionTCPStatus;
  BTStatus _currentStatus = BTStatus.none;
  // ignore: unused_field
  TCPStatus _currentTCPStatus = TCPStatus.none;
  // _currentUsbStatus is only supports on Android
  // ignore: unused_field
  USBStatus _currentUsbStatus = USBStatus.none;
  List<int>? pendingTask;
  String _ipAddress = '';
  String _port = '9100';
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  BluetoothPrinter? selectedPrinter;

  @override
  void initState() {
    if (Platform.isWindows) defaultPrinterType = PrinterType.usb;
    super.initState();
    _portController.text = _port;
    _scan();

    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus = PrinterManager.instance.stateBluetooth.listen((status) {
      log(' ----------------- status bt $status ------------------ ');
      _currentStatus = status;
      if (status == BTStatus.connected) {
        setState(() {
          _isConnected = true;
        });
      }
      if (status == BTStatus.none) {
        setState(() {
          _isConnected = false;
        });
      }
      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance.send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });
    //  PrinterManager.instance.stateUSB is only supports on Android
    _subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      log(' ----------------- status usb $status ------------------ ');
      _currentUsbStatus = status;
      if (Platform.isAndroid) {
        if (status == USBStatus.connected && pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance.send(type: PrinterType.usb, bytes: pendingTask!);
            pendingTask = null;
          });
        }
      }
    });

    //  PrinterManager.instance.stateUSB is only supports on Android
    _subscriptionTCPStatus = PrinterManager.instance.stateTCP.listen((status) {
      log(' ----------------- status tcp $status ------------------ ');
      _currentTCPStatus = status;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _subscriptionUsbStatus?.cancel();
    _subscriptionTCPStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  // method to scan devices according PrinterType
  void _scan() {
    devices.clear();
    _subscription = printerManager.discovery(type: defaultPrinterType, isBle: _isBle).listen((device) {
      devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
      setState(() {});
    });
  }

  void setPort(String value) {
    if (value.isEmpty) value = '9100';
    _port = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void setIpAddress(String value) {
    _ipAddress = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  Future<bool> selectDevice(BluetoothPrinter device) async {
    try{
      if (selectedPrinter != null) {
        if ((device.address != selectedPrinter!.address) || (device.typePrinter == PrinterType.usb && selectedPrinter!.vendorId != device.vendorId)) {
          await PrinterManager.instance.disconnect(type: selectedPrinter!.typePrinter);
        }
      }

      selectedPrinter = device;
      setState(() {});
      return true;
    }catch(e){
      return false;
    }
  }

  Future _printReceiveTest() async {
    List<int> bytes = [];

    // Xprinter XP-N160I
    final profile = await CapabilityProfile.load(name: 'XP-N160I');

    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.setGlobalCodeTable('CP1252');


      final Uint8List imageBytes = widget.imageData;
      // decode the bytes into an image
      final decodedImage = img.decodeImage(imageBytes)!;
      // Create a black bottom layer
      // Resize the image to a 130x? thumbnail (maintaining the aspect ratio).
      img.Image thumbnail = img.copyResize(decodedImage,width: PaperSize.mm58.width,maintainAspect: false,);
      // creates a copy of the original image with set dimensions
      img.Image originalImg = img.copyResize(decodedImage, width: PaperSize.mm58.width,maintainAspect: false, );
      // fills the original image with a white background
      img.fill(originalImg, color: img.ColorRgb8(255, 255, 255));
      // var padding = (originalImg.width - thumbnail.width) / 2;
      //
      // //insert the image inside the frame and center it
      drawImage(originalImg, thumbnail, dstX: 0);
      //
      // // convert image to grayscale
      // var grayscaleImage = img.grayscale(originalImg);

      bytes += generator.feed(1);
      // bytes += generator.imageRaster(img.decodeImage(imageBytes)!, align: PosAlign.center);
      bytes += generator.imageRaster(originalImg, align: PosAlign.center);
      bytes += generator.feed(1);

    _printEscPos(bytes, generator);
  }

  /// print ticket
  void _printEscPos(List<int> bytes, Generator generator) async {
    var connectedTCP = false;
    if (selectedPrinter == null) return;
    var bluetoothPrinter = selectedPrinter!;

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: UsbPrinterInput(name: bluetoothPrinter.deviceName, productId: bluetoothPrinter.productId, vendorId: bluetoothPrinter.vendorId));
        pendingTask = null;
        break;
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
                name: bluetoothPrinter.deviceName,
                address: bluetoothPrinter.address!,
                isBle: bluetoothPrinter.isBle ?? false,
                autoConnect: _reconnect));
        pendingTask = null;
        if (Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        connectedTCP = await printerManager.connect(type: bluetoothPrinter.typePrinter, model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!));
        if (!connectedTCP) print(' --- please review your connection ---');
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth && Platform.isAndroid) {
      if (_currentStatus == BTStatus.connected) {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
      }
    } else {
      printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
    }
  }

  // conectar dispositivo
  _connectDevice() async {
    _isConnected = false;
    if (selectedPrinter == null) return;
    switch (selectedPrinter!.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: UsbPrinterInput(name: selectedPrinter!.deviceName, productId: selectedPrinter!.productId, vendorId: selectedPrinter!.vendorId));
        _isConnected = true;
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: BluetoothPrinterInput(
                name: selectedPrinter!.deviceName,
                address: selectedPrinter!.address!,
                isBle: selectedPrinter!.isBle ?? false,
                autoConnect: _reconnect));
        break;
      case PrinterType.network:
        await printerManager.connect(type: selectedPrinter!.typePrinter, model: TcpPrinterInput(ipAddress: selectedPrinter!.address!));
        _isConnected = true;
        break;
      default:
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
      content: Container(
        height: MediaQuery.of(context).size.height*0.5,
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedPrinter == null || _isConnected
                            ? null
                            : () {
                          _connectDevice();
                        },
                        child: const Text("Connect", textAlign: TextAlign.center),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedPrinter == null || !_isConnected
                            ? null
                            : () {
                          if (selectedPrinter != null) printerManager.disconnect(type: selectedPrinter!.typePrinter);
                          setState(() {
                            _isConnected = false;
                          });
                        },
                        child: const Text("Disconnect", textAlign: TextAlign.center),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                  children: devices
                      .map(
                        (device) => ListTile(
                          selected: selectedPrinter != null &&
                              ((device.typePrinter == PrinterType.usb && Platform.isWindows
                                  ? device.deviceName == selectedPrinter!.deviceName
                                  : device.vendorId != null && selectedPrinter!.vendorId == device.vendorId) ||
                                  (device.address != null && selectedPrinter!.address == device.address)),
                      selectedColor: Theme.of(context).primaryColor,
                      title: Text('${device.deviceName}'),
                      subtitle: Platform.isAndroid && defaultPrinterType == PrinterType.usb
                          ? null
                          : Visibility(visible: !Platform.isWindows, child: Text("${device.address}")),
                      onTap: () {
                        // do something
                        selectDevice(device).then((value) async => {
                          if(value==true){
                           await _printReceiveTest()
                          }
                        });
                      },
                      leading: selectedPrinter != null &&
                          ((device.typePrinter == PrinterType.usb && Platform.isWindows
                              ? device.deviceName == selectedPrinter!.deviceName
                              : device.vendorId != null && selectedPrinter!.vendorId == device.vendorId) ||
                              (device.address != null && selectedPrinter!.address == device.address))
                          ? const Icon(
                        Icons.check,
                        color: Colors.green,
                      )
                          : null,

                    ),
                  )
                      .toList()),
              Visibility(
                visible: defaultPrinterType == PrinterType.network && Platform.isWindows,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                    controller: _ipController,
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    decoration: const InputDecoration(
                      label: Text("Ip Address"),
                      prefixIcon: Icon(Icons.wifi, size: 24),
                    ),
                    onChanged: setIpAddress,
                  ),
                ),
              ),
              Visibility(
                visible: defaultPrinterType == PrinterType.network && Platform.isWindows,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                    controller: _portController,
                    keyboardType: const TextInputType.numberWithOptions(signed: true),
                    decoration: const InputDecoration(
                      label: Text("Port"),
                      prefixIcon: Icon(Icons.numbers_outlined, size: 24),
                    ),
                    onChanged: setPort,
                  ),
                ),
              ),
              Visibility(
                visible: defaultPrinterType == PrinterType.network && Platform.isWindows,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: OutlinedButton(
                    onPressed: () async {
                      if (_ipController.text.isNotEmpty) setIpAddress(_ipController.text);
                      _printReceiveTest();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                      child: Text("Print", textAlign: TextAlign.center),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BluetoothPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;

  PrinterType typePrinter;
  bool? state;

  BluetoothPrinter(
      {this.deviceName,
      this.address,
      this.port,
      this.state,
      this.vendorId,
      this.productId,
      this.typePrinter = PrinterType.bluetooth,
      this.isBle = false});
}
