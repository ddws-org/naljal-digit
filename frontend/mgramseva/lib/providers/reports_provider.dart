import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/reports/InactiveConsumerReportData.dart';
import 'package:mgramseva/model/reports/leadger_report.dart';
import 'package:mgramseva/model/reports/monthly_ledger_data.dart';
import 'package:mgramseva/model/reports/vendor_report_data.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../model/common/BillsTableData.dart';
import '../model/localization/language.dart';
import '../model/mdms/tax_period.dart';
import '../model/reports/WaterConnectionCount.dart';
import '../model/reports/bill_report_data.dart';
import '../model/reports/collection_report_data.dart';
import '../model/reports/expense_bill_report_data.dart';
import '../repository/core_repo.dart';
import '../repository/reports_repo.dart';
import '../utils/common_methods.dart';
import '../utils/constants.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import '../utils/date_formats.dart';
import '../utils/error_logging.dart';
import 'package:mgramseva/utils/excel_download/save_file_mobile.dart'
    if (dart.library.html) 'package:mgramseva/utils/excel_download/save_file_web.dart';
import '../utils/global_variables.dart';
import '../utils/localization/application_localizations.dart';
import '../utils/models.dart';
import 'common_provider.dart';
import 'package:mgramseva/services/mdms.dart' as mdms;

class ReportsProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();
  LanguageList? billingYearList;
  var selectedBillYear;
  var selectedBillPeriod;
  var selectedBillCycle;
  var consumerCode = '';
  var billingyearCtrl = TextEditingController();
  var billingcycleCtrl = TextEditingController();
  List<BillReportData>? demandreports;
  List<LedgerData>? ledgerReport;
  List<CollectionReportData>? collectionreports;
  List<InactiveConsumerReportData>? inactiveconsumers;
  List<ExpenseBillReportData>? expenseBillReportData;
  List<VendorReportData>? vendorReportData;
  List<MonthReportData>? monthlyLedgerReport;
  WaterConnectionCountResponse? waterConnectionCount;
  BillsTableData genericTableData = BillsTableData([], []);

  int limit = 10;
  int offset = 1;

  void clearBillingSelection() {
    selectedBillYear = null;
    selectedBillPeriod = null;
    selectedBillCycle = null;
    billingcycleCtrl.clear();
    billingyearCtrl.clear();
    demandreports = [];
    ledgerReport = [];
    collectionreports = [];
    inactiveconsumers = [];
    expenseBillReportData = [];
    vendorReportData = [];
    notifyListeners();
  }

  void clearTableData() {
    genericTableData = BillsTableData([], []);
    notifyListeners();
  }

  void updateConsumerCode(val) {
    consumerCode = val;
    notifyListeners();
  }

  void updateDefaultDate() {
    onChangeOfBillYear(getFinancialYearListDropdown(billingYearList).first);
  }

  dispose() {
    streamController.close();
    super.dispose();
  }

  List<TableHeader> get demandHeaderList => [
        TableHeader(i18.common.CONNECTION_ID),
        TableHeader(
          i18.consumer.OLD_CONNECTION_ID,
          isSortingRequired: false,
        ),
        TableHeader(i18.common.NAME),
        TableHeader('Consumer Created On Date'),
        TableHeader(i18.billDetails.CORE_PENALTY),
        TableHeader(i18.common.CORE_ADVANCE),
        TableHeader(i18.billDetails.TOTAL_AMOUNT),
      ];
  List<TableHeader> get leadgerHeaderList => [
        TableHeader(i18.common.LEDGER_MONTH),
        TableHeader(i18.common.LEDGER_DEMAND_GENERATION_DATE),
        TableHeader(i18.common.LEDGER_MONTHLY_CHARGE),
        TableHeader(i18.common.LEDGER_PREV_MONTH_BALANCE),
        TableHeader(i18.common.LEDGER_TOTAL_DUE),
        TableHeader(i18.common.LEDGER_DUE_DATE_PAYMENT),
        TableHeader(i18.common.LEDGER_DATE),
        TableHeader(i18.common.LEDGER_RECIPET_NO),
        TableHeader(i18.common.LEDGER_AMOUNT),
        TableHeader(i18.common.LEDGER_BALANCE),
        TableHeader(i18.common.LEDGER_PENALTY_APPLIED_ON_DATE),
        TableHeader(i18.common.LEDGER_PENALTY),
        TableHeader(i18.common.LEDGER_BALANCE_FOR_THE_MONH),
      ];

  List<TableHeader> get monthlyLedgerReportHeaderList => [
        TableHeader(i18.consumer.ML_NEW_CONN_ID),
        TableHeader(i18.consumer.ML_SR_NO),
        TableHeader(i18.consumer.ML_OLD_CONN_ID),
        TableHeader(i18.consumer.ML_CONSUMER_NAME),
        TableHeader(i18.consumer.ML_CONSUMER_ENTERED_DATA),
        TableHeader(i18.consumer.ML_PREV_OUTSTANDING_TILL_LAST_MONTH),
        TableHeader(i18.consumer.ML_ADV_AMOUNT_RECEIVED),
        TableHeader(i18.consumer.ML_CURR_MONTH_PENALTY),
        TableHeader(i18.consumer.ML_BILL_GENERATED_FOR_MONTH),
        TableHeader(i18.consumer.ML_DATE_OF_GENERATED),
        TableHeader(i18.consumer.ML_TOTAL_AMOUNT),
        TableHeader(i18.consumer.ML_AMOUNT_COLLECT_AGAINST_TOTAL),
        TableHeader(i18.consumer.ML_DATE_OF_AMOUNT_COLLECTED),
        TableHeader(i18.consumer.ML_REMAINING_AMOUNT_TO_BE_COLLECTED),
        // TableHeader(i18.common.ML_SURPLUS_AMOUNT_COLLECETD),
      ];

  List<TableHeader> get collectionHeaderList => [
        TableHeader(i18.common.CONNECTION_ID),
        TableHeader(
          i18.consumer.OLD_CONNECTION_ID,
          isSortingRequired: false,
        ),
        TableHeader(i18.common.NAME),
        TableHeader(i18.common.PAYMENT_METHOD),
        TableHeader(i18.billDetails.TOTAL_AMOUNT),
      ];
  List<TableHeader> get inactiveConsumerHeaderList => [
        TableHeader(i18.common.CONNECTION_ID),
        TableHeader(i18.common.STATUS),
        TableHeader(i18.common.INACTIVATED_DATE),
        TableHeader(i18.common.INACTIVATED_BY_NAME),
      ];
  List<TableHeader> get expenseBillReportHeaderList => [
        TableHeader(i18.expense.EXPENSE_TYPE),
        TableHeader(i18.expense.VENDOR_NAME),
        TableHeader(i18.expense.AMOUNT),
        TableHeader(i18.expense.BILL_DATE),
        TableHeader(i18.expense.EXPENSE_START_DATE),
        TableHeader(i18.expense.EXPENSE_END_DATE),
        TableHeader(i18.expense.APPLICATION_STATUS),
        TableHeader(i18.expense.PAID_DATE),
        TableHeader(i18.expense.HAS_ATTACHMENT),
        TableHeader(i18.expense.CANCELLED_TIME),
        TableHeader(i18.expense.CANCELLED_BY),
      ];

  List<TableHeader> get vendorReportHeaderList => [
        TableHeader(i18.common.BILL_ID),
        TableHeader(i18.expense.VENDOR_NAME),
        TableHeader(i18.common.MOBILE_NUMBER),
        TableHeader(i18.expense.EXPENSE_TYPE),
      ];

  void onChangeOfPageLimit(
      PaginationResponse response, String type, BuildContext context) {
    if (type == i18.dashboard.BILL_REPORT) {
      getDemandReport(limit: response.limit, offset: response.offset);
    }
    if (type == i18.dashboard.COLLECTION_REPORT) {
      getCollectionReport(limit: response.limit, offset: response.offset);
    }
    if (type == i18.dashboard.INACTIVE_CONSUMER_REPORT) {
      getInactiveConsumerReport(limit: response.limit, offset: response.offset);
    }
    if (type == i18.dashboard.EXPENSE_BILL_REPORT) {
      getExpenseBillReport(limit: response.limit, offset: response.offset);
    }
    if (type == i18.dashboard.VENDOR_REPORT) {
      getVendorReport(limit: response.limit, offset: response.offset);
    }
    if (type == i18.dashboard.LEDGER_REPORTS) {
      getLeadgerReport(limit: response.limit, offset: response.offset);
    }
    if (type == i18.dashboard.MONTHLY_LEDGER_REPORT_LABEL) {
      getMonthlyLedgerReport(limit: response.limit, offset: response.offset);
    }
  }

  List<TableDataRow> getDemandsData(List<BillReportData> list,
      {isExcel = false}) {
    return list.map((e) => getDemandRow(e, isExcel: isExcel)).toList();
  }

  List<TableDataRow> getLedgerData(List<LedgerData> list, {isExcel = false}) {
    return list.map((e) => getLedgerRow(e, isExcel: isExcel)).toList();
  }

  String formatYearMonth(String inputString) {
    final length = inputString.length;
    if (length < 4) {
      return inputString; // Return the original string if length is less than 4
    } else {
      return inputString.substring(0, length - 4) +
          ' - ' +
          inputString.substring(length - 4);
    }
  }

  String formatPaymentReceipts(List<LeadgerPayment>? payments) {
    return payments?.map((payment) => payment.receiptNo)?.join(', ') ?? '';
  }

  TableDataRow getLedgerRow(LedgerData data, {bool isExcel = false}) {

    return TableDataRow([
      TableData(
        formatYearMonth('${data.months?.values.first.demand?.month}'),
      ),
      TableData(
          '${DateFormats.leadgerTimeStampToDate(data.months?.values.first.demand?.demandGenerationDate)}'),
      TableData('₹ ${data.months?.values.first.demand?.monthlyCharges}'),
      TableData('₹ ${data.months?.values.first.demand?.previousMonthBalance}'),
      TableData('₹ ${(data.months?.values.first.demand?.monthlyCharges ?? 0) + (data.months?.values.first.demand?.previousMonthBalance ?? 0) }'),
      TableData(
          '${DateFormats.leadgerTimeStampToDate(data.months?.values.first.demand?.dueDateOfPayment)}'),
      TableData(
          '${DateFormats.leadgerTimeStampToDate(data.months?.values.first.payment?.first.paymentCollectionDate)}'),
      // TableData('${data.months?.values.first.payment?.first.receiptNo}'),
      TableData('${formatPaymentReceipts(data.months?.values?.first.payment)}'),
      TableData('₹ ${data.months?.values.first.totalPaymentInMonth}'),
      TableData(
          '₹ ${(double.parse("${(data.months?.values.first.demand?.monthlyCharges ?? 0) + (data.months?.values.first.demand?.previousMonthBalance ?? 0)}") - double.parse("${data.months?.values.first.totalPaymentInMonth}"))}'),
      TableData(
          '${DateFormats.leadgerTimeStampToDate(data.months?.values.first.demand?.penaltyAppliedOnDate)}'),
      TableData('₹  ${data.months?.values.first.demand?.penalty}'),
      TableData('₹ ${((double.parse("${(data.months?.values.first.demand?.monthlyCharges ?? 0) + (data.months?.values.first.demand?.previousMonthBalance ?? 0)}") - double.parse("${data.months?.values.first.totalPaymentInMonth}"))) + double.parse("${data.months?.values.first.demand?.penalty}")}'),
    ]);
  }

  TableDataRow getDemandRow(BillReportData data, {bool isExcel = false}) {
    String? name = CommonMethods.truncateWithEllipsis(20, data.consumerName!);
    return TableDataRow([
      TableData(
        isExcel
            ? '${data.connectionNo ?? '-'}'
            : '${data.connectionNo?.split('/').first ?? ''}/...${data.connectionNo?.split('/').last ?? ''}',
      ),
      TableData(
          '${(data.oldConnectionNo == null ? null : data.oldConnectionNo!.isEmpty ? null : data.oldConnectionNo) ?? '-'}'),
      TableData('${name ?? '-'}'),
      TableData(
          '${DateFormats.timeStampToDate(int.parse(data.consumerCreatedOnDate ?? '0'))}'),
      TableData('${data.penalty ?? '0'}'),
      TableData('${data.advance ?? '0'}'),
      TableData('${data.demandAmount ?? '0'}'),
    ]);
  }

  List<TableDataRow> getCollectionData(List<CollectionReportData> list,
      {bool isExcel = false}) {
    return list.map((e) => getCollectionRow(e, isExcel: isExcel)).toList();
  }

  TableDataRow getCollectionRow(CollectionReportData data,
      {bool isExcel = false}) {
    String? name = CommonMethods.truncateWithEllipsis(20, data.consumerName!);
    if (data.oldConnectionNo != null && data.oldConnectionNo!.isEmpty) {
      data.oldConnectionNo = '-';
    }
    return TableDataRow([
      TableData(
        isExcel
            ? '${data.connectionNo ?? '-'}'
            : '${data.connectionNo?.split('/').first ?? ''}/...${data.connectionNo?.split('/').last ?? ''}',
      ),
      TableData(
          '${(data.oldConnectionNo == null ? null : data.oldConnectionNo!.isEmpty ? null : data.oldConnectionNo) ?? '-'}'),
      TableData('${name ?? '-'}'),
      TableData('${data.paymentMode ?? '-'}'),
      TableData('${data.paymentAmount ?? '0'}'),
    ]);
  }

  List<TableDataRow> getInactiveConsumersData(
      List<InactiveConsumerReportData> list,
      {bool isExcel = false}) {
    return list
        .map((e) => getInactiveConsumersDataRow(e, isExcel: isExcel))
        .toList();
  }

  TableDataRow getInactiveConsumersDataRow(InactiveConsumerReportData data,
      {bool isExcel = false}) {
    String? inactivatedBy =
        CommonMethods.truncateWithEllipsis(20, data.inactivatedByName!);
    if (data.connectionNo != null && data.connectionNo!.isEmpty) {
      data.connectionNo = '-';
    }
    var inactivatedDate = DateFormats.timeStampToDate(
        data.inactiveDate?.toInt(),
        format: "dd/MM/yyyy");
    return TableDataRow([
      TableData(
        isExcel
            ? '${data.connectionNo ?? '-'}'
            : '${data.connectionNo?.split('/').first ?? ''}/...${data.connectionNo?.split('/').last ?? ''}',
      ),
      TableData('${data.status ?? '-'}'),
      TableData('${inactivatedDate ?? '-'}'),
      TableData('${inactivatedBy ?? '-'}'),
    ]);
  }

  List<TableDataRow> getExpenseBillReportData(List<ExpenseBillReportData> list,
      {bool isExcel = false}) {
    return list
        .map((e) => getExpenseBillReportDataRow(e, isExcel: isExcel))
        .toList();
  }

  TableDataRow getExpenseBillReportDataRow(ExpenseBillReportData data,
      {bool isExcel = false}) {
    String? vendorName =
        CommonMethods.truncateWithEllipsis(20, data.vendorName!);
    String? typeOfExpense =
        CommonMethods.truncateWithEllipsis(20, data.typeOfExpense!);
    String? applicationStatus =
        CommonMethods.truncateWithEllipsis(20, data.applicationStatus!);
    String? lastModifiedBy =
        CommonMethods.truncateWithEllipsis(20, data.lastModifiedBy!);
    String? fileLink =
        CommonMethods.truncateWithEllipsis(20, data.filestoreid!);
    var billDate = DateFormats.timeStampToDate(data.billDate?.toInt(),
        format: "dd/MM/yyyy");
    var taxPeriodFrom = DateFormats.timeStampToDate(data.taxPeriodFrom?.toInt(),
        format: "dd/MM/yyyy");
    var taxPeriodTo = DateFormats.timeStampToDate(data.taxPeriodTo?.toInt(),
        format: "dd/MM/yyyy");
    var paidDate = data.paidDate == 0
        ? '-'
        : DateFormats.timeStampToDate(data.paidDate?.toInt(),
            format: "dd/MM/yyyy");
    var lastModifiedTime = data.lastModifiedTime == 0
        ? '-'
        : DateFormats.timeStampToDate(data.lastModifiedTime?.toInt(),
            format: "dd/MM/yyyy");
    return TableDataRow([
      TableData(
          '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(typeOfExpense ?? '-')}'),
      TableData('${vendorName ?? '-'}'),
      TableData('${data.amount ?? '-'}'),
      TableData('${billDate ?? '-'}'),
      TableData('${taxPeriodFrom ?? '-'}'),
      TableData('${taxPeriodTo ?? '-'}'),
      TableData('${applicationStatus ?? '-'}'),
      TableData('${paidDate ?? '-'}'),
      TableData('${fileLink ?? '-'}'),
      TableData('${lastModifiedTime ?? '-'}'),
      TableData('${lastModifiedBy ?? '-'}'),
    ]);
  }

  List<TableDataRow> getMonthlyReportData(List<MonthReportData> list,
      {bool isExcel = false, bool hideSerialNo = false}) {
    return list
        .asMap() // Add index to each element
        .entries
        .map((entry) => getMonthlyLedgerReportDataRow(entry.value,
            index: entry.key, isExcel: isExcel,
            hideSerialNo: hideSerialNo ))
        .toList();
  }

  List<TableDataRow> getVendorReportData(List<VendorReportData> list,
      {bool isExcel = false}) {
    return list
        .map((e) => getVendorReportDataRow(e, isExcel: isExcel))
        .toList();
  }

  TableDataRow getMonthlyLedgerReportDataRow(MonthReportData data,
      {bool isExcel = false,bool hideSerialNo = false, int index = 0}) {
    return TableDataRow([
      TableData('${data.connectionNo}'),
      if(!hideSerialNo)
      TableData('${index + 1}'),
      TableData('${data.oldConnectionNo}'),
      TableData('${data.consumerName ?? "NA"}'),
      TableData(
          '${DateFormats.leadgerTimeStampToDate(data.consumerCreatedOnDate)}'),
      TableData('${data.arrears ?? "-"}'),
      TableData('${data.advance ?? "-"}'),
      TableData('${data.penalty ?? "-"}'),
      TableData('${data.demandAmount ?? "-"}'),
      TableData(
          '${DateFormats.leadgerTimeStampToDate(data.demandGenerationDate)}'),
      TableData('${data.totalAmount ?? "-"}'),
      TableData('${data.amountPaid ?? "-"}'),
      TableData('${DateFormats.leadgerTimeStampToDate(data.paidDate)}'),
      TableData('${data.remainingAmount ?? "-"}'),
      // TableData('SURPLUS AMT'),
    ]);
  }

  TableDataRow getVendorReportDataRow(VendorReportData data,
      {bool isExcel = false}) {
    String? vendorName =
        CommonMethods.truncateWithEllipsis(20, data.vendorName!);
    String? typeOfExpense =
        CommonMethods.truncateWithEllipsis(20, data.typeOfExpense!);
    String? billId = CommonMethods.truncateWithEllipsis(20, data.billId!);
    return TableDataRow([
      TableData('${billId ?? '-'}'),
      TableData('${vendorName ?? '-'}'),
      TableData('${data.mobileNo ?? '-'}'),
      TableData(
          '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(typeOfExpense ?? '-')}'),
    ]);
  }

  void callNotifier() {
    notifyListeners();
  }

  updateSelectedBillYear(val) {
    selectedBillYear = val;
    notifyListeners();
  }

  void onChangeOfBillYear(val) {
    selectedBillYear = val;
    billingyearCtrl.text = val.toString();
    billingcycleCtrl.clear();
    selectedBillCycle = null;
    selectedBillPeriod = null;
    demandreports = [];
    ledgerReport = [];
    collectionreports = [];
    inactiveconsumers = [];
    expenseBillReportData = [];
    vendorReportData = [];
    notifyListeners();
  }

  void onChangeOfBillCycle(cycle) {
    var val = cycle['code'];
    var result = DateTime.parse(val.toString());
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
    demandreports = [];
    ledgerReport = [];
    collectionreports = [];
    inactiveconsumers = [];
    expenseBillReportData = [];
    vendorReportData = [];
    notifyListeners();
  }

  Future<void> getFinancialYearList() async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      var res = await CoreRepository().getMdms(mdms.getTenantFinancialYearList(
          commonProvider.userDetails!.userRequest!.tenantId.toString()));
      billingYearList = res;
      notifyListeners();
      streamController.add(billingYearList);
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
    }
  }

  List<TaxPeriod> getFinancialYearListDropdownA(LanguageList? languageList) {
    if (languageList?.mdmsRes?.billingService?.taxPeriodList != null) {
      CommonMethods.getFilteredFinancialYearList(
          languageList?.mdmsRes?.billingService?.taxPeriodList ??
              <TaxPeriod>[]);
      languageList?.mdmsRes?.billingService?.taxPeriodList!
          .sort((a, b) => a.fromDate!.compareTo(b.fromDate!));
      return (languageList?.mdmsRes?.billingService?.taxPeriodList ??
              <TaxPeriod>[])
          .reversed
          .toList();
    }
    return <TaxPeriod>[];
  }

  List<Map<String, dynamic>> getBillingCycleDropdownA(
      dynamic selectedBillYear) {
    List<Map<String, dynamic>> dates = [];
    if (selectedBillYear != null) {
      DatePeriod ytd;
      var fromDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(selectedBillYear.fromDate)) as DateTime;

      var toDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(selectedBillYear.toDate)) as DateTime;

      ytd = DatePeriod(fromDate, toDate, DateType.YTD);

      /// Get months based on selected billing year
      var months = CommonMethods.getPastMonthUntilFinancialYTD(ytd,
          showCurrentMonth: true);

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
    // if (dates.length > 0) {
    //   return (dates).map((value) {
    //     var d = value['name'];
    //     return "${ApplicationLocalizations.of(navigatorKey.currentContext!)
    //         .translate((Constants.MONTHS[d.month - 1])) +
    //         " - " +
    //         d.year.toString()}";
    //   }).toList();
    // }
    return dates;
  }

  List<TaxPeriod> getFinancialYearListDropdown(LanguageList? languageList) {
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

  List<Map<String, dynamic>> getBillingCycleDropdown(dynamic selectedBillYear) {
    var dates = <Map<String, dynamic>>[];
    if (selectedBillYear != null) {
      DatePeriod ytd;
      var fromDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(selectedBillYear.fromDate)) as DateTime;

      var toDate = DateFormats.getFormattedDateToDateTime(
          DateFormats.timeStampToDate(selectedBillYear.toDate)) as DateTime;

      ytd = DatePeriod(fromDate, toDate, DateType.YTD);

      /// Get months based on selected billing year
      var months = CommonMethods.getPastMonthUntilFinancialYTD(ytd,
          showCurrentMonth: true);

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

  Future<void> getLeadgerReport({
    bool download = false,
    int offset = 1,
    int limit = 12,
  }) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);

      if (selectedBillYear == null) {
        throw Exception(
            '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.SELECT_BILLING_CYCLE)}');
      }
      Map<String, dynamic> params = {
        'tenantId': commonProvider.userDetails!.selectedtenant!.code,
        'offset': '${offset - 1}',
        'limit': '${download ? -1 : limit}',
        'consumercode': consumerCode,
        'year': selectedBillYear.financialYear,
      };
      var response = await ReportsRepo().fetchLedgerReport(params);
      if (response != null) {
        ledgerReport = response;
        if (download) {
          generateExcel(
              leadgerHeaderList
                  .map<String>((e) =>
                      '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(e.label)}')
                  .toList(),
              getLedgerData(ledgerReport!, isExcel: true)
                      .map<List<String>>(
                          (e) => e.tableRow.map((e) => e.label).toList())
                      .toList() ??
                  [],
              title:
                  'LedgerReport_${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}_${selectedBillYear.toString().replaceAll('/', '_')}',
              optionalData: [
                'Ledger Report',
                '$selectedBillYear',
                '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(commonProvider.userDetails!.selectedtenant!.code!)}',
                '${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}',
                'Downloaded On ${DateFormats.timeStampToDate(DateTime.now().millisecondsSinceEpoch, format: 'dd/MMM/yyyy')}'
              ]);
        } else {
          if (ledgerReport != null && ledgerReport!.isNotEmpty) {
            this.limit = limit;
            this.offset = offset;
            this.genericTableData =
                BillsTableData(leadgerHeaderList, getLedgerData(ledgerReport!));
          }
        }

        streamController.add(response);
        callNotifier();
      } else {
        streamController.add('error');
        throw Exception('API Error');
      }
      callNotifier();
    } catch (e, s) {
      ledgerReport = [];
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
      callNotifier();
    }
  }

  Future<void> getDemandReport(
      {bool download = false,
      int offset = 1,
      int limit = 10,
      String sortOrder = "ASC"}) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      if (selectedBillPeriod == null) {
        throw Exception(
            '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.SELECT_BILLING_CYCLE)}');
      }
      Map<String, dynamic> params = {
        'tenantId': commonProvider.userDetails!.selectedtenant!.code,
        'demandStartDate': selectedBillPeriod?.split('-')[0],
        'demandEndDate': selectedBillPeriod?.split('-')[1],
        'offset': '${offset - 1}',
        'limit': '${download ? -1 : limit}',
        'sortOrder': '$sortOrder'
      };
      var response = await ReportsRepo().fetchBillReport(params);
      if (response != null) {
        demandreports = response;
        if (download) {
          generateExcel(
              demandHeaderList
                  .map<String>((e) =>
                      '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(e.label)}')
                  .toList(),
              getDemandsData(demandreports!, isExcel: true)
                      .map<List<String>>(
                          (e) => e.tableRow.map((e) => e.label).toList())
                      .toList() ??
                  [],
              title:
                  'DemandReport_${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}_${selectedBillPeriod.toString().replaceAll('/', '_')}',
              optionalData: [
                'Demand Report',
                '$selectedBillPeriod',
                '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(commonProvider.userDetails!.selectedtenant!.code!)}',
                '${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}',
                'Downloaded On ${DateFormats.timeStampToDate(DateTime.now().millisecondsSinceEpoch, format: 'dd/MMM/yyyy')}'
              ]);
        } else {
          if (demandreports != null && demandreports!.isNotEmpty) {
            this.limit = limit;
            this.offset = offset;
            this.genericTableData = BillsTableData(
                demandHeaderList, getDemandsData(demandreports!));
          }
        }
        streamController.add(response);
        callNotifier();
      } else {
        streamController.add('error');
        throw Exception('API Error');
      }
      callNotifier();
    } catch (e, s) {
      demandreports = [];
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
      callNotifier();
    }
  }

  Future<void> getCollectionReport(
      {bool download = false,
      int offset = 1,
      int limit = 10,
      String sortOrder = "ASC"}) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      if (selectedBillPeriod == null) {
        throw Exception(
            '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.SELECT_BILLING_CYCLE)}');
      }
      Map<String, dynamic> params = {
        'tenantId': commonProvider.userDetails!.selectedtenant!.code,
        'paymentStartDate': selectedBillPeriod?.split('-')[0],
        'paymentEndDate': selectedBillPeriod?.split('-')[1],
        'offset': '${offset - 1}',
        'limit': '${download ? -1 : limit}',
        'sortOrder': '$sortOrder'
      };
      var response = await ReportsRepo().fetchCollectionReport(params);
      if (response != null) {
        collectionreports = response;
        if (download) {
          generateExcel(
              collectionHeaderList
                  .map<String>((e) =>
                      '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(e.label)}')
                  .toList(),
              getCollectionData(collectionreports!, isExcel: true)
                      .map<List<String>>(
                          (e) => e.tableRow.map((e) => e.label).toList())
                      .toList() ??
                  [],
              title:
                  'CollectionReport_${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}_${selectedBillPeriod.toString().replaceAll('/', '_')}',
              optionalData: [
                'Collection Report',
                '$selectedBillPeriod',
                '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(commonProvider.userDetails!.selectedtenant!.code!)}',
                '${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}',
                'Downloaded On ${DateFormats.timeStampToDate(DateTime.now().millisecondsSinceEpoch, format: 'dd/MMM/yyyy')}'
              ]);
        } else {
          if (collectionreports != null && collectionreports!.isNotEmpty) {
            this.limit = limit;
            this.offset = offset;
            this.genericTableData = BillsTableData(
                collectionHeaderList, getCollectionData(collectionreports!));
          }
        }
        streamController.add(response);
        callNotifier();
      } else {
        streamController.add('error');
        throw Exception('API Error');
      }
      callNotifier();
    } catch (e, s) {
      collectionreports = [];
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
      callNotifier();
    }
  }

  Future<void> getInactiveConsumerReport(
      {bool download = false,
      int offset = 1,
      int limit = 10,
      String sortOrder = "ASC"}) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      if (selectedBillPeriod == null) {
        throw Exception(
            '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.SELECT_BILLING_CYCLE)}');
      }
      Map<String, dynamic> params = {
        'tenantId': commonProvider.userDetails!.selectedtenant!.code,
        'monthStartDate': selectedBillPeriod?.split('-')[0],
        'monthEndDate': selectedBillPeriod?.split('-')[1],
        'offset': '${offset - 1}',
        'limit': '${download ? -1 : limit}',
        'sortOrder': '$sortOrder'
      };
      var response = await ReportsRepo().fetchInactiveConsumerReport(params);
      if (response != null) {
        inactiveconsumers = response;
        if (download) {
          generateExcel(
              inactiveConsumerHeaderList
                  .map<String>((e) =>
                      '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(e.label)}')
                  .toList(),
              getInactiveConsumersData(inactiveconsumers!, isExcel: true)
                      .map<List<String>>(
                          (e) => e.tableRow.map((e) => e.label).toList())
                      .toList() ??
                  [],
              title:
                  'InactiveConsumers_${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}_${selectedBillPeriod.toString().replaceAll('/', '_')}',
              optionalData: [
                'Inactive Consumer Report',
                '$selectedBillPeriod',
                '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(commonProvider.userDetails!.selectedtenant!.code!)}',
                '${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}',
                'Downloaded On ${DateFormats.timeStampToDate(DateTime.now().millisecondsSinceEpoch, format: 'dd/MMM/yyyy')}'
              ]);
        } else {
          if (inactiveconsumers != null && inactiveconsumers!.isNotEmpty) {
            this.limit = limit;
            this.offset = offset;
            this.genericTableData = BillsTableData(inactiveConsumerHeaderList,
                getInactiveConsumersData(inactiveconsumers!));
          }
        }
        streamController.add(response);
        callNotifier();
      } else {
        streamController.add('error');
        throw Exception('API Error');
      }
      callNotifier();
    } catch (e, s) {
      inactiveconsumers = [];
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
      callNotifier();
    }
  }

  Future<void> getExpenseBillReport(
      {bool download = false,
      int offset = 1,
      int limit = 10,
      String sortOrder = "ASC"}) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      if (selectedBillPeriod == null) {
        throw Exception(
            '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.SELECT_BILLING_CYCLE)}');
      }
      Map<String, dynamic> params = {
        'tenantId': commonProvider.userDetails!.selectedtenant!.code,
        'monthstartDate': selectedBillPeriod?.split('-')[0],
        'monthendDate': selectedBillPeriod?.split('-')[1],
        'offset': '${offset - 1}',
        'limit': '${download ? -1 : limit}',
        'sortOrder': '$sortOrder'
      };
      var response = await ReportsRepo().fetchExpenseBillReport(params);
      if (response != null) {
        expenseBillReportData = response;
        if (download) {
          generateExcel(
              expenseBillReportHeaderList
                  .map<String>((e) =>
                      '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(e.label)}')
                  .toList(),
              getExpenseBillReportData(expenseBillReportData!, isExcel: true)
                      .map<List<String>>(
                          (e) => e.tableRow.map((e) => e.label).toList())
                      .toList() ??
                  [],
              title:
                  'ExpenseBillReport_${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}_${selectedBillPeriod.toString().replaceAll('/', '_')}',
              optionalData: [
                'Expense Bill Report',
                '$selectedBillPeriod',
                '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(commonProvider.userDetails!.selectedtenant!.code!)}',
                '${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}',
                'Downloaded On ${DateFormats.timeStampToDate(DateTime.now().millisecondsSinceEpoch, format: 'dd/MMM/yyyy')}'
              ]);
        } else {
          if (expenseBillReportData != null &&
              expenseBillReportData!.isNotEmpty) {
            this.limit = limit;
            this.offset = offset;
            this.genericTableData = BillsTableData(expenseBillReportHeaderList,
                getExpenseBillReportData(expenseBillReportData!));
          }
        }
        streamController.add(response);
        callNotifier();
      } else {
        streamController.add('error');
        throw Exception('API Error');
      }
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
      callNotifier();
    }
  }

  Future<void> getMonthlyLedgerReport({
    bool download = false,
    int offset = 1,
    int limit = 10,
  }) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      if (selectedBillPeriod == null) {
        throw Exception(
            '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.SELECT_BILLING_CYCLE)}');
      }
      Map<String, dynamic> params = {
        'tenantId': commonProvider.userDetails!.selectedtenant!.code,
        'startDate': selectedBillPeriod?.split('-')[0],
        'endDate': selectedBillPeriod?.split('-')[1],
        'offset': '${offset - 1}',
        'limit': '${download ? -1 : limit}',
        'sortOrder': 'DESC'
      };
      var response = await ReportsRepo().fetchMonthlyLedgerReport(params);
     
      if (response != null) {
        monthlyLedgerReport = response.monthReport;
        if (download) {
          List<String> headerList = monthlyLedgerReportHeaderList
                  .map<String>((e) =>
                      '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(e.label)}')
                  .toList();
                   headerList.removeAt(1);                   
          generateExcel(
              headerList,
              getMonthlyReportData(monthlyLedgerReport!, isExcel: true,hideSerialNo: true)
                      .map<List<String>>(
                          (e) => e.tableRow.map((e) => e.label).toList())
                      .toList() ??
                  [],
              title:
                  'MonthlyReport_${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}_${selectedBillPeriod.toString().replaceAll('/', '_')}',
              optionalData: [
                'Monthly Report',
                '$selectedBillPeriod',
                '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(commonProvider.userDetails!.selectedtenant!.code!)}',
                '${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}',
                'Downloaded On ${DateFormats.timeStampToDate(DateTime.now().millisecondsSinceEpoch, format: 'dd/MMM/yyyy')}'
              ]);
        } else {
          if (monthlyLedgerReport != null && monthlyLedgerReport!.isNotEmpty) {
            this.limit = limit;
            this.offset = offset;
            this.genericTableData = BillsTableData(
                monthlyLedgerReportHeaderList,
                getMonthlyReportData(monthlyLedgerReport!));
          }
        }
        streamController.add(response);
        callNotifier();
      } else {
        streamController.add('error');
        throw Exception('API Error');
      }
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
      callNotifier();
    }
  }

  Future<void> getVendorReport(
      {bool download = false,
      int offset = 1,
      int limit = 10,
      String sortOrder = "ASC"}) async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      if (selectedBillPeriod == null) {
        throw Exception(
            '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.SELECT_BILLING_CYCLE)}');
      }
      Map<String, dynamic> params = {
        'tenantId': commonProvider.userDetails!.selectedtenant!.code,
        'monthStartDate': selectedBillPeriod?.split('-')[0],
        'monthEndDate': selectedBillPeriod?.split('-')[1],
        'offset': '${offset - 1}',
        'limit': '${download ? -1 : limit}',
        'sortOrder': '$sortOrder'
      };
      var response = await ReportsRepo().fetchVendorReport(params);
      if (response != null) {
        vendorReportData = response;
        if (download) {
          generateExcel(
              vendorReportHeaderList
                  .map<String>((e) =>
                      '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(e.label)}')
                  .toList(),
              getVendorReportData(vendorReportData!, isExcel: true)
                      .map<List<String>>(
                          (e) => e.tableRow.map((e) => e.label).toList())
                      .toList() ??
                  [],
              title:
                  'VendorReport_${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}_${selectedBillPeriod.toString().replaceAll('/', '_')}',
              optionalData: [
                'Vendor Report',
                '$selectedBillPeriod',
                '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(commonProvider.userDetails!.selectedtenant!.code!)}',
                '${commonProvider.userDetails?.selectedtenant?.code?.substring(3)}',
                'Downloaded On ${DateFormats.timeStampToDate(DateTime.now().millisecondsSinceEpoch, format: 'dd/MMM/yyyy')}'
              ]);
        } else {
          if (vendorReportData != null && vendorReportData!.isNotEmpty) {
            this.limit = limit;
            this.offset = offset;
            this.genericTableData = BillsTableData(
                vendorReportHeaderList, getVendorReportData(vendorReportData!));
          }
        }
        streamController.add(response);
        callNotifier();
      } else {
        streamController.add('error');
        throw Exception('API Error');
      }
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
      callNotifier();
    }
  }

  void clearBuildTableData() {
    genericTableData = BillsTableData([], []);
    callNotifier();
  }

  Future<void> generateExcel(List<String> headers, List<List<String>> tableData,
      {String title = 'HouseholdRegister',
      List<String> optionalData = const []}) async {
    //Create a Excel document.

    //Creating a workbook.
    headers.insert(0,
        '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.S_NO)}');
    final Workbook workbook = Workbook();
    //Accessing via index
    final Worksheet sheet = workbook.worksheets[0];
    // sheet.showGridlines = false;

    // Enable calculation for worksheet.
    sheet.enableSheetCalculations();
    int dataStartRow = 2;
    int headersStartRow = 1;
    // //Set data in the worksheet.s
    if (optionalData.isEmpty) {
      sheet.getRangeByName('A1:D1').columnWidth = 32.5;
      sheet.getRangeByName('A1:D1').cellStyle.hAlign = HAlignType.center;
    } else {
      sheet.getRangeByName('A1:A${tableData.length + 1}').columnWidth = 12.5;
      sheet.getRangeByName('A1:A${tableData.length + 1}').cellStyle.hAlign =
          HAlignType.center;
      sheet.getRangeByName('A1:A${tableData.length + 1}').autoFit();
      sheet
          .getRangeByName(
              'B1:${CommonMethods.getAlphabetsWithKeyValue()[optionalData.length + 1].label}1')
          .columnWidth = 32.5;
      sheet
          .getRangeByName(
              'B1:${CommonMethods.getAlphabetsWithKeyValue()[optionalData.length + 1].label}1')
          .cellStyle
          .hAlign = HAlignType.center;
      sheet
          .getRangeByName(
              'B2:${CommonMethods.getAlphabetsWithKeyValue()[headers.length + 1].label}2')
          .columnWidth = 32.5;
      sheet
          .getRangeByName(
              'A2:${CommonMethods.getAlphabetsWithKeyValue()[headers.length + 1].label}2')
          .cellStyle
          .hAlign = HAlignType.center;
      sheet
          .getRangeByName(
              'A2:${CommonMethods.getAlphabetsWithKeyValue()[headers.length + 1].label}2')
          .cellStyle
          .bold = true;
      dataStartRow = 3;
      headersStartRow = 2;
      for (int i = 0; i < optionalData.length; i++) {
        sheet
            .getRangeByName(
                '${CommonMethods.getAlphabetsWithKeyValue()[i + 1].label}1')
            .setText(
                optionalData[CommonMethods.getAlphabetsWithKeyValue()[i].key]);
      }
    }

    for (int i = 0; i < headers.length; i++) {
      sheet
          .getRangeByName(
              '${CommonMethods.getAlphabetsWithKeyValue()[i].label}$headersStartRow')
          .setText(headers[CommonMethods.getAlphabetsWithKeyValue()[i].key]);
    }

    for (int i = dataStartRow; i < tableData.length + dataStartRow; i++) {
      for (int j = 0; j < headers.length; j++) {
        if (j == 0) {
          sheet
              .getRangeByName(
                  '${CommonMethods.getAlphabetsWithKeyValue()[j].label}$i')
              .setText('${i - dataStartRow + 1}');
        } else {
          sheet
              .getRangeByName(
                  '${CommonMethods.getAlphabetsWithKeyValue()[j].label}$i')
              .setText(tableData[i - dataStartRow][j - 1]);
        }
        sheet
            .getRangeByName(
                '${CommonMethods.getAlphabetsWithKeyValue()[j].label}$i')
            .cellStyle
            .hAlign = HAlignType.center;
        sheet
            .getRangeByName(
                '${CommonMethods.getAlphabetsWithKeyValue()[j].label}$i')
            .cellStyle
            .vAlign = VAlignType.center;
      }
    }

    //Save and launch the excel.
    final List<int> bytes = workbook.saveAsStream();
    //Dispose the document.
    workbook.dispose();

    //Save and launch the file.
    await saveAndLaunchFile(bytes, '$title.xlsx');
  }

  Future<void> getWaterConnectionsCount() async {
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      Map<String, dynamic> params = {
        'tenantId': commonProvider.userDetails!.selectedtenant!.code,
      };
      var response = await ReportsRepo().fetchWaterConnectionsCount(params);
      if (response != null) {
        waterConnectionCount = response;
        streamController.add(response);
        callNotifier();
      } else {
        streamController.add('error');
        throw Exception('API Error');
      }
      callNotifier();
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
      callNotifier();
    }
  }
}
