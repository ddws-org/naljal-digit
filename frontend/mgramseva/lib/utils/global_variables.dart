import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// By using this key, we can push pages without context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Present navigation
String? currentRoute;

class APIConstants {
  static const double API_VERSION = 1;
  static const String API_MODULE_NAME = 'mgramseva';
  static const String API_MESSAGE_ID = '';
  static const double API_DID = 1;
  static const String API_KEY = '';
  static const String API_TS = '';
}

/// Custom overly
OverlayState? overlayState;
OverlayEntry? overlayEntry;

/// Gives package versions info
PackageInfo? packageInfo;