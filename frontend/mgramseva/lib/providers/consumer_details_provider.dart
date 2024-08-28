import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/common/demand.dart';
import 'package:mgramseva/model/connection/property.dart';
import 'package:mgramseva/model/connection/tenant_boundary.dart';
import 'package:mgramseva/model/connection/water_connection.dart' as addition;
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/model/connection/water_connections.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/model/mdms/category_type.dart';
import 'package:mgramseva/model/mdms/connection_type.dart';
import 'package:mgramseva/model/mdms/payment_type.dart';
import 'package:mgramseva/model/mdms/property_type.dart';
import 'package:mgramseva/model/mdms/sub_category_type.dart';
import 'package:mgramseva/model/mdms/tax_period.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/search_connection_provider.dart';
import 'package:mgramseva/repository/billing_service_repo.dart';
import 'package:mgramseva/repository/consumer_details_repo.dart';
import 'package:mgramseva/repository/core_repo.dart';
import 'package:mgramseva/repository/search_connection_repo.dart';
import 'package:mgramseva/screeens/consumer_details/consumer_details_walk_through/walk_through.dart';
import 'package:mgramseva/services/mdms.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/widgets/custom_dialog.dart';
import 'package:mgramseva/widgets/search_select_field_builder.dart';
import 'package:provider/provider.dart';

class ConsumerProvider with ChangeNotifier {
  late List<ConsumerWalkWidgets> consmerWalkthrougList;
  var streamController = StreamController.broadcast();
  late GlobalKey<FormState> formKey;
  var isFirstDemand = false;
  var autoValidation = false;
  int activeIndex = 0;
  late WaterConnection waterconnection;
  var boundaryList = <Boundary>[];
  var categoryList = [];
  var selectedcycle;
  TaxPeriod? billYear;
  var selectedbill;
  late Property property;
  late List dates = [];
  late bool isEdit = false;
  LanguageList? languageList;
  PaymentType? paymentType;
  bool phoneNumberAutoValidation = false;
  GlobalKey<SearchSelectFieldState>? searchPickerKey;

  setModel() async {
    waterconnection.BillingCycleCtrl.text = "";
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    isEdit = false;
    waterconnection = WaterConnection.fromJson({
      "action": "SUBMIT",
      "proposedTaps": 1,
      "proposedPipeSize": 10,
      "noOfTaps": 1
    });

    property = Property.fromJson({
      "landArea": 1,
      "usageCategory": "RESIDENTIAL",
      "creationReason": "CREATE",
      "noOfFloors": 1,
      "source": "WS",
      "channel": "CITIZEN",
      "ownershipCategory": "INDIVIDUAL",
      "owners": [
        Owners.fromJson({
          "ownerType": "NONE",
        }).toJson()
      ],
      "address": Address().toJson()
    });

    if (boundaryList.length == 1) {
      property.address.localityCtrl = boundaryList.first;
      onChangeOfLocality(property.address.localityCtrl);
    }
    if (commonProvider.userDetails?.selectedtenant?.code != null) {
      property.address.gpNameCtrl.text =
          commonProvider.userDetails!.selectedtenant!.code!;
      property.address.gpNameCityCodeCtrl.text =
          commonProvider.userDetails!.selectedtenant!.city!.code!;
    }
  }

  dispose() {
    streamController.close();
    super.dispose();
  }

  void onChangeOfCheckBox(bool? value, BuildContext context) {
    if (value ?? false) showInActiveAlert(context);
    if (value == true)
      waterconnection.status = Constants.CONNECTION_STATUS.first;
    else
      waterconnection.status = Constants.CONNECTION_STATUS[1];
    notifyListeners();
  }

  showInActiveAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: i18.common.ALERT,
          content: i18.consumer.ALL_DEMANDS_REVERSED,
          actions: [
            {'label': i18.common.OK, 'callBack': () => Navigator.pop(context)}
          ],
        );
      },
    );
  }

  Future<void> getWaterConnection(id) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      WaterConnections waterconnections =
          await SearchConnectionRepository().getconnection({
        "tenantId": commonProvider.userDetails!.selectedtenant!.code,
        "connectionNumber": id.split('_').join('/')
      });

      if (waterconnections.waterConnection != null &&
          waterconnections.waterConnection!.isNotEmpty) {
        setWaterConnection(waterconnections.waterConnection?.first);
        fetchBoundary();
        getProperty({
          "tenantId": commonProvider.userDetails?.selectedtenant?.code,
          "propertyIds": waterconnections.waterConnection?.first.propertyId
        });
      }
    } catch (e) {}
  }

  Future<void> setWaterConnection(data) async {
    try {
      await getConnectionTypePropertyTypeTaxPeriod();
      await getPaymentType();
      isEdit = true;
      waterconnection = data;
      waterconnection.getText();
      selectedcycle = {
        'code': DateTime.fromMillisecondsSinceEpoch(
            waterconnection.previousReadingDate!),
        'name':
            "${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(DateFormats.timeStampToDate(waterconnection.previousReadingDate, format: 'MMMM')) + " - " + DateFormats.timeStampToDate(waterconnection.previousReadingDate, format: 'yyyy')}"
      };
      if (waterconnection.previousReadingDate != null &&
          (languageList?.mdmsRes?.billingService?.taxPeriodList?.isNotEmpty ??
              false)) {
        var date = DateTime.fromMillisecondsSinceEpoch(
            waterconnection.previousReadingDate!);
        DatePeriod datePeriod;
        if (date.month > 3)
          datePeriod = DatePeriod(DateTime(date.year, 4),
              DateTime(date.year + 1, 3, 31, 23, 59, 59, 999), DateType.YEAR);
        else
          datePeriod = DatePeriod(DateTime(date.year - 1, 4),
              DateTime(date.year, 3, 31, 23, 59, 59, 999), DateType.YEAR);

        billYear = languageList?.mdmsRes?.billingService?.taxPeriodList
            ?.firstWhere((e) {
          var date = DateTime.fromMillisecondsSinceEpoch(e.fromDate!);
          return date.month == datePeriod.startDate.month &&
              date.year == datePeriod.startDate.year;
        });
      }
      List<Demand>? demand = await ConsumerRepository().getDemandDetails({
        "consumerCode": waterconnection.connectionNo,
        "businessService": "WS",
        "tenantId": waterconnection.tenantId,
        // "status": "ACTIVE"
      });

      var paymentDetails = await BillingServiceRepository().fetchdBillPayments({
        "tenantId": waterconnection.tenantId,
        "consumerCodes": waterconnection.connectionNo,
        "businessService": "WS"
      });

      if (waterconnection.connectionType == 'Metered' &&
          waterconnection.additionalDetails?.meterReading.toString() != '0') {
        var meterReading = waterconnection.additionalDetails?.meterReading
            .toString()
            .padLeft(5, '0');
        waterconnection.om_1Ctrl.text =
            meterReading.toString().characters.elementAt(0);
        waterconnection.om_2Ctrl.text =
            meterReading.toString().characters.elementAt(1);
        waterconnection.om_3Ctrl.text =
            meterReading.toString().characters.elementAt(2);
        waterconnection.om_4Ctrl.text =
            meterReading.toString().characters.elementAt(3);
        waterconnection.om_5Ctrl.text =
            meterReading.toString().characters.elementAt(4);
      }

      demand =
          demand?.where((element) => element.status != 'CANCELLED').toList();

      if (demand?.isEmpty == true) {
        isFirstDemand = false;
      } else if (demand?.length == 1 &&
          demand?.first.consumerType == 'waterConnection-arrears') {
        isFirstDemand = false;
      } else if (demand?.length == 1 &&
          demand?.first.consumerType == 'waterConnection-advance' &&
          demand?.first.demandDetails?.first.taxHeadMasterCode ==
              'WS_ADVANCE_CARRYFORWARD') {
        isFirstDemand = false;
      } else {
        isFirstDemand = true;
      }

      if (paymentDetails.payments != null &&
          paymentDetails.payments!.isNotEmpty) {
        isFirstDemand = true;
      }

      notifyListeners();
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
    }
  }

  Future<void> getConsumerDetails() async {
    try {
      streamController.add(property);
    } catch (e) {
      print(e);
      streamController.addError('error');
    }
  }

  void validateConsumerDetails(context) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    if (formKey.currentState!.validate()) {
      waterconnection.setText();
      property.owners!.first.setText();
      property.address.setText();

      property.tenantId = commonProvider.userDetails!.selectedtenant!.code;
      property.address.city = commonProvider.userDetails!.selectedtenant!.name;
      if (waterconnection.processInstance == null) {
        var processInstance = ProcessInstance();
        processInstance.action = 'SUBMIT';
        waterconnection.processInstance = processInstance;
      }
      waterconnection.tenantId =
          commonProvider.userDetails!.selectedtenant!.code;
      waterconnection.connectionHolders = property.owners;
      waterconnection.noOfTaps = 1;
      waterconnection.propertyType = property.propertyType;
      if (waterconnection.connectionType == 'Metered') {
        waterconnection.meterInstallationDate =
            waterconnection.previousReadingDate;

        // ignore: unrelated_type_equality_checks
        waterconnection.previousReading =
            (waterconnection.om_1Ctrl.text == "" &&
                    waterconnection.om_2Ctrl.text == "" &&
                    waterconnection.om_3Ctrl.text == "" &&
                    waterconnection.om_4Ctrl.text == "" &&
                    waterconnection.om_5Ctrl.text == "")
                ? 0
                : int.parse(waterconnection.om_1Ctrl.text +
                    waterconnection.om_2Ctrl.text +
                    waterconnection.om_3Ctrl.text +
                    waterconnection.om_4Ctrl.text +
                    waterconnection.om_5Ctrl.text);
      } else {
        waterconnection.previousReadingDate =
            waterconnection.meterInstallationDate;
      }

      if (waterconnection.additionalDetails == null) {
        waterconnection.additionalDetails =
            addition.AdditionalDetails.fromJson({
          "locality": property.address.locality?.code,
          "street": property.address.street,
          "doorNo": property.address.doorNo,
          "initialMeterReading": waterconnection.previousReading,
          "propertyType": property.propertyType,
          "meterReading": waterconnection.previousReading,
          "category": waterconnection.categoryCtrl.text.trim().isEmpty
              ? null
              : waterconnection.additionalDetails?.category,
          "subCategory": waterconnection.subCategoryCtrl.text.trim().isEmpty
              ? null
              : waterconnection.additionalDetails?.subCategory,
          "aadharNumber": waterconnection.addharCtrl.text.trim().isEmpty
              ? null
              : waterconnection.addharCtrl.text.trim(),
          "remarks": waterconnection.status == "Inactive" ?  property.owners?.first.remarks : ""
        });
      } else {
        waterconnection.additionalDetails!.locality =
            property.address.locality!.code;
        waterconnection.additionalDetails!.initialMeterReading =
            waterconnection.previousReading;
        waterconnection.additionalDetails!.category =
            waterconnection.categoryCtrl.text.trim().isEmpty
                ? null
                : waterconnection.additionalDetails?.category;
        waterconnection.additionalDetails!.subCategory =
            waterconnection.subCategoryCtrl.text.trim().isEmpty
                ? null
                : waterconnection.additionalDetails?.subCategory;
        waterconnection.additionalDetails!.aadharNumber =
            waterconnection.addharCtrl.text.trim().isEmpty
                ? null
                : waterconnection.addharCtrl.text.trim();
        waterconnection.additionalDetails!.street = property.address.street;
        waterconnection.additionalDetails!.doorNo = property.address.doorNo;
        waterconnection.additionalDetails!.meterReading =
            waterconnection.previousReading;
        waterconnection.additionalDetails!.propertyType = property.propertyType;

        waterconnection.additionalDetails!.remarks =  waterconnection.status == "Inactive" ?
            property.owners?.first.remarks : "";
      }

      try {
        Loaders.showLoadingDialog(context);
        //IF the Consumer Detaisl Screen is in Edit Mode
        if (!isEdit) {
          var result1 =
              await ConsumerRepository().addProperty(property.toJson());
          waterconnection.propertyId =
              result1['Properties'].first!['propertyId'];

          var result2 = await ConsumerRepository()
              .addconnection(waterconnection.toJson());
          if (result2 != null) {
            setModel();
            phoneNumberAutoValidation = false;

            streamController.add(property);
            Notifiers.getToastMessage(
                context, i18.consumer.REGISTER_SUCCESS, 'SUCCESS');
            selectedcycle = null;
            waterconnection.connectionType = '';
            Navigator.pop(context);
          }
        } else {
          property.creationReason = 'UPDATE';
          property.address.geoLocation = GeoLocation();
          property.address.geoLocation?.latitude = null;
          property.address.geoLocation?.longitude = null;
          property.source = 'WS';
          if (waterconnection.status == 'Inactive') {
            waterconnection.paymentType = null;
            waterconnection.penalty = null;
            waterconnection.arrears = null;
            waterconnection.advance = null;
          }

          var result1 =
              await ConsumerRepository().updateProperty(property.toJson());
          var result2 = await ConsumerRepository()
              .updateconnection(waterconnection.toJson());

          if (result2 != null && result1 != null)
            Notifiers.getToastMessage(
                context, i18.consumer.UPDATED_SUCCESS, 'SUCCESS');
          Navigator.of(context,rootNavigator: true).pop();
          CommonMethods.home();
        }
      } catch (e, s) {
        Navigator.of(context,rootNavigator: true).pop();
        ErrorHandler().allExceptionsHandler(context, e, s);
      }
    } else {
      autoValidation = true;
      notifyListeners();
    }
  }

  void onChangeOfGender(String gender, Owners owners) {
    owners.gender = gender;
    notifyListeners();
  }

  void onChangeOfDate(value) {
    notifyListeners();
  }

  Future<void> getConnectionTypePropertyTypeTaxPeriod() async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);

      var dateTime = DateTime.now();
      if (dateTime.month == 4) {
        dateTime = DateTime(dateTime.year, dateTime.month - 1, dateTime.day);
      }

      var res = await CoreRepository().getMdms(
          getConnectionTypePropertyTypeTaxPeriodMDMS(
              commonProvider.userDetails!.userRequest!.tenantId.toString(),
              (DateFormats.dateToTimeStamp(DateFormats.getFilteredDate(
                  dateTime.toLocal().toString())))));
      languageList = res;
    } catch (e) {
      print(e);
    }
  }

  Future<void> getPaymentType() async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    try {
      var res = await CommonProvider.getMdmsBillingService(
          commonProvider.userDetails!.selectedtenant?.code.toString() ??
              commonProvider.userDetails!.userRequest!.tenantId.toString());
      if (res.mdmsRes?.billingService?.taxHeadMasterList != null &&
          res.mdmsRes!.billingService!.taxHeadMasterList!.isNotEmpty) {
        paymentType = res;
      } else {
        var res = await CommonProvider.getMdmsBillingService(
            commonProvider.userDetails!.userRequest!.tenantId.toString());
        paymentType = res;
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<Property?> getProperty(
    Map<String, dynamic> query,
  ) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      var res = await ConsumerRepository().getProperty(query);
      if (res != null)
        property = new Property.fromJson(res['Properties'].first);

      property.owners!.first.getText();
      property.address.getText();

      property.address.localityCtrl = boundaryList.firstWhere(
          (element) => element.code == property.address.locality!.code);
      onChangeOfLocality(property.address.localityCtrl);

      property.address.gpNameCtrl.text =
          commonProvider.userDetails!.selectedtenant!.code!;
      property.address.gpNameCityCodeCtrl.text =
          commonProvider.userDetails!.selectedtenant!.city!.code!;

      streamController.add(property);
      notifyListeners();
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<void> fetchBoundary() async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    try {
      var result = await ConsumerRepository().getLocations({
        "hierarchyTypeCode": "REVENUE",
        "boundaryType": "Locality",
        "tenantId": commonProvider.userDetails!.selectedtenant!.code
      });
      boundaryList = [];
      result['TenantBoundary'] != null && result['TenantBoundary'].length > 0
          ? boundaryList.addAll(
              TenantBoundary.fromJson(result['TenantBoundary'][0]).boundary!)
          : {};
      if (boundaryList.length == 1) {
        property.address.localityCtrl = boundaryList.first;
        onChangeOfLocality(property.address.localityCtrl);
      } else {
        boundaryList.add(Boundary.fromJson({
          "code": "WARD1",
          "name": commonProvider.userDetails!.selectedtenant!.name,
          "label": "Locality",
          "latitude": null,
          "longitude": null,
          "area": null,
          "pincode": null,
          "boundaryNum": 1,
          "children": []
        }));
        property.address.localityCtrl = Locality.fromJson({
          "code": "WARD1",
          "name": commonProvider.userDetails!.selectedtenant!.name,
          "label": "Locality",
          "latitude": null,
          "longitude": null,
          "area": null,
          "pincode": null,
          "boundaryNum": 1,
          "children": []
        });
        onChangeOfLocality(property.address.localityCtrl);
      }
      // notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  void setWalkThrough(value) {
    consmerWalkthrougList = value;
  }

  void onChangeOfLocality(val) {
    property.address.locality ??= Locality();
    property.address.locality?.code = val.code;
    property.address.locality?.area = val.area;
    notifyListeners();
  }

  void onChangeOfCategory(val) {
    waterconnection.additionalDetails ??= addition.AdditionalDetails();
    waterconnection.categoryCtrl.text = val;
    waterconnection.additionalDetails?.category = val;
    notifyListeners();
  }

  void onChangeOfSubCategory(val) {
    waterconnection.additionalDetails ??= addition.AdditionalDetails();
    waterconnection.subCategoryCtrl.text = val;
    waterconnection.additionalDetails?.subCategory = val;
    notifyListeners();
  }

  onChangeOfPropertyType(val) {
    property.propertyType = val;
    notifyListeners();
  }

  List<Boundary> getBoundaryList() {
    if (boundaryList.length > 0) {
      return boundaryList;
    }
    return <Boundary>[];
  }

  List<String> getCategoryList() {
    if (languageList?.mdmsRes?.category != null) {
      return (languageList?.mdmsRes?.category?.categoryList ?? <CategoryType>[])
          .map((value) {
        return value.code!;
      }).toList();
    }
    return <String>[];
  }

  List<String> getSubCategoryList() {
    if (languageList?.mdmsRes?.subCategory != null) {
      return (languageList?.mdmsRes?.subCategory?.subcategoryList ??
              <SubCategoryType>[])
          .map((value) {
        return value.code!;
      }).toList();
    }
    return <String>[];
  }

  List<String> getPropertyTypeList() {
    if (languageList?.mdmsRes?.propertyTax?.PropertyTypeList != null) {
      return (languageList?.mdmsRes?.propertyTax?.PropertyTypeList ??
              <PropertyType>[])
          .map((value) {
        return value.code!;
      }).toList();
    }
    return <String>[];
  }

  onChangeOfConnectionType(val) {
    waterconnection.connectionType = val;
    waterconnection.meterIdCtrl.clear();
    waterconnection.previousReadingDateCtrl.clear();
    billYear = null;
    selectedcycle = null;
    waterconnection.BillingCycleCtrl.clear();
    waterconnection.meterInstallationDateCtrl.clear();
    searchPickerKey?.currentState?.Options.clear();

    notifyListeners();
  }

  onChangeBillingCycle(val) {
    selectedcycle = val;
    DateTime result = DateTime.parse(val['code'].toString());
    waterconnection.previousReadingDateCtrl.clear();
    waterconnection.BillingCycleCtrl.text = result.toLocal().toString();
    waterconnection.meterInstallationDateCtrl.text =
        result.toLocal().toString();
    notifyListeners();
  }

//Displaying ConnectionType data Fetched From MDMD (Ex Metered, Non Metered..)
  List<String> getConnectionTypeList() {
    if (languageList?.mdmsRes?.connection?.connectionTypeList != null) {
      return (languageList?.mdmsRes?.connection?.connectionTypeList ??
              <ConnectionType>[])
          .map((value) {
        return value.code!;
      }).toList();
    }
    return <String>[];
  }

  //Displaying Billing Cycle Vaule (EX- JAN-2021,,)
  List<Map<String, dynamic>> getBillingCycle() {
    var dates = <Map<String, dynamic>>[];
    if (billYear != null) {
      DatePeriod ytd;
      var fromDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(billYear?.fromDate)) as DateTime;

      var toDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(billYear?.toDate)) as DateTime;

      ytd = DatePeriod(fromDate, toDate, DateType.YTD);

      /// Get months based on selected billing year
      var months = CommonMethods.getPastMonthUntilFinancialYTD(ytd);

      /// if selected year is future year means all the months will be removed
      if (fromDate.year > ytd.endDate.year) months.clear();

      for (var i = 0; i < months.length; i++) {
        var prevMonth = months[i].startDate;
        var r = {
          "code": prevMonth,
          "name":
              '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate((Constants.MONTHS[prevMonth.month - 1])) + " - " + prevMonth.year.toString()}'
        };
        dates.add(r);
      }
    }
    if (dates.length > 0 && waterconnection.connectionType == 'Non_Metered') {
      return dates;
    }
    return <Map<String, dynamic>>[];
  }

  //Displaying Billing Cycle Vaule (EX- JAN-2021,,)
  List<Map<String, dynamic>> getBillingCycleMonthCountCurrent(
      TaxPeriod? billYear) {
    var dates = <Map<String, dynamic>>[];
    if (billYear != null) {
      DatePeriod ytd;
      var fromDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(billYear?.fromDate)) as DateTime;

      var toDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(billYear?.toDate)) as DateTime;

      ytd = DatePeriod(fromDate, toDate, DateType.YTD);

      /// Get months based on selected billing year
      var months = CommonMethods.getPastMonthUntilFinancialYTD(ytd);

      /// if selected year is future year means all the months will be removed
      if (fromDate.year > ytd.endDate.year) months.clear();

      for (var i = 0; i < months.length; i++) {
        var prevMonth = months[i].startDate;
        var r = {
          "code": prevMonth,
          "name":
              '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate((Constants.MONTHS[prevMonth.month - 1])) + " - " + prevMonth.year.toString()}'
        };
        dates.add(r);
      }
    }
    if (dates.length > 0 && waterconnection.connectionType == 'Non_Metered') {
      return dates;
    }
    return <Map<String, dynamic>>[];
  }

  incrementIndex(index, consumerGenderKey) async {
    if (boundaryList.length > 1) {
      activeIndex = index + 1;
    } else {
      if (activeIndex == 4) {
        activeIndex = index + 2;
      } else {
        activeIndex = index + 1;
      }
    }
    await Scrollable.ensureVisible(consumerGenderKey.currentContext!,
        duration: new Duration(milliseconds: 100));
  }

  callNotifier() {
    notifyListeners();
  }

  void onChangeOfBillYear(val) {
    billYear = val;
    selectedcycle = null;
    waterconnection.previousReadingDateCtrl.clear();
    waterconnection.BillingCycleCtrl.clear();
    waterconnection.meterInstallationDateCtrl.clear();
    searchPickerKey?.currentState?.Options.clear();
    // waterconnection.billingCycleYearCtrl.text = billYear;
    notifyListeners();
  }

  List<TaxPeriod> getFinancialYearList() {
    if (languageList?.mdmsRes?.billingService?.taxPeriodList != null) {
      CommonMethods.getFilteredFinancialYearList(
          languageList?.mdmsRes?.billingService?.taxPeriodList ??
              <TaxPeriod>[]);
      languageList?.mdmsRes?.billingService?.taxPeriodList!
          .sort((a, b) => a.fromDate!.compareTo(b.fromDate!));
      return (languageList?.mdmsRes?.billingService?.taxPeriodList ??
              <TaxPeriod>[])
          .map((value) {
            return value;
          })
          .toList()
          .reversed
          .toList();
    }
    return <TaxPeriod>[];
  }

  List<TaxPeriod> getLastFinancialYearList(int count) {
    return getFinancialYearList().length > count
        ? getFinancialYearList().sublist(0, count)
        : getFinancialYearList();
  }

  List<Map<String, dynamic>> newBillingCycleFunction({int pastMonthCount = 2}) {
    List<TaxPeriod> financialYears = getFinancialYearList();
    var dates = <Map<String, dynamic>>[];
    financialYears.forEach((year) {
      dates.addAll(getBillingCycleMonthCountCurrent(year));
    });
    dates.sort((a, b) => b['code'].compareTo(a['code']));
    return dates.toList().length > 2
        ? dates.toList().sublist(0, 2)
        : dates.toList();
  }

  void onChangeOfAmountType(value) {
    waterconnection.paymentType = value;

    if (!isEdit) {
      waterconnection.penaltyCtrl.clear();
      waterconnection.advanceCtrl.clear();
      waterconnection.arrearsCtrl.clear();
    } else {}
    notifyListeners();
  }

  List<KeyValue> getPaymentTypeList() {
    if (CommonProvider.getPenaltyOrAdvanceStatus(paymentType, true))
      return Constants.CONSUMER_PAYMENT_TYPE;
    return [Constants.CONSUMER_PAYMENT_TYPE.first];
  }
}
