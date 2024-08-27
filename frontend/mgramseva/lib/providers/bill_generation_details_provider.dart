import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/bill/bill_generation_details/bill_generation_details.dart';
import 'package:mgramseva/model/bill/billing.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/model/demand/demand_list.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/model/mdms/connection_type.dart';
import 'package:mgramseva/model/mdms/property_type.dart';
import 'package:mgramseva/model/mdms/tax_head_master.dart';
import 'package:mgramseva/model/mdms/tax_period.dart';
import 'package:mgramseva/model/success_handler.dart';
import 'package:mgramseva/providers/household_details_provider.dart';
import 'package:mgramseva/repository/bill_generation_details_repo.dart';
import 'package:mgramseva/repository/billing_service_repo.dart';
import 'package:mgramseva/repository/core_repo.dart';
import 'package:mgramseva/repository/search_connection_repo.dart';
import 'package:mgramseva/routers/routers.dart';
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
import 'package:mgramseva/widgets/common_success_page.dart';
import 'package:mgramseva/widgets/error_page.dart';
import 'package:provider/provider.dart';

import 'common_provider.dart';
import 'ifix_hierarchy_provider.dart';

class BillGenerationProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();
  LanguageList? languageList;
  late GlobalKey<FormState> formKey;
  var autoValidation = false;
  late BillGenerationDetails billGenerateDetails;
  var waterconnection = WaterConnection();
  late BillList billList;
  late List dates = [];
  var selectedBillYear;
  var selectedBillPeriod;
  var selectedBillCycle;
  var meterReadingDate;
  var prevReadingDate;
  var readingExist;

  setModel(String? id, WaterConnection? waterConnection,
      BuildContext context) async {
    billGenerateDetails = BillGenerationDetails();
    billGenerateDetails.serviceCat = '10101';

    billGenerateDetails.meterReadingDateCtrl.text =
        DateFormats.timeStampToDate(DateFormats.dateToTimeStamp(
      DateFormats.getFilteredDate(
        DateTime.now().toLocal().toString(),
      ),
    ));
    if (id == null) {
      billGenerateDetails.serviceType = 'Non_Metered';
    } else {
      if (waterConnection == null) {
        var commonProvider = Provider.of<CommonProvider>(
            navigatorKey.currentContext!,
            listen: false);
        id.split('_').join('/');
        try {
          Loaders.showLoadingDialog(context);

          var res = await SearchConnectionRepository().getconnection({
            "tenantId": commonProvider.userDetails!.selectedtenant!.code,
            ...{'connectionNumber': id.split('_').join('/')},
          });
          Navigator.pop(context);
          waterconnection = res.waterConnection!.first;
          billGenerateDetails.propertyType =
              waterconnection.additionalDetails!.propertyType;
          billGenerateDetails.serviceType = waterconnection.connectionType;
          billGenerateDetails.meterNumberCtrl.text = waterconnection.meterId!;
          if (waterconnection.connectionType == 'Metered') {
            waterconnection = res.waterConnection!.first;
            var meterRes = await BillGenerateRepository().searchMeteredDemand({
              "tenantId": commonProvider.userDetails!.selectedtenant!.code,
              ...{'connectionNos': id.split('_').join('/')},
            });
            setMeterReading(meterRes);
          }
        } catch (e, s) {
          Navigator.pop(context);
          ErrorHandler().allExceptionsHandler(context, e, s);
        }
      } else {
        billGenerateDetails.propertyType =
            waterConnection.additionalDetails!.propertyType;
        billGenerateDetails.serviceType = waterConnection.connectionType;
        billGenerateDetails.meterNumberCtrl.text = waterConnection.meterId!;
        waterconnection = waterConnection;
        if (waterconnection.connectionType == 'Metered') {
          var commonProvider = Provider.of<CommonProvider>(
              navigatorKey.currentContext!,
              listen: false);
          var meterRes = await BillGenerateRepository().searchMeteredDemand({
            "tenantId": commonProvider.userDetails!.selectedtenant!.code,
            ...{'connectionNos': id.split('_').join('/')},
          });
          setMeterReading(meterRes);
          if (meterRes.meterReadings!.length == 0) {
            prevReadingDate = waterConnection.previousReadingDate;
          }
        } else {}
      }
    }
  }

  setMeterReading(meterRes) {
    if (meterRes.meterReadings!.length > 0 &&
        meterRes.meterReadings!.first.currentReading != null) {
      readingExist = false;
      var previousMeterReading = meterRes.meterReadings!.first.currentReading
          .toString()
          .padLeft(5, '0');
      billGenerateDetails.meterNumberCtrl.text = waterconnection.meterId!;
      billGenerateDetails.om_1Ctrl.text = previousMeterReading.toString()[0];
      billGenerateDetails.om_2Ctrl.text = previousMeterReading.toString()[1];
      billGenerateDetails.om_3Ctrl.text = previousMeterReading.toString()[2];
      billGenerateDetails.om_4Ctrl.text = previousMeterReading.toString()[3];
      billGenerateDetails.om_5Ctrl.text = previousMeterReading.toString()[4];
      var readDate = DateTime.fromMillisecondsSinceEpoch(
          meterRes.meterReadings!.first.currentReadingDate);
      var reqDate = readDate.add(Duration(days: 1)).toLocal().toString();
      prevReadingDate = DateFormats.dateToTimeStamp(
          DateFormats.getFilteredDate(reqDate, dateFormat: 'dd/MM/yyyy'));
    } else {
      readingExist = false;
      var previousMeterReading = waterconnection.additionalDetails!.meterReading
          .toString()
          .padLeft(5, '0');
      billGenerateDetails.om_1Ctrl.text = previousMeterReading.toString()[0];
      billGenerateDetails.om_2Ctrl.text = previousMeterReading.toString()[1];
      billGenerateDetails.om_3Ctrl.text = previousMeterReading.toString()[2];
      billGenerateDetails.om_4Ctrl.text = previousMeterReading.toString()[3];
      billGenerateDetails.om_5Ctrl.text = previousMeterReading.toString()[4];
      prevReadingDate = waterconnection.previousReadingDate;
    }
    notifyListeners();
  }

  dispose() {
    streamController.close();
    super.dispose();
  }

  onChangeOfServiceType(val) {
    billGenerateDetails.serviceType = val;
    notifyListeners();
  }

  onChangeOfServiceCat(val) {
    billGenerateDetails.serviceCat = val;
    notifyListeners();
  }

  onChangeOfProperty(val) {
    billGenerateDetails.propertyType = val;
    notifyListeners();
  }

  void onChangeOfBillYear(val) {
    selectedBillYear = val;
    billGenerateDetails.billYear = selectedBillYear;
    notifyListeners();
  }

  void clearBillYear() {
    selectedBillYear = null;
    billGenerateDetails.billYear = null;
    selectedBillCycle = null;
    billGenerateDetails.billCycle = null;
    selectedBillPeriod = null;
    notifyListeners();
  }

  void onChangeOfBillCycle(cycle) {
    var val = cycle['code'];
    DateTime result = DateTime.parse(val.toString());
    selectedBillCycle = cycle;
    selectedBillPeriod = (DateFormats.getFilteredDate(
            result.toLocal().toString(),
            dateFormat: "dd/MM/yyyy")) +
        "-" +
        DateFormats.getFilteredDate(
            (new DateTime(result.year, result.month + 1, 0))
                .toLocal()
                .toString(),
            dateFormat: "dd/MM/yyyy");
    billGenerateDetails.billCycle = result.toLocal().toString();
    notifyListeners();
  }

  void onChangeOfDate(value) {
    notifyListeners();
  }

  void onClickOfCollectPayment(Bill bill, BuildContext context) {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);

    Map<String, dynamic> query = {
      'consumerCode': bill.consumerCode,
      'businessService': bill.businessService,
      'tenantId': commonProvider.userDetails?.selectedtenant?.code,
      'connectionType': waterconnection.connectionType
    };
    Navigator.pushNamed(context, Routes.HOUSEHOLD_DETAILS_COLLECT_PAYMENT,
        arguments: query);
  }

  Future<void> getServiceTypePropertyTypeandConnectionType() async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      var res = await CoreRepository().getMdms(
          getServiceTypeConnectionTypePropertyTypeMDMS(
              commonProvider.userDetails!.userRequest!.tenantId.toString()));
      languageList = res;
      notifyListeners();
      streamController.add(billGenerateDetails);
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
    }
  }

  void onSubmit(context) async {
    if (formKey.currentState!.validate() &&
        billGenerateDetails.serviceType == "Metered") {
      if (billGenerateDetails.om_1Ctrl.text.isEmpty ||
          billGenerateDetails.om_2Ctrl.text.isEmpty ||
          billGenerateDetails.om_3Ctrl.text.isEmpty ||
          billGenerateDetails.om_4Ctrl.text.isEmpty ||
          billGenerateDetails.om_5Ctrl.text.isEmpty) {
        Notifiers.getToastMessage(
            context, i18.demandGenerate.OLD_METER_READING_INVALID, 'ERROR');
      } else if (billGenerateDetails.nm_1Ctrl.text.isEmpty ||
          billGenerateDetails.nm_2Ctrl.text.isEmpty ||
          billGenerateDetails.nm_3Ctrl.text.isEmpty ||
          billGenerateDetails.nm_4Ctrl.text.isEmpty ||
          billGenerateDetails.nm_5Ctrl.text.isEmpty) {
        Notifiers.getToastMessage(
            context, i18.demandGenerate.NEW_METER_READING_INVALID, 'ERROR');
      } else {
        var oldMeter = billGenerateDetails.om_1Ctrl.text +
            billGenerateDetails.om_2Ctrl.text +
            billGenerateDetails.om_3Ctrl.text +
            billGenerateDetails.om_4Ctrl.text +
            billGenerateDetails.om_5Ctrl.text;
        var newMeter = billGenerateDetails.nm_1Ctrl.text +
            billGenerateDetails.nm_2Ctrl.text +
            billGenerateDetails.nm_3Ctrl.text +
            billGenerateDetails.nm_4Ctrl.text +
            billGenerateDetails.nm_5Ctrl.text;
        if (int.parse(oldMeter) < int.parse(newMeter)) {
          try {
            Loaders.showLoadingDialog(context);
            var commonProvider = Provider.of<CommonProvider>(
                navigatorKey.currentContext!,
                listen: false);
            var res1 = {
              "meterReadings": {
                "currentReading": int.parse(newMeter),
                "currentReadingDate": DateFormats.dateToTimeStamp(
                    billGenerateDetails.meterReadingDateCtrl.text),
                "billingPeriod":
                    "${DateFormats.timeStampToDate(prevReadingDate)} - ${DateFormats.timeStampToDate(DateFormats.dateToTimeStamp(billGenerateDetails.meterReadingDateCtrl.text))}",
                "meterStatus": "Working",
                "connectionNo": waterconnection.connectionNo,
                "lastReading": int.parse(oldMeter),
                "lastReadingDate": prevReadingDate,
                "generateDemand": true,
                "tenantId": commonProvider.userDetails!.selectedtenant!.code
              }
            };
            var billResponse1 =
                await BillGenerateRepository().calculateMeterConnection(res1);
            await BillingServiceRepository().fetchBill({
              "tenantId": commonProvider.userDetails!.selectedtenant!.code,
              "consumerCode": waterconnection.connectionNo.toString(),
              "businessService": "WS"
            }).then((value) => billList = value);
            Navigator.pop(context);
            late String localizationText;
            localizationText =
                '${ApplicationLocalizations.of(context).translate(i18.demandGenerate.GENERATE_BILL_SUCCESS_SUBTEXT)}';
            localizationText = localizationText.replaceFirst(
                '{number}', '(+91 - ${billList.bill!.first.mobileNumber})');
            Navigator.of(context).pushReplacement(
                new MaterialPageRoute(builder: (BuildContext context) {
              return CommonSuccess(
                SuccessHandler(
                    ApplicationLocalizations.of(context)
                        .translate(i18.demandGenerate.GENERATE_BILL_SUCCESS),
                    localizationText,
                    ApplicationLocalizations.of(context)
                        .translate(i18.common.COLLECT_PAYMENT),
                    Routes.BILL_GENERATE,
                    downloadLink: '',
                    downloadLinkLabel: ApplicationLocalizations.of(context)
                        .translate(i18.common.DOWNLOAD),
                    whatsAppShare: '',
                    subHeader:
                        '${ApplicationLocalizations.of(context).translate(i18.demandGenerate.BILL_ID_NO)}',
                    subHeaderText:
                        '${billList.bill!.first.billNumber.toString()}'),
                callBack: () =>
                    onClickOfCollectPayment(billList.bill!.first, context),
                callBackDownload: () async {
                  var hhp = Provider.of<HouseHoldProvider>(
                      navigatorKey.currentContext!,
                      listen: false);
                  // if (hhp.aggDemandItems == null) {
                  await BillingServiceRepository().fetchAggregateDemand({
                    "tenantId":
                        commonProvider.userDetails!.selectedtenant!.code,
                    "consumerCode":
                        billList.bill?.first.consumerCode.toString(),
                    "businessService": "WS",
                  }).then((AggragateDemandDetails? value) {
                    if (value != null) {
                      hhp.aggDemandItems = value;
                      notifyListeners();
                    }
                  });
                  // }
                  return commonProvider.getFileFromPDFBillService({
                    "BillAndDemand": {
                      "Bill": [billList.bill?.first],
                      "AggregatedDemands": hhp.aggDemandItems
                    }
                  }, {
                    "key": waterconnection.connectionType == 'Metered'
                        ? "ws-bill-v2"
                        : "ws-bill-nm-v2",
                    "tenantId":
                        commonProvider.userDetails!.selectedtenant!.code,
                  }, billList.bill!.first.mobileNumber, billList.bill!.first,
                      "Download");
                },
                callBackWhatsApp: () async {
                  var hhp = Provider.of<HouseHoldProvider>(
                      navigatorKey.currentContext!,
                      listen: false);
                  // if (hhp.aggDemandItems == null) {
                  await BillingServiceRepository().fetchAggregateDemand({
                    "tenantId":
                        commonProvider.userDetails!.selectedtenant!.code,
                    "consumerCode":
                        billList.bill?.first.consumerCode.toString(),
                    "businessService": "WS",
                  }).then((AggragateDemandDetails? value) {
                    if (value != null) {
                      hhp.aggDemandItems = value;
                      notifyListeners();
                    }
                  });
                  // }
                  return commonProvider.getFileFromPDFBillService({
                    "BillAndDemand": {
                      "Bill": [billList.bill?.first],
                      "AggregatedDemands": hhp.aggDemandItems
                    }
                  }, {
                    "key": waterconnection.connectionType == 'Metered'
                        ? "ws-bill-v2"
                        : "ws-bill-nm-v2",
                    "tenantId":
                        commonProvider.userDetails!.selectedtenant!.code,
                  }, billList.bill!.first.mobileNumber, billList.bill!.first,
                      "Share");
                },
                backButton: true,
              );
            }));
          } catch (e) {
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(
                new MaterialPageRoute(builder: (BuildContext context) {
              return ErrorPage(e.toString());
            }));
          }
        } else {
          Notifiers.getToastMessage(
              context, i18.demandGenerate.NEW_METER_READING_INVALID, 'ERROR');
        }
      }
    } else if (formKey.currentState!.validate() &&
        billGenerateDetails.serviceType == "Non_Metered") {
      var rateProvider = Provider.of<IfixHierarchyProvider>(
          navigatorKey.currentContext!,
          listen: false);
      var rate = rateProvider.wcBillingSlabs!.wCBillingSlabs!
          .where((element) => element.connectionType == 'Non_Metered')
          .toList();
      if (selectedBillPeriod != null) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  surfaceTintColor: Colors.white,
                  title: Text(
                      '${ApplicationLocalizations.of(context).translate(i18.common.CORE_CONFIRM)}'),
                  content: Container(
                    height: 370,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${ApplicationLocalizations.of(context).translate(i18.demandGenerate.ARE_YOU_SURE_TO_GENERATE_DEMAND_FOR)} "${ApplicationLocalizations.of(context).translate(billGenerateDetails.serviceType!)}" ${ApplicationLocalizations.of(context).translate(i18.demandGenerate.WITH_MINIMUM_CHARGE_OF)} : '),
                        SizedBox(
                          height: 10,
                        ),
                        FittedBox(
                          child: DataTable(
                            border: TableBorder.all(
                              width: 0.5,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              color: Colors.grey,
                            ),
                            columns: [
                              DataColumn(
                                  label: Text(
                                "${ApplicationLocalizations.of(context).translate(i18.searchWaterConnection.CONNECTION_TYPE)}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text(
                                "${ApplicationLocalizations.of(context).translate(i18.common.RATE_PERCENTAGE)}",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                            ],
                            rows: [
                              ...rate
                                  .map((e) => DataRow(cells: [
                                        DataCell(Text(
                                            "${ApplicationLocalizations.of(context).translate("${e.buildingType}")}")),
                                        DataCell(Text("${e.minimumCharge}"))
                                      ]))
                                  .toList()
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            '${ApplicationLocalizations.of(context).translate(i18.demandGenerate.NO_DEMAND_GEN_WITH_RATE_0)}'), //* Note : No Demand will be generated for the Service Type with rate set to 0.
                      ],
                    ),
                  ),
                  actions: (rateProvider.wcBillingSlabs!.wCBillingSlabs!
                                  .where((element) =>
                                      element.connectionType == 'Non_Metered')
                                  .length -
                              rateProvider.wcBillingSlabs!.wCBillingSlabs!
                                  .where((element) =>
                                      element.connectionType == 'Non_Metered' &&
                                      element.minimumCharge == 0)
                                  .length ==
                          0)
                      ? [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                  '${ApplicationLocalizations.of(context).translate(i18.consumerReciepts.CLOSE)}'))
                        ]
                      : [
                          TextButton(
                              onPressed: () async {
                                if (rateProvider.wcBillingSlabs!.wCBillingSlabs!
                                            .where((element) =>
                                                element.connectionType ==
                                                'Non_Metered')
                                            .length -
                                        rateProvider
                                            .wcBillingSlabs!.wCBillingSlabs!
                                            .where((element) =>
                                                element.connectionType ==
                                                    'Non_Metered' &&
                                                element.minimumCharge == 0)
                                            .length ==
                                    0) {
                                  Navigator.pop(context);
                                  Notifiers.getToastMessage(
                                      context,
                                      '${ApplicationLocalizations.of(context).translate(i18.demandGenerate.NO_SERVICE_PRESENT_WITH_RATE_MORE_THAN_0)}',
                                      'ERROR'); //No Service type present with rate more than 0.
                                  return;
                                }
                                try {
                                  Loaders.showLoadingDialog(context);
                                  var commonProvider =
                                      Provider.of<CommonProvider>(
                                          navigatorKey.currentContext!,
                                          listen: false);
                                  var res2 = {
                                    "tenantId": commonProvider
                                        .userDetails!.selectedtenant!.code,
                                    "billingPeriod": selectedBillPeriod
                                  };
                                  var billResponse2 =
                                      await BillGenerateRepository()
                                          .bulkDemand(res2);
                                  Navigator.pop(context);
                                  String localizationText =
                                      getSubtitleText(context);
                                  Navigator.of(context).pushReplacement(
                                      new MaterialPageRoute(
                                          builder: (BuildContext context) {
                                    return CommonSuccess(SuccessHandler(
                                        ApplicationLocalizations.of(context)
                                            .translate(i18.demandGenerate
                                                .GENERATE_DEMAND_SUCCESS),
                                        localizationText,
                                        i18.common.BACK_HOME,
                                        Routes.BILL_GENERATE,
                                        subHeader:
                                            '${ApplicationLocalizations.of(context).translate(i18.demandGenerate.BILLING_CYCLE_LABEL)}',
                                        subTextFun: () =>
                                            getLocalizedText(context),
                                        subtitleFun: () =>
                                            getSubtitleText(context)));
                                  }));
                                } catch (e) {
                                  Navigator.of(context).pushReplacement(
                                      new MaterialPageRoute(
                                          builder: (BuildContext context) {
                                    return ErrorPage(e.toString());
                                  }));
                                }
                              },
                              child: Text(
                                  '${ApplicationLocalizations.of(context).translate(i18.common.YES)}')),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                  '${ApplicationLocalizations.of(context).translate(i18.common.NO)}')),
                        ],
                ));
      } else {
        Notifiers.getToastMessage(
            context,
            '${ApplicationLocalizations.of(context).translate(i18.common.SELECT_BILLING_CYCLE)}',
            'ERROR'); //Please select billing cycle
      }
    } else {
      autoValidation = true;
      notifyListeners();
    }
  }

  String getSubtitleText(BuildContext context) {
    late String localizationText;

    localizationText =
        '${ApplicationLocalizations.of(context).translate(i18.demandGenerate.GENERATE_DEMAND_SUCCESS_SUBTEXT)}';
    localizationText = localizationText.replaceFirst(
        '{billing cycle}',
        '${ApplicationLocalizations.of(context).translate(selectedBillCycle['name'].toString())} | ' +
            ' ${selectedBillYear.financialYear!.toString().substring(2)}');
    return localizationText;
  }

  String getLocalizedText(BuildContext context) {
    return '${ApplicationLocalizations.of(context).translate(selectedBillCycle['name'])} | ' +
        ' ${selectedBillYear.financialYear!.toString().substring(2)}';
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

  List<String> getServiceCategoryList() {
    if (languageList?.mdmsRes?.billingService?.taxHeadMasterList != null) {
      return (languageList?.mdmsRes?.billingService?.taxHeadMasterList ??
              <TaxHeadMaster>[])
          .map((value) {
        return value.code!;
      }).toList();
    }
    return <String>[];
  }

  List<Map<String, dynamic>> getBillingCycle() {
    var dates = <Map<String, dynamic>>[];
    if (billGenerateDetails.billYear != null && selectedBillYear != null) {
      DatePeriod ytd;
      var fromDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(selectedBillYear.fromDate)) as DateTime;

      var toDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(selectedBillYear.toDate)) as DateTime;

      ytd = DatePeriod(fromDate, toDate, DateType.YTD);

      /// Get months based on selected billing year
      var months = CommonMethods.getPastMonthUntilFinancialYTD(ytd);

      /// if selected year is future year means all the months will be removed
      if (fromDate.year > ytd.endDate.year) months.clear();

      for (var i = 0; i < months.length; i++) {
        var prevMonth = months[i].startDate;
        Map<String, dynamic> r = {
          "code": prevMonth,
          "name":
              "${ApplicationLocalizations.of(navigatorKey.currentContext!).translate((Constants.MONTHS[prevMonth.month - 1])) + " - " + prevMonth.year.toString()}"
        };
        dates.add(r);
      }
    }
    if (dates.length > 0) {
      return dates;
    }
    return <Map<String, dynamic>>[];
  }
}
