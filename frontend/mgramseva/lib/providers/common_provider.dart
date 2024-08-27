import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:mgramseva/model/bill/bill_payments.dart';
import 'package:mgramseva/model/demand/demand_list.dart';
import 'package:mgramseva/model/file/file_store.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/model/localization/localization_label.dart';
import 'package:mgramseva/model/mdms/payment_type.dart';
import 'package:mgramseva/model/mdms/tenants.dart';
import 'package:mgramseva/model/user/user_details.dart';
import 'package:mgramseva/model/user_profile/user_profile.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/providers/tenants_provider.dart';
import 'package:mgramseva/repository/authentication_repo.dart';
import 'package:mgramseva/repository/core_repo.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/services/local_storage.dart';
import 'package:mgramseva/services/mdms.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

import '../model/demand/update_demand_list.dart';
import '../utils/notifiers.dart';

class CommonProvider with ChangeNotifier {
  List<LocalizationLabel> localizedStrings = <LocalizationLabel>[];
  var userLoggedStreamCtrl = StreamController.broadcast();
  UserDetails? userDetails;
  AppVersion? appVersion;
  static Map<String, String> downloadUrl = {};

  dispose() {
    userLoggedStreamCtrl.close();
    super.dispose();
  }

  Future<List<LocalizationLabel>> getLocalizationLabels() async {
    var languageProvider = Provider.of<LanguageProvider>(
        navigatorKey.currentContext!,
        listen: false);
    List<LocalizationLabel> labels = <LocalizationLabel>[];

    dynamic localLabelResponse;
    if (kIsWeb) {
      localLabelResponse =
          html.window.localStorage[languageProvider.selectedLanguage?.value ?? ''];
    } else {
      localLabelResponse = await storage.read(
          key: languageProvider.selectedLanguage?.value ?? '');
    }
    if (localLabelResponse != null && localLabelResponse.trim().isNotEmpty) {
      return localizedStrings = jsonDecode(localLabelResponse)
          .map<LocalizationLabel>((e) => LocalizationLabel.fromJson(e))
          .toList();
    }

    try {
      var query = {
        'module':
            'mgramseva-common,mgramseva-consumer,mgramseva-expenses,mgramseva-water-connection,mgramseva-bill,mgramseva-payments,mgramseva-dashboard,mgramseva-feedback',
        'locale': languageProvider.selectedLanguage?.value ?? '',
        'tenantId': languageProvider.stateInfo!.code
      };

      var response = await CoreRepository().getLocilisation(query);
      labels = localizedStrings = response;
      setLocalizationLabels(response);
    } catch (e) {}
    return labels;
  }

  setSelectedTenant(UserDetails? loginDetails) {
    if (kIsWeb) {
      html.window.localStorage[Constants.LOGIN_KEY] =
          loginDetails == null ? '' : jsonEncode(loginDetails.toJson());
    } else {
      storage.write(
          key: Constants.LOGIN_KEY,
          value:
              loginDetails == null ? null : jsonEncode(loginDetails.toJson()));
    }
  }

  setTenant(tenant) {
    userDetails?.selectedtenant = tenant;
    setSelectedState(userDetails!);
    notifyListeners();
  }

  void setSelectedState(UserDetails? loginDetails) async {
    if (kIsWeb) {
      html.window.localStorage[Constants.LOGIN_KEY] =
          loginDetails == null ? '' : jsonEncode(loginDetails.toJson());
    } else {
      storage.write(
          key: Constants.LOGIN_KEY,
          value:
              loginDetails == null ? null : jsonEncode(loginDetails.toJson()));
    }
  }

  setLocalizationLabels(List<LocalizationLabel> labels) async {
    var languageProvider = Provider.of<LanguageProvider>(
        navigatorKey.currentContext!,
        listen: false);
    try {
      if (kIsWeb) {
        html.window.localStorage[languageProvider.selectedLanguage?.value ?? ''] =
            jsonEncode(labels.map((e) => e.toJson()).toList());
      } else {
        await storage.write(
            key: languageProvider.selectedLanguage?.value ?? '',
            value: jsonEncode(labels.map((e) => e.toJson()).toList()));
      }
    } catch (e) {
      Notifiers.getToastMessage(navigatorKey.currentState!.context,
          'Unable to store the details', 'ERROR');
    }
  }

  set loginCredentials(UserDetails? loginDetails) {
    userDetails = loginDetails;
    if (kIsWeb) {
      html.window.localStorage[Constants.LOGIN_KEY] =
          loginDetails == null ? '' : jsonEncode(loginDetails.toJson());
    } else {
      storage.write(
          key: Constants.LOGIN_KEY,
          value:
              loginDetails == null ? null : jsonEncode(loginDetails.toJson()));
    }
    notifyListeners();
  }

