import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mgramseva/env/app_config.dart';
import 'package:mgramseva/model/events/events_List.dart';
import 'package:mgramseva/model/common/pdf_service.dart';

import 'package:mgramseva/model/file/file_store.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/model/localization/localization_label.dart';
import 'package:mgramseva/model/mdms/payment_type.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/repository/water_services_calculation.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
enum FileUploadStatus {
  NOT_ACTIVE,STARTED,COMPLETED
}
class CoreRepository extends BaseService {
  Future<List<LocalizationLabel>> getLocilisation(
      Map<String, dynamic> query) async {
    late List<LocalizationLabel> labelList;
    var res = await makeRequest(
        url: Url.LOCALIZATION,
        queryParameters: query,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "_search",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            ""),
        method: RequestType.POST);
    if (res != null) {
      labelList = res['messages']
          .map<LocalizationLabel>((e) => LocalizationLabel.fromJson(e))
          .toList();
    }
    return labelList;
  }

  Future<LanguageList> getMdms(Map body) async {
    late LanguageList languageList;
    var res = await makeRequest(
        url: Url.MDMS,
        body: body,
        method: RequestType.POST,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "_search",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            ""));
    if (res != null) {
      languageList = LanguageList.fromJson(res);
    }
    return languageList;
  }

  Future<WCBillingSlabs?> getRateFromMdms(String tenantId) async {
    var body = {
      "MdmsCriteria": {
        "tenantId": tenantId,
        "moduleDetails": [
          {
            "moduleName": "ws-services-calculation",
            "masterDetails": [
              {"name": "WCBillingSlab"}
            ]
          }
        ]
      }
    };
    late LanguageList languageList;
    var res = await makeRequest(
        url: Url.MDMS,
        body: body,
        method: RequestType.POST,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "_search",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            ""));
    if (res != null) {
      languageList = LanguageList.fromJson(res);
    }
    return languageList.mdmsRes?.wcBillingSlabList;
  }
  Future<PSPCLIntegration?> getPSPCLGpwscFromMdms(String tenantId) async {
    var body = {
      "MdmsCriteria": {
        "tenantId": tenantId,
        "moduleDetails": [
          {
            "moduleName": "pspcl-integration",
            "masterDetails": [
              {
                "name": "accountNumberGpMapping"
              }
            ]
          }
        ]
      }
    };
    late LanguageList languageList;
    var res = await makeRequest(
        url: Url.MDMS,
        body: body,
        method: RequestType.POST,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "_search",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            ""));
    if (res != null) {
      languageList = LanguageList.fromJson(res);
    }
    return languageList.mdmsRes?.pspclIntegration;
  }

  Future<PaymentType> getPaymentTypeMDMS(Map body) async {
    late PaymentType paymentType;
    var res = await makeRequest(
        url: Url.MDMS,
        body: body,
        method: RequestType.POST,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "_search",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            ""));
    if (res != null) {
      paymentType = PaymentType.fromJson(res);
    }
    return paymentType;
  }

  Future<List<FileStore>> uploadFiles(
      List<dynamic>? _paths, String moduleName) async {
    Map? respStr;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var postUri = Uri.parse("$apiBaseUrl${Url.FILE_UPLOAD}");
    var request = new http.MultipartRequest("POST", postUri);
    if (_paths != null && _paths.isNotEmpty) {
      if (_paths is List<PlatformFile>) {
        for (var i = 0; i < _paths.length; i++) {
          var path = _paths[i];
          var fileName = '${path.name}.${path.extension?.toLowerCase()}';
          http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
              'file', path.bytes!,
              contentType: CommonMethods().getMediaType(fileName),
              filename: fileName);
          request.files.add(multipartFile);
        }
      } else if (_paths is List<File>) {
        _paths.forEach((file) async {
          request.files.add(await http.MultipartFile.fromPath('file', file.path,
              contentType: CommonMethods().getMediaType(file.path),
              filename: '${file.path.split('/').last}'));
        });
      } else if (_paths is List<CustomFile>) {
        for (var i = 0; i < _paths.length; i++) {
          var path = _paths[i];
          var fileName = '${path.name}.${path.extension.toLowerCase()}';
          http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
              'file', path.bytes,
              contentType: CommonMethods().getMediaType(fileName),
              filename: fileName);
          request.files.add(multipartFile);
        }
      }
      request.fields['tenantId'] =
          commonProvider.userDetails!.selectedtenant!.code!;
      request.fields['module'] = moduleName;
      await request.send().then((response) async {
        if (response.statusCode == 201)
          respStr = json.decode(await response.stream.bytesToString());
      });
      if (respStr != null && respStr?['files'] != null) {
        return respStr?['files']
            .map<FileStore>((e) => FileStore.fromJson(e))
            .toList();
      }
    }
    return <FileStore>[];
  }

  Future<List<FileStore>?> fetchFiles(List<String> storeId) async {
    List<FileStore>? fileStoreIds;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var res = await makeRequest(
        url:
            '${Url.FILE_FETCH}?tenantId=${commonProvider.userDetails!.selectedtenant!.code!}&fileStoreIds=${storeId.join(',')}',
        method: RequestType.GET);

    if (res != null) {
      fileStoreIds = res['fileStoreIds']
          .map<FileStore>((e) => FileStore.fromJson(e))
          .toList();
    }
    return fileStoreIds;
  }

  Future<String?> urlShotner(String inputUrl) async {
    Map<String, String> header = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    try {
      var response = await http.post(
          Uri.parse(apiBaseUrl + '${Url.URL_SHORTNER}'),
          headers: header,
          body: jsonEncode({"url": inputUrl}));

      return response.body;
        } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
    }
    return null;
  }

  Future<PDFServiceResponse?> getFileStorefromPdfService(body, params) async {
    var languageProvider = Provider.of<LanguageProvider>(
        navigatorKey.currentContext!,
        listen: false);
    PDFServiceResponse? pdfServiceResponse;
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      var res = await makeRequest(
        url: '${Url.FETCH_FILESTORE_ID_PDF_SERVICE}',
        body: body,
        queryParameters: params,
        method: RequestType.POST,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "_create",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            "string|" + languageProvider.selectedLanguage!.value!,
            commonProvider.userDetails!.accessToken),
      );

      if (res != null) {
        pdfServiceResponse = PDFServiceResponse.fromJson(res);
        return pdfServiceResponse;
      }
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
    }
    return null;
  }

  Future<EventsList?> fetchNotifications(params) async {
    EventsList? eventsResponse;
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);

      var res = await makeRequest(
          url: Url.FETCH_EVENTS,
          method: RequestType.POST,
          body: {},
          queryParameters: params,
          requestInfo: RequestInfo(
              APIConstants.API_MODULE_NAME,
              APIConstants.API_VERSION,
              APIConstants.API_TS,
              "_search",
              APIConstants.API_DID,
              APIConstants.API_KEY,
              APIConstants.API_MESSAGE_ID,
              commonProvider.userDetails!.accessToken));

      if (res != null) {
        eventsResponse = EventsList.fromJson((res));

        return eventsResponse;
      }
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
    }
    return null;
  }

  Future<bool?> updateNotifications(events) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);

      var res = await makeRequest(
          url: Url.UPDATE_EVENTS,
          method: RequestType.POST,
          body: events,
          requestInfo: RequestInfo(
              APIConstants.API_MODULE_NAME,
              APIConstants.API_VERSION,
              APIConstants.API_TS,
              "_update",
              APIConstants.API_DID,
              APIConstants.API_KEY,
              APIConstants.API_MESSAGE_ID,
              commonProvider.userDetails!.accessToken));

      if (res != null) {
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
    }
    return null;
  }

  Future<bool?> fileDownload(BuildContext context, String url,
      [String? fileName]) async {
    if (url.contains(',')) {
      url = url.split(',').first;
    }

    fileName = fileName ?? CommonMethods.getExtension(url);
    try {
      var downloadPath;
      if (kIsWeb) {
        html.AnchorElement anchorElement = new html.AnchorElement(href: url);
        anchorElement.download = url;
        anchorElement.target = '_blank';
        anchorElement.click();
        return true;
      } else if (Platform.isIOS) {
        downloadPath = (await getApplicationDocumentsDirectory()).path;
      } else {
        downloadPath = (await getDownloadsDirectory())?.path;
      }
      var status = await Permission.storage.status;
      var status2 = await Permission.photos.status;
      var status1 = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }if (!status1.isGranted) {
        await Permission.notification.request();
      }
      if (!status2.isGranted) {
        await Permission.photos.request();
        await Permission.videos.request();
      }

      final response = await FlutterDownloader.enqueue(
          url: url,
          savedDir: downloadPath,
          fileName: '$fileName',
          showNotification: true,
          openFileFromNotification: true,
          saveInPublicStorage: true);
      if (response != null) {
        CommonProvider.downloadUrl[response] = '$downloadPath/$fileName';
        return true;
      }
      return false;
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(context, e, s);
    }
    return null;
  }

  Future<String?> submitFeedBack(Map body) async {
    var response = await makeRequest(
        url: Url.POST_PAYMENT_FEEDBACK, body: body, method: RequestType.POST);
    return response;
  }
}
