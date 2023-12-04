import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:mgramseva/env/app_config.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/custom_exception.dart';
import 'package:mgramseva/utils/models.dart';

class BaseService {
  Future<dynamic> makeRequest<T>(
      {@required String? url,
      String? baseUrl,
      dynamic body,
      String? contentType,
      Map<String, dynamic>? queryParameters,
      Map<String, String>? headers,
      RequestType method = RequestType.GET,
      RequestInfo? requestInfo}) async {
    var uri;

    if (queryParameters == null) {
      uri = Uri.parse('${baseUrl != null ? baseUrl : apiBaseUrl}$url');
    } else {
      String queryString = Uri(queryParameters: queryParameters).query;
      uri = Uri.parse(
          '${baseUrl != null ? baseUrl : apiBaseUrl}$url?$queryString');
      // uri = Uri.https(apiBaseUrl, url!,  queryParameters);
    }

    // dio.options.baseUrl = baseUrl ?? Urls.baseUrl;
    // dio.options.connectTimeout = Constants.CONNECTION_TIMEOUT; //5s
    // dio.options.receiveTimeout = Constants.RECEIVE_TIMEOUT; //5s
    // dio.options.contentType =  'application/json';
    // dio.options.headers =  {
    //   "Connection" : 'Keep-Alive'
    // };

    if (requestInfo != null) {
      if (body != null) {
        body = {"RequestInfo": requestInfo.toJson(), ...body};
      } else {
        body = requestInfo.toJson();
      }
    }

    if (headers == null ||
        headers[HttpHeaders.contentTypeHeader] == 'application/json') {
      body = jsonEncode(body);
    }

    var header = headers ??
        {
          HttpHeaders.contentTypeHeader: 'application/json',
        };

    http.Response response;
    try {
      switch (method) {
        case RequestType.GET:
          response = await http.get(uri);
          break;
        case RequestType.PUT:
          response = await http.put(uri, body: json.encode(body));
          break;
        case RequestType.POST:
          response = await http.post(uri, headers: header, body: body);
          break;
        case RequestType.DELETE:
          response = await http.delete(uri, body: json.encode(body));
      }
      return _response(response);
    } on CustomException catch (e) {
      throw e;
    } catch (e) {
      print(e);
      throw CustomException('', 502, ExceptionType.CONNECTIONISSUE);
    }
  }
}

dynamic _response(http.Response response) {
  var data;
  try {
    data = json.decode(utf8.decode(response.bodyBytes));
  } catch (e) {
    /// if response was string then it will come to this exception block
    data = utf8.decode(response.bodyBytes);
    return data;
  }

  var errorMessage = data?['Errors']?[0]?['code'] ??
      data?['Errors']?[0]?['message'] ??
      data?['Errors']?[0]?['description'] ??
      data?['error_description'] ??
      data?['error']?['fields']?[0]?['code'] ??
      data?['error']?['fields']?[0]?['message'] ??
      '';

  var errorList = data?['Errors'] ?? [];

  switch (response.statusCode) {
    case 200:
      return data;
    case 201:
      return data;
    case 202:
      return data;
    case 400:
      throw getException(errorMessage, errorList, response.statusCode,
          ExceptionType.FETCHDATA);
    case 401:
    case 403:
      throw CustomException(
          errorMessage, response.statusCode, ExceptionType.UNAUTHORIZED);
    case 500:
      throw getException(errorMessage, errorList, response.statusCode,
          ExceptionType.INVALIDINPUT);
    default:
      throw CustomException(
          errorMessage, response.statusCode, ExceptionType.OTHER);
  }
}

CustomException getException(String errorMsg, List<dynamic> errorList,
    int statusCode, ExceptionType exceptionType) {
  for (var error in errorList) {
    if ((error['message'] ?? '').contains(Constants.INVALID_EXCEPTION_CODE)) {
      throw CustomException(
          i18.common.SESSION_EXPIRED, statusCode, ExceptionType.UNAUTHORIZED);
    }
  }
  throw CustomException(errorMsg, statusCode, exceptionType);
}