  set userProfile(UserProfile? profile) {
    if (kIsWeb) {
      html.window.localStorage[Constants.USER_PROFILE_KEY] =
          profile == null ? '' : jsonEncode(profile.toJson());
    } else {
      storage.write(
          key: Constants.USER_PROFILE_KEY,
          value: profile == null ? null : jsonEncode(profile.toJson()));
    }
    notifyListeners();
  }

  walkThroughCondition(bool? firstTime, String key) {
    if (kIsWeb) {
      html.window.localStorage[key] = firstTime.toString();
    } else {
      storage.write(key: key, value: firstTime.toString());
    }
    notifyListeners();
  }

  Future<String> getWalkThroughCheck(String key) async {
    var userResponse;
    try {
      if (kIsWeb) {
        userResponse = html.window.localStorage[key];
      } else {
        userResponse = (await storage.read(key: key));
      }
    } catch (e) {
      userLoggedStreamCtrl.add(null);
    }
    if (userResponse == null) {
      userResponse = 'true';
    }
    return userResponse;
  }

  Future<UserProfile> getUserProfile() async {
    var userResponse;
    try {
      if (kIsWeb) {
        userResponse = html.window.localStorage[Constants.USER_PROFILE_KEY];
      } else {
        userResponse = await storage.read(key: Constants.USER_PROFILE_KEY);
      }
    } catch (e) {
      userLoggedStreamCtrl.add(null);
    }
    return UserProfile.fromJson(jsonDecode(userResponse));
  }

  Future<void> getLoginCredentials() async {
    var languageProvider = Provider.of<LanguageProvider>(
        navigatorKey.currentContext!,
        listen: false);
    dynamic loginResponse;
    dynamic stateResponse;
    try {
      if (kIsWeb) {
        loginResponse = html.window.localStorage[Constants.LOGIN_KEY];

        stateResponse = html.window.localStorage[Constants.STATES_KEY];
      } else {
        var isUpdated = false;
        try {
          if (!await storage.containsKey(key: Constants.APP_VERSION) ||
              !await storage.containsKey(key: Constants.BUILD_NUMBER)) {
            await storage.deleteAll();
            isUpdated = true;
            storage.write(
                key: Constants.APP_VERSION, value: packageInfo?.version);
            storage.write(
                key: Constants.BUILD_NUMBER, value: packageInfo?.buildNumber);
          } else {
            if (await storage.read(key: Constants.APP_VERSION) !=
                    packageInfo?.version ||
                await storage.read(key: Constants.BUILD_NUMBER) !=
                    packageInfo?.buildNumber) {
              await storage.deleteAll();
              isUpdated = true;
              storage.write(
                  key: Constants.APP_VERSION, value: packageInfo?.version);
              storage.write(
                  key: Constants.BUILD_NUMBER, value: packageInfo?.buildNumber);
            }
          }
        } catch (e) {}

        if (!isUpdated) {
          loginResponse = await storage.read(key: Constants.LOGIN_KEY);
          stateResponse = await storage.read(key: Constants.STATES_KEY);
        }
      }

      if (stateResponse != null && stateResponse.trim().isNotEmpty) {
        languageProvider.stateInfo =
            StateInfo.fromJson(jsonDecode(stateResponse));
      }

      if (loginResponse != null && loginResponse.trim().isNotEmpty) {
        var decodedResponse = UserDetails.fromJson(jsonDecode(loginResponse));
        userDetails = decodedResponse;
        userLoggedStreamCtrl.add(decodedResponse);
      } else {
        userLoggedStreamCtrl.add(null);
      }
    } catch (e) {
      userLoggedStreamCtrl.add(null);
    }
  }

  Future<void> getAppVersionDetails() async {
    try {
      var localizationList = await CoreRepository().getMdms(
          initRequestBody({"tenantId": dotenv.get('STATE_LEVEL_TENANT_ID')}));
      appVersion = localizationList.mdmsRes!.commonMasters!.appVersion!.first;
    } catch (e) {
      print(e.toString());
    }
  }

  UserDetails? getWebLoginStatus() {
    var languageProvider = Provider.of<LanguageProvider>(
        navigatorKey.currentContext!,
        listen: false);

    dynamic loginResponse;
    dynamic stateResponse;

    var isUpdated = false;
    if (!html.window.localStorage.containsKey(Constants.APP_VERSION) ||
        !html.window.localStorage.containsKey(Constants.BUILD_NUMBER)) {
      html.window.localStorage.clear();
      isUpdated = true;
      html.window.localStorage[Constants.APP_VERSION] = packageInfo?.version ?? '';
      html.window.localStorage[Constants.BUILD_NUMBER] =
          packageInfo?.buildNumber ?? '';
    } else {
      if (html.window.localStorage[Constants.APP_VERSION] != packageInfo?.version ||
          html.window.localStorage[Constants.BUILD_NUMBER] !=
              packageInfo?.buildNumber) {
        html.window.localStorage.clear();
        isUpdated = true;
        html.window.localStorage[Constants.APP_VERSION] = packageInfo?.version ?? '';
        html.window.localStorage[Constants.BUILD_NUMBER] =
            packageInfo?.buildNumber ?? '';
      }
    }

    if (!isUpdated) {
      loginResponse = html.window.localStorage[Constants.LOGIN_KEY];
      stateResponse = html.window.localStorage[Constants.STATES_KEY];
    } else {
      userDetails = null;
    }

    if (stateResponse != null && stateResponse.trim().isNotEmpty) {
      languageProvider.stateInfo =
          StateInfo.fromJson(jsonDecode(stateResponse));

      if (languageProvider.stateInfo != null) {
        ApplicationLocalizations(Locale(
                languageProvider.selectedLanguage?.label ?? '',
                languageProvider.selectedLanguage?.value))
            .load();
      }
    }

    if (loginResponse != null && loginResponse.trim().isNotEmpty) {
      var decodedResponse = UserDetails.fromJson(jsonDecode(loginResponse));
      userDetails = decodedResponse;
    }
    return userDetails;
  }

