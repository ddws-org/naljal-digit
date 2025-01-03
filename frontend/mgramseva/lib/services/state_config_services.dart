import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart'; // For kIsWeb check
import 'package:http/http.dart' as http;
import 'package:mgramseva/env/app_config.dart';
import 'package:universal_html/html.dart' as html; // For web-based URL handling
class StateConfigService {
  static final StateConfigService _instance = StateConfigService._internal();
  static const String configUrl = "https://naljal-uat-s3.s3.ap-south-1.amazonaws.com/states.json";
  Map<String, String> _stateConfig = {};

  factory StateConfigService() {
    return _instance;
  }

  StateConfigService._internal();

  Future<void> loadConfig() async {
    if (_stateConfig.isNotEmpty) {
      log("Using cached state config", name: "Config");
      return;
    }

    final response = await http.get(Uri.parse(configUrl));
    if (response.statusCode == 200) {
      _stateConfig = Map<String, String>.from(json.decode(response.body));
      log("Fetched state config from S3", name: "Config");
    } else {
      throw Exception("Failed to load configuration");
    }
  }

  String? getTenantId() {
    final state = _determineStateFromUrl();
    if (state != null) {
      return _stateConfig[state];
    }
    log("State could not be determined", name: "State Error");
    return null;
  }

  String? _determineStateFromUrl() {
    return _extractStateName(apiBaseUrl);
  }

  String? _extractStateName(String url) {
    final uri = Uri.parse(url);
    return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
  }
}

