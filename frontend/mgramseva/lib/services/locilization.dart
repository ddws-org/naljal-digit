import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mgramseva/env/app_config.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:universal_html/html.dart';
// import 'package:mgramseva/services/local_storage.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create storage
// final storage = new FlutterSecureStorage();

Future getLocalisation(String locale) async {
  var res = window.localStorage['localisation_' + locale.toString()];
  if (res == null) {
    final requestInfo = RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        "_search",
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        "");

    // print(requestInfo.toJson());
    var response = await http.post(
        Uri.parse(apiBaseUrl.toString() +
            Url.LOCALIZATION +
            "?module=mgramseva-common&locale=" +
            locale +
            "&tenantId=pb"),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: json.encode(requestInfo.toJson()));
    //  var response = await http.post(url,body:json.encode(user.toMap()));
    print('Response status: ${response.statusCode}');

    // print('Response body: ${response.body}');
    if (response.statusCode == 200) {
// Write value
      if (kIsWeb) {
        window.localStorage['localisation_' + locale] =
            jsonEncode(json.decode(response.body)['messages']);
        // Use flutter_secure_storage
        // await storage.write(
        //     key: 'token', value: json.decode(response.body)['token']);
      } else {
        // Use localStorage - unsafe

        // window.localStorage['local'] = ;
      }
    }

    return (response);
  } else {
    return;
  }
}