  void onLogout() async {
    await AuthenticationRepository().logoutUser().then((onValue) {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil(Routes.SELECT_LANGUAGE, (route) => false);
      loginCredentials = null;
    });
  }

  void onTapOfAttachment(FileStore store, context) async {
    if (store.url == null) return;
    CoreRepository().fileDownload(context, store.url!);
  }

  void shareonwatsapp(FileStore store, mobileNumber, input) async {
    if (store.url == null) return;
    late html.AnchorElement anchorElement;
    try {
      var res = await CoreRepository().urlShotner(store.url as String);
      if (kIsWeb) {
        if (mobileNumber == null) {
          anchorElement = new html.AnchorElement(
              href: "https://wa.me/send?text=" +
                  input.toString().replaceFirst('{link}', res!));
        } else {
          anchorElement = new html.AnchorElement(
              href: "https://wa.me/+91$mobileNumber?text=" +
                  input.toString().replaceFirst('{link}', res!));
        }

        anchorElement.target = "_blank";
        anchorElement.click();
      } else {
        var link;
        if (mobileNumber == null) {
          final FlutterShareMe flutterShareMe = FlutterShareMe();
          var response = await flutterShareMe.shareToWhatsApp(
                  msg: input.toString().replaceFirst('{link}', res!)) ??
              '';
          if (response.contains('PlatformException')) {
            link = "https://api.whatsapp.com/send?text=" +
                input
                    .toString()
                    .replaceAll(" ", "%20")
                    .replaceFirst('{link}', res);
            await canLaunch(link)
                ? launch(link)
                : ErrorHandler.logError('failed to launch the url $link');
          }
          return;
        } else {
          link = "https://wa.me/+91$mobileNumber?text=" +
              input
                  .toString()
                  .replaceAll(" ", "%20")
                  .replaceFirst('{link}', res!);
        }
        await canLaunch(link)
            ? launch(link)
            : ErrorHandler.logError('failed to launch the url $link');
      }
    } catch (e, s) {
      ErrorHandler.logError(e.toString(), s);
    }
  }

  void getStoreFileDetails(
      fileStoreId, mode, mobileNumber, context, link) async {
    if (fileStoreId == null) return;
    try {
      var res = await CoreRepository().fetchFiles([fileStoreId!]);
      if (res != null) {
        if (mode == 'Share') {
          shareonwatsapp(res.first, mobileNumber, link);
        } else
          onTapOfAttachment(res.first, context);
      }
    } catch (e, s) {
      ErrorHandler.logError(e.toString(), s);
    }
  }

  void getFileFromPDFPaymentService(
      body, params, mobileNumber, Payments payments, mode) async {
    try {
      var res = await CoreRepository().getFileStorefromPdfService(body, params);
      String link = (ApplicationLocalizations.of(navigatorKey.currentContext!)
          .translate(i18.common.SHARE_RECEIPT_LINK)
          .toString()
          .replaceFirst('{user}', payments.paidBy!)
          .replaceFirst('{Amount}', payments.totalAmountPaid.toString())
          .replaceFirst('{new consumer id}',
              payments.paymentDetails!.first.bill!.consumerCode.toString())
          .replaceFirst('{Amount}',
              (payments.totalDue! - payments.totalAmountPaid!).toString()));
      getStoreFileDetails(res!.filestoreIds!.first, mode, mobileNumber,
          navigatorKey.currentContext, link);
    } catch (e, s) {
      ErrorHandler.logError(e.toString(), s);
    }
  }

