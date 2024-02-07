import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:universal_html/html.dart';
import 'package:flutter/services.dart' show rootBundle;

const _baseUrl = "baseUrl";

enum Environment { dev, stage, prod }

late Map<String, dynamic> _config;

Future<void> setEnvironment(Environment env) async{
  switch (env) {
    case Environment.dev:
      _config = await devConstants;
      break;
    case Environment.stage:
      _config = stageConstants;
      break;
    case Environment.prod:
      _config = prodConstants;
      break;
  }
}

dynamic get apiBaseUrl {
  return _config[_baseUrl];
}

Future<Map<String, dynamic>> get devConstants async {

  if(kIsWeb){
    var state = (window.location.href.split('/')[4] == 'mgramseva'?window.location.href.split('/')[3]:'');
    final content = await rootBundle.loadString('assets/json/states.json');
    Map states = json.decode(content);
    if(state.isNotEmpty && states.containsKey(state)){
      print("States: "+states.toString());
      var stateCode = states[state]['code'];
      Constants.STATE_CODE = stateCode;
    }
    return {
      _baseUrl: "https://naljalseva.jjm.in/" + state + (state.isNotEmpty?"/":''),
      // _baseUrl: window.location.origin + "/" + state + (state.isNotEmpty?"/":''),
    };
  }
  return {
    _baseUrl: const String.fromEnvironment('BASE_URL'),
  };
}

Map<String, dynamic> stageConstants = {
  _baseUrl: "https://api.stage.com/",
};

Map<String, dynamic> prodConstants = {
  _baseUrl: "https://api.production.com/",
};

class FirebaseConfigurations {
  static const _apiKey = "AIzaSyBWQkRGvXiKu_fLAA5O8SvQzZTWeQTqMZ8";
  static const _authDomain = "mgramseva-qa.egov.org.in";
  static const _projectId = "sample-mgramseva";
  static const _storageBucket = "sample-mgramseva.appspot.com";
  static const _messagingSenderId ="1026518772539";
  static const _appId = "1:1026518772539:android:bfa7ff7ef250f28789251e";

//Make some getter functions
  String get apiKey => _apiKey;
  String get authDomain => _authDomain;
  String get projectId => _projectId;
  String get storageBucket => _storageBucket;
  String get messagingSenderId => _messagingSenderId;
  String get appId => _appId;

  static FirebaseOptions get firebaseOptions => FirebaseOptions(apiKey: _apiKey, appId: _appId, messagingSenderId: _messagingSenderId, projectId: _projectId, storageBucket: _storageBucket, authDomain: _authDomain);
}