  void getFileFromPDFBillService(body, params, mobileNumber, bill, mode,
      {String? fireStoreId = ""}) async {
    try {
      var res;
      if (fireStoreId == "") {
        res = await CoreRepository().getFileStorefromPdfService(body, params);
      }

      String link = (ApplicationLocalizations.of(navigatorKey.currentContext!)
          .translate(i18.common.SHARE_BILL_LINK)
          .toString()
          .replaceFirst('{user}', bill.payerName!.toString())
          .replaceFirst('{cycle}',
              '${DateFormats.getMonthWithDay(bill.billDetails?.first?.fromPeriod)} - ${DateFormats.getMonthWithDay(bill.billDetails?.first?.toPeriod)}')
          .replaceFirst('{new consumer id}', bill.consumerCode!.toString())
          .replaceFirst('{Amount}', bill.totalAmount.toString()));
      getStoreFileDetails(
        fireStoreId != "" ? fireStoreId : res!.filestoreIds!.first,
        mode,
        mobileNumber,
        navigatorKey.currentContext,
        link,
      );
    } catch (e, s) {
      ErrorHandler.logError(e.toString(), s);
    }
  }

  String? getMdmsId(LanguageList? mdms, String code, MDMSType mdmsType) {
    try {
      switch (mdmsType) {
        case MDMSType.BusinessService:
          return mdms?.mdmsRes?.billingService?.businessServiceList
              ?.firstWhere((e) => e.businessService == code)
              .code;
        case MDMSType.ConsumerType:
          return mdms?.mdmsRes?.billingService?.businessServiceList
              ?.firstWhere((e) => e.businessService == code)
              .code;
        case MDMSType.TaxHeadCode:
          return mdms?.mdmsRes?.billingService?.taxHeadMasterList
              ?.firstWhere((e) => e.service == code)
              .code;
        default:
          return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<void> sharePdfOnWhatsApp(BuildContext context, pw.Document pdf,
      String fileName, String localizedText,
      {bool isDownload = false}) async {
    try {
      if (isDownload && kIsWeb) {
        final blob = html.Blob([await pdf.save()]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.document.createElement('a') as html.AnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = '$fileName.pdf';
        html.document.body?.children.add(anchor);
        anchor.click();
        html.document.body?.children.remove(anchor);
        html.Url.revokeObjectUrl(url);
      } else {
        /// Enable loader
        Loaders.showLoadingDialog(context, label: '');

        Uint8List data = await pdf.save();

        /// Uploading file to S3 bucket
        var file = CustomFile(data, fileName, 'pdf');
        var response = await CoreRepository()
            .uploadFiles(<CustomFile>[file], APIConstants.API_MODULE_NAME);

        if (response.isNotEmpty) {
          var commonProvider =
              Provider.of<CommonProvider>(context, listen: false);
          var res =
              await CoreRepository().fetchFiles([response.first.fileStoreId!]);
          if (res != null && res.isNotEmpty) {
            if (isDownload) {
              CoreRepository().fileDownload(context, res.first.url ?? '');
            } else {
              var url = res.first.url ?? '';
              if (url.contains(',')) {
                url = url.split(',').first;
              }
              response.first.url = url;

              commonProvider.shareonwatsapp(
                  response.first, null, localizedText);
            }
          }
        }
        navigatorKey.currentState?.pop();
      }
    } catch (e, s) {
      navigatorKey.currentState?.pop();
      ErrorHandler().allExceptionsHandler(context, e, s);
    }
  }

  static List<KeyValue> getAlphabetsWithKeyValue() {
    List<String> alphabets = [];
    List<KeyValue> excelColumns = [];
    for (int i = 65; i <= 90; i++) {
      alphabets.add(String.fromCharCode(i));
    }
    for (int i = 0; i < 26; i++) {
      excelColumns.add(KeyValue(alphabets[i], i));
    }
    return excelColumns;
  }

  Future<pw.Font> getPdfFontFamily() async {
    var language = Provider.of<LanguageProvider>(navigatorKey.currentContext!,
        listen: false);

    switch (language.selectedLanguage!.value) {
      case 'en_IN':
        return pw.Font.ttf(
            await rootBundle.load('assets/fonts/Roboto/Roboto-Regular.ttf'));
      case 'hi_IN':
        return pw.Font.ttf(
            await rootBundle.load('assets/fonts/Roboto/Hind-Regular.ttf'));
      default:
        return pw.Font.ttf(
            await rootBundle.load('assets/fonts/Roboto/punjabi.ttf'));
    }
  }

  // static  String getAdvanceAdjustedAmount(List<Demands> demandList) {
  //   var amount = '0';
  //   var index = -1;
  //   for(int i =0; i < demandList.length; i++){
  //     index = demandList[i].demandDetails?.lastIndexWhere((e) => e.taxHeadMasterCode == 'WS_ADVANCE_CARRYFORWARD') ?? -1;
  //     if(index != -1){
  //
  //       if(demandList[i].demandDetails?.length == 1){
  //
  //       }else if(demandList[i].demandDetails?.length == 2){
  //         amount = (demandList[i].demandDetails![index].collectionAmount ?? 0).toString();
  //       } else if(demandList[i].demandDetails?[index].collectionAmount == demandList[i].demandDetails?[index].taxAmount){
  //         if((demandList.first.demandDetails?.first.collectionAmount ?? 0) > 0){
  //          amount = (-(demandList.first.demandDetails!.first.collectionAmount ?? 0)).toString();
  //         }else {
  //           amount = (demandList[i].demandDetails![index].collectionAmount ?? 0).toString();
  //         }
  //         }
  //       else{
  //         amount = ((demandList[i].demandDetails![index].collectionAmount ?? 0) -  (demandList[i].demandDetails![index-1].collectionAmount ?? 0)).toString();
  //       }
  //       break;
  //     }
  //   }
  //   return amount;
  // }

  static String getAdvanceAdjustedAmount(List<Demands> demandList) {
    // Set Amt as 0
    var amount = '0';
    var index = -1;

    // if demandList.isEmpty return Amt as 0
    if (demandList.isEmpty) return amount;

    // Sort Demands where Payments were not completed
    var filteredDemands =
        demandList.where((e) => !(e.isPaymentCompleted ?? false)).toList();

    // Early return if first demand has time penalty and there's applicable penalty
    if (filteredDemands.first.demandDetails?.first.taxHeadMasterCode ==
            'WS_TIME_PENALTY' &&
        CommonProvider.getPenaltyApplicable(demandList).penaltyApplicable !=
            0) {
      // here also return 0;
      return amount;
    } else {
      for (int i = 0; i < filteredDemands.length; i++) {
        index = demandList[i].demandDetails?.lastIndexWhere(
                (e) => e.taxHeadMasterCode == 'WS_ADVANCE_CARRYFORWARD') ??
            -1;
        // Find the last index of "WS_ADVANCE_CARRYFORWARD" element in the current demand's details list (if it exists)
        // true => index value else => -1
        if (index != -1) {
          var demandDetail = demandList[i].demandDetails?[index];
          // Collection Amt < tax amt
          if (demandDetail!.collectionAmount!.abs() <
              demandDetail.taxAmount!.abs()) {
            //  save amount
            amount = filteredDemands.first.demandDetails?.last.collectionAmount
                    ?.toString() ??
                '0.0';
          } else if (demandDetail.collectionAmount! ==
              demandDetail.taxAmount!) {
            // Iterate through  filteredDemands
            if (filteredDemands.first.demandDetails?.last.collectionAmount !=
                0) {
              var list = <double>[];
              for (int j = 0; j <= i; j++) {
                // Iterate through  elements in the current demand's details list
                for (int k = 0;
                    k < (filteredDemands[j].demandDetails?.length ?? 0);
                    k++) {
                  if (k == index && j == i) break;
                  // Add amount to collection
                  list.add(
                      filteredDemands[j].demandDetails![k].collectionAmount ??
                          0);
                }
              }
              // find sum of colleted amount
              var collectedAmount = list.reduce((a, b) => a + b);
              amount = double.parse("$collectedAmount") >=
                      double.parse("${demandDetail.collectionAmount?.abs()}")
                  ? filteredDemands.first.demandDetails?.last.collectionAmount
                          ?.toString() ??
                      '0'
                  : '0';
              // set amount
            }
          }
        }
      }
    }
    return amount;
  }

  static double getTotalBillAmount(List<Demands> demandList) {
    if (!isFirstDemand(demandList)) {
      var amount = 0.0;
      demandList.first.demandDetails?.forEach((demand) {
        if (demand.taxHeadMasterCode == '10102' ||
            demand.taxHeadMasterCode == '10201' ||
            demand.taxHeadMasterCode == 'WS_TIME_PENALTY')
          amount += ((demand.taxAmount ?? 0) - (demand.collectionAmount ?? 0));
      });
      return amount;
    }
    return ((CommonProvider.checkAdvance(demandList)
            ? (demandList.first.demandDetails?.first.taxAmount ?? 0)
            : (demandList.first.demandDetails?.first.taxAmount ?? 0) -
                (demandList.first.demandDetails?.first.collectionAmount ?? 0)) +
        CommonProvider.getArrearsAmount(demandList));
  }

  static num getNetDueAmountWithWithOutPenalty(num totalAmount, Penalty penalty,
      [bool withPenalty = false]) {
    if (withPenalty)
      return totalAmount >= 0
          ? (penalty.isDueDateCrossed
              ? totalAmount
              : totalAmount + penalty.penalty)
          : penalty.penalty;
    return totalAmount;
  }

  static bool isFirstDemand(List<Demands> demandList) {
    var isFirstDemand = false;

    if (demandList.isEmpty == true) {
      isFirstDemand = false;
    } else if (demandList.length == 1 &&
        demandList.first.consumerType == 'waterConnection-arrears') {
      isFirstDemand = false;
    } else if (demandList.length == 1 &&
        demandList.first.consumerType == 'waterConnection-advance' &&
        demandList.first.demandDetails?.first.taxHeadMasterCode ==
            'WS_ADVANCE_CARRYFORWARD') {
      isFirstDemand = false;
    } else {
      isFirstDemand = true;
    }
    return isFirstDemand;
  }

  static double getNormalPenalty(List<Demands> demandList) {
    var penalty = 0.0;

    var filteredDemands =
        demandList.where((e) => !(e.isPaymentCompleted ?? false)).toList();

    filteredDemands.forEach((billDetails) {
      billDetails.demandDetails?.forEach((billAccountDetails) {
        if (billAccountDetails.taxHeadMasterCode == '10201') {
          penalty += ((billAccountDetails.taxAmount ?? 0) -
              (billAccountDetails.collectionAmount ?? 0));
        }
      });
    });
    return penalty;
  }

  List<String>? uniqueRolesList() {
    return userDetails?.userRequest?.roles
        ?.where((e) => e.tenantId == userDetails?.selectedtenant?.code)
        .map((role) => role.code.toString())
        .toSet()
        .toList();
  }

  static double getCurrentBill(List<Demands> demandList) {
    var currentBill = 0.0;
    var currentBillLeft = 0.0;

    var filteredDemands =
        demandList.where((e) => !(e.isPaymentCompleted ?? false));

    filteredDemands.forEach((elem) {
      elem.demandDetails?.forEach((demand) {
        if (demand.taxHeadMasterCode == '10101') {
          currentBillLeft =
              ((demand.taxAmount ?? 0) - (demand.collectionAmount ?? 0));
        }
      });
    });

    if (currentBillLeft == 0) {
      filteredDemands.first.demandDetails?.forEach((billAccountDetails) {
        if (billAccountDetails.taxHeadMasterCode == '10101') {
          currentBill += ((billAccountDetails.taxAmount ?? 0) -
              (billAccountDetails.collectionAmount ?? 0));
        }
      });
    } else {
      currentBill = currentBillLeft;
    }

    return currentBill;
  }

  static Penalty getPenalty(List<UpdateDemands>? demandList) {
    Penalty? penalty;

    var filteredDemands =
        demandList?.where((e) => !(e.isPaymentCompleted ?? false)).first;

    filteredDemands?.demandDetails?.forEach((billAccountDetails) {
      if (billAccountDetails.taxHeadMasterCode == 'WS_TIME_PENALTY') {
        var amount = billAccountDetails.taxAmount ?? 0;
        DateTime billGenerationDate, expiryDate;
        // DateTime.fromMillisecondsSinceEpoch(1659420829000);
        var date = billAccountDetails.auditDetails != null
            ? DateTime.fromMillisecondsSinceEpoch(
                billAccountDetails.auditDetails!.createdTime ?? 0)
            : DateTime.fromMillisecondsSinceEpoch(filteredDemands
                    .demandDetails?.first.auditDetails!.createdTime ??
                0);
        billGenerationDate =
            expiryDate = DateTime(date.year, date.month, date.day);
        expiryDate = expiryDate.add(Duration(
            milliseconds: filteredDemands.billExpiryTime ?? 0, days: 0));
        penalty = Penalty(
            amount.toDouble(),
            DateFormats.getFilteredDate(expiryDate.toString()),
            DateTime.now().isAfter(expiryDate));
      }
    });
    return penalty ?? Penalty(0.0, '', false);
  }

  static PenaltyApplicable getPenaltyApplicable(List<Demands>? demandList) {
    var res = [];
    var filteredDemands =
        demandList?.where((e) => !(e.isPaymentCompleted ?? false)).toList();

    if (demandList?.first.demandDetails?.first.taxHeadMasterCode ==
        'WS_TIME_PENALTY') {
      filteredDemands?.first.demandDetails!.forEach((e) {
        if (e.taxHeadMasterCode == 'WS_TIME_PENALTY') {
          res.add((e.taxAmount ?? 0) - (e.collectionAmount ?? 0));
        }
      });
    } else {
      filteredDemands?.first.demandDetails!.forEach((e) {
        if (e.taxHeadMasterCode == 'WS_TIME_PENALTY' ||
            e.taxHeadMasterCode == '10201') {
          res.add((e.taxAmount ?? 0) - (e.collectionAmount ?? 0));
        }
      });
    }

    var penaltyAmount = res.length == 0
        ? 0
        : ((res.reduce((previousValue, element) => previousValue + element))
                as double)
            .abs();

    return PenaltyApplicable(penaltyAmount.toDouble());
  }

  static num getAdvanceAmount(List<Demands> demandList) {
    var amount = 0.0;
    var index = -1;
    for (int i = 0; i < demandList.length; i++) {
      index = demandList[i].demandDetails?.lastIndexWhere(
              (e) => e.taxHeadMasterCode == 'WS_ADVANCE_CARRYFORWARD') ??
          -1;
      if (index != -1) {
        amount = (demandList[i].demandDetails![index].taxAmount ?? 0) -
            (demandList[i].demandDetails![index].collectionAmount ?? 0);
        break;
      }
    }
    return amount;
  }

  static double getArrearsAmount(List<Demands> demandList) {
    List res = [];

    if (!isFirstDemand(demandList)) {
      var arrearsAmount = 0.0;
      demandList.first.demandDetails?.forEach((demand) {
        if (demand.taxHeadMasterCode == '10102')
          arrearsAmount +=
              ((demand.taxAmount ?? 0) - (demand.collectionAmount ?? 0));
      });
      return arrearsAmount;
    }

    if (demandList.isNotEmpty) {
      var filteredDemands = demandList
          .where((e) =>
              (!(e.isPaymentCompleted ?? false) && e.status != 'CANCELLED'))
          .toList();
      for (var demand in filteredDemands) {
        demand.demandDetails!.forEach((e) {
          if (e.taxHeadMasterCode != 'WS_ADVANCE_CARRYFORWARD') {
            res.add((e.taxAmount ?? 0) - (e.collectionAmount ?? 0));
          }
        });
      }
    }

    var arrearsDeduction =
        (demandList.first.demandDetails?.first.taxHeadMasterCode !=
                    'WS_ADVANCE_CARRYFORWARD' &&
                demandList.first.demandDetails?.first.taxHeadMasterCode !=
                    'WS_TIME_PENALTY')
            ? ((demandList.first.demandDetails?.first.taxAmount ?? 0) -
                (demandList.first.demandDetails?.first.collectionAmount ?? 0))
            : 0;

    return res.length == 0
        ? 0
        : ((res.reduce((previousValue, element) => previousValue + element) -
                arrearsDeduction) as double)
            .abs();
  }

  static double getArrearsAmountOncePenaltyExpires(List<Demands> demandList) {
    List res = [];
    var arrearsDeduction = 0.0;
    var penaltyDeduction = 0.0;

    if (!isFirstDemand(demandList)) {
      var arrearsAmount = 0.0;
      demandList.first.demandDetails?.forEach((demand) {
        if (demand.taxHeadMasterCode == '10102')
          arrearsAmount +=
              ((demand.taxAmount ?? 0) - (demand.collectionAmount ?? 0));
      });
      return arrearsAmount;
    }

    if (demandList.isNotEmpty) {
      var filteredDemands = demandList
          .where((e) =>
              (!(e.isPaymentCompleted ?? false) && e.status != 'CANCELLED'))
          .toList();

      filteredDemands.forEach((elem) {
        elem.demandDetails?.forEach((element) {
          if (element.taxHeadMasterCode == '10101') {
            arrearsDeduction =
                ((element.taxAmount ?? 0) - (element.collectionAmount ?? 0));
          }
        });
      });

      filteredDemands.first.demandDetails?.forEach((element) {
        if (element.taxHeadMasterCode == 'WS_TIME_PENALTY') {
          penaltyDeduction =
              ((element.taxAmount ?? 0) - (element.collectionAmount ?? 0));
        }
      });

      for (var demand in filteredDemands) {
        demand.demandDetails!.forEach((e) {
          if (e.taxHeadMasterCode != 'WS_ADVANCE_CARRYFORWARD') {
            res.add((e.taxAmount ?? 0) - (e.collectionAmount ?? 0));
          }
        });
      }
    }

    return res.length == 0
        ? 0
        : ((res.reduce((previousValue, element) => previousValue + element) -
                arrearsDeduction -
                penaltyDeduction) as double)
            .abs();
  }

  static Future<PaymentType> getMdmsBillingService(String tenantId) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);

      return await CoreRepository()
          .getPaymentTypeMDMS(getMDMSPaymentModes(tenantId));
    } catch (e) {
      return PaymentType();
    }
  }

  static Future<PaymentType> getMdmsPaymentList(String tenantId) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);

      return await CoreRepository()
          .getPaymentTypeMDMS(getPaymentModeList(tenantId));
    } catch (e) {
      return PaymentType();
    }
  }

  static bool checkAdvance(List<Demands> demandList) {
    var advance = false;
    var index = -1;
    for (int i = 0; i < demandList.length; i++) {
      index = demandList[i].demandDetails?.lastIndexWhere(
              (e) => e.taxHeadMasterCode == 'WS_ADVANCE_CARRYFORWARD') ??
          -1;
      if (index != -1) {
        advance = true;
        break;
      }
    }
    return advance;
  }

  static bool getPenaltyOrAdvanceStatus(PaymentType? languageList,
      [isAdvance = false, bool isTimePenalty = false]) {
    if (languageList == null) return false;
    var index = languageList.mdmsRes?.billingService?.taxHeadMasterList
        ?.indexWhere((e) =>
            e.code ==
            (isAdvance
                ? 'WS_ADVANCE_CARRYFORWARD'
                : isTimePenalty
                    ? 'WS_TIME_PENALTY'
                    : '10201'));
    if (index != null && index != -1) {
      return (languageList
              .mdmsRes?.billingService?.taxHeadMasterList?[index].isRequired ??
          false);
    }
    return false;
  }

// App Bar Calls Refreactor
  void appBarUpdate() {
     var tenantProvider = Provider.of<TenantsProvider>(navigatorKey.currentContext!, listen: false);
    
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    
    if (tenantProvider.tenants != null) {
      final r = commonProvider.userDetails!.userRequest!.roles!
          .map((e) => e.tenantId)
          .toSet()
          .toList();
      final result = tenantProvider.tenants!.tenantsList
          ?.where((element) => r.contains(element.code?.trim()))
          .toList();
      if (result?.length == 1 &&
          commonProvider.userDetails!.selectedtenant == null) {
        if (result?.isNotEmpty ?? false)
          commonProvider.setTenant(result?.first);
    
        // });
      } else if (result != null &&
          result.length > 1 &&
          commonProvider.userDetails!.selectedtenant == null) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => showDialogBox(result));
      }
    } else {
      tenantProvider.getTenants().then((value) {
        final r = commonProvider.userDetails!.userRequest!.roles!
            .map((e) => e.tenantId)
            .toSet()
            .toList();
        final result = tenantProvider.tenants!.tenantsList
            ?.where((element) => r.contains(element.code?.trim()))
            .toList();
        if (result?.length == 1 &&
            commonProvider.userDetails!.selectedtenant == null) {
          if (result?.isNotEmpty ?? false)
            commonProvider.setTenant(result?.first);
    
          // });
        } else if (result != null &&
            result.length > 1 &&
            commonProvider.userDetails!.selectedtenant == null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => showDialogBox(result));
        }
      });
    }
  }

    showDialogBox(List<Tenants> tenants) {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    var tenantProvider = Provider.of<TenantsProvider>(navigatorKey.currentContext!, listen: false);
    final r = commonProvider.userDetails!.userRequest!.roles!
        .map((e) => e.tenantId)
        .toSet()
        .toList();
    final res = tenantProvider.tenants!.tenantsList!
        .where((element) => r.contains(element.code?.trim()))
        .toList();
    showDialog(
        barrierDismissible: commonProvider.userDetails!.selectedtenant != null,
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) {
          var searchController = TextEditingController();
          var visibleTenants = tenants.asMap().values.where((element) =>element.city?.districtCode != null).toList();
          return StatefulBuilder(
            builder: (context, StateSetter stateSetter) {
              return Stack(children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width > 720
                            ? MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.width / 3
                            : 0,
                        top: 60),
                    width: MediaQuery.of(context).size.width > 720
                        ? MediaQuery.of(context).size.width / 3
                        : MediaQuery.of(context).size.width,
                    height: (visibleTenants.length * 50 < 300 ?
                    visibleTenants.length * 50 : 300)+ 60,
                    color: Colors.white,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        Material(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: "${ApplicationLocalizations.of(context)
                                    .translate(i18.common.SEARCH)}"
                              ),
                              onChanged: (text) {
                                  if(text.isEmpty){
                                    stateSetter(()=>visibleTenants = tenants.asMap().values.toList()
                                    );
                                  }else{
                                    var tresult = tenants.where((e) => "${ApplicationLocalizations.of(context)
                                        .translate(e.code!)}-${e.city!.code!}".toLowerCase().trim().contains(text.toLowerCase().trim())).toList();
                                    stateSetter(()=>visibleTenants = tresult
                                    );
                                  }
                              },
                            ),
                          ),
                        ),
                        ...List.generate(visibleTenants.length, (index) {
                        return GestureDetector(
                            onTap: () {
                              commonProvider.setTenant(visibleTenants[index]);
                              Navigator.of(context,rootNavigator: true).pop();
                              CommonMethods.home();
                            },
                            child: Material(
                                child: Container(
                              color: index.isEven
                                  ? Colors.white
                                  : Color.fromRGBO(238, 238, 238, 1),
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              padding: EdgeInsets.all(5),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ApplicationLocalizations.of(context)
                                            .translate(visibleTenants[index].code!),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: commonProvider.userDetails!
                                                            .selectedtenant !=
                                                        null &&
                                                    commonProvider
                                                            .userDetails!
                                                            .selectedtenant!
                                                            .city!
                                                            .code ==
                                                        visibleTenants[index].city!.code!
                                                ? Theme.of(context).primaryColor
                                                : Colors.black),
                                      ),
                                      Text(visibleTenants[index].city!.code!,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: commonProvider.userDetails!
                                                              .selectedtenant !=
                                                          null &&
                                                      commonProvider
                                                              .userDetails!
                                                              .selectedtenant!
                                                              .city!
                                                              .code ==
                                                          visibleTenants[index].city!.code!
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.black))
                                    ]),
                              ),
                            )));
                      },growable: true)],
                    ))
              ]);
            }
          );
        });
  }


// App Bar Calls Refreactor


}
