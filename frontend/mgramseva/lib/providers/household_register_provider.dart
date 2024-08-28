import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/model/connection/water_connections.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/reports_provider.dart';
import 'package:mgramseva/repository/search_connection_repo.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/screeens/household_register/household_pdf_creator.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/excel_download/generate_excel.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/color_codes.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

class HouseholdRegisterProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();
  TextEditingController searchController = TextEditingController();
  int offset = 1;
  int limit = 10;
  late DateTime selectedDate;
  SortBy? sortBy;
  WaterConnections? waterConnectionsDetails;
  WaterConnection? waterConnection;
  String selectedTab = Constants.ALL;
  Map<String, int> collectionCountHolder = {};
  Timer? debounce;
  bool isLoaderEnabled = false;
  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  onChangeOfTab(BuildContext context, int index) async {
    var householdProvider =
        Provider.of<HouseholdRegisterProvider>(context, listen: false)
          ..limit = 10
          ..offset = 1
          ..sortBy = SortBy('connectionNumber', false);

    householdProvider
      ..waterConnectionsDetails?.waterConnection = <WaterConnection>[]
      ..waterConnectionsDetails?.totalCount = null;

    if (index == 0) {
      householdProvider.selectedTab = Constants.ALL;
    } else if (index == 1) {
      householdProvider.selectedTab = Constants.PAID;
    } else {
      householdProvider.selectedTab = Constants.PENDING;
    }
    householdProvider.fetchHouseholdDetails(
        context, householdProvider.limit, householdProvider.offset, true);
  }

  Future<void> fetchHouseholdDetails(
      BuildContext context, int limit, int offSet,
      [bool isSearch = false]) async {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    var totalCount = waterConnectionsDetails?.totalCount ?? 0;
    this.limit = limit;
    this.offset = offSet;
    notifyListeners();
    if (!isSearch &&
        waterConnectionsDetails?.totalCount != null &&
        ((offSet + limit) > totalCount ? totalCount : (offSet + limit)) <=
            (waterConnectionsDetails?.waterConnection?.length ?? 0)) {
      streamController.add(waterConnectionsDetails?.waterConnection?.sublist(
          offset - 1,
          ((offset + limit) - 1) > totalCount
              ? totalCount
              : (offset + limit) - 1));
      return;
    }

    if (isSearch) waterConnectionsDetails = null;

    var query = {
      'tenantId': commonProvider.userDetails?.selectedtenant?.code,
      'offset': '${offset - 1}',
      'limit': '$limit',
      'toDate': '${DateTime.now().millisecondsSinceEpoch}',
      'isCollectionCount': 'true',
    };

    if (selectedTab != Constants.ALL) {
      query.addAll(
          {'isBillPaid': (selectedTab == Constants.PAID) ? 'true' : 'false'});
    }

    if (sortBy != null) {
      query.addAll({
        'sortOrder': sortBy!.isAscending ? 'ASC' : 'DESC',
        'sortBy': sortBy!.key
      });
    }

    if (searchController.text.trim().isNotEmpty) {
      query.addAll({
        'textSearch': searchController.text.trim(),
        // 'name' : searchController.text.trim(),
        'freeSearch': 'true',
      });
    }

    query
        .removeWhere((key, value) => (value is String && value.trim().isEmpty));
    streamController.add(null);

    isLoaderEnabled = true;
    notifyListeners();
    try {
      var response = await SearchConnectionRepository().getconnection(query);

      var searchResponse;
      if (isSearch && selectedTab != Constants.ALL) {
        query.remove('isBillPaid');
        searchResponse =
            await SearchConnectionRepository().getconnection(query);
      }

      isLoaderEnabled = false;

      if (selectedTab == Constants.ALL) {
        collectionCountHolder[Constants.ALL] = response.totalCount ?? 0;
        collectionCountHolder[Constants.PAID] =
            response.collectionDataCount?.collectionPaid ?? 0;
        collectionCountHolder[Constants.PENDING] =
            response.collectionDataCount?.collectionPending ?? 0;
      } else if (searchResponse != null) {
        collectionCountHolder[Constants.ALL] = searchResponse.totalCount ?? 0;
        collectionCountHolder[Constants.PAID] =
            searchResponse.collectionDataCount?.collectionPaid ?? 0;
        collectionCountHolder[Constants.PENDING] =
            searchResponse.collectionDataCount?.collectionPending ?? 0;
      }

      if (waterConnectionsDetails == null) {
        waterConnectionsDetails = response;
        notifyListeners();
      } else {
        waterConnectionsDetails?.totalCount = response.totalCount;
        waterConnectionsDetails?.waterConnection
            ?.addAll(response.waterConnection ?? <WaterConnection>[]);
      }
      notifyListeners();
      streamController.add(waterConnectionsDetails!.waterConnection!.isEmpty
          ? <WaterConnection>[]
          : waterConnectionsDetails?.waterConnection?.sublist(
              offSet - 1,
              ((offset + limit - 1) >
                      (waterConnectionsDetails?.totalCount ?? 0))
                  ? (waterConnectionsDetails!.totalCount!)
                  : (offset + limit) - 1));
    } catch (e, s) {
      isLoaderEnabled = false;
      notifyListeners();
      streamController.addError('error');
      ErrorHandler().allExceptionsHandler(context, e, s);
    }
  }

  List<String> getCollectionsTabList(BuildContext context) {
    var list = [i18.dashboard.ALL, i18.dashboard.PAID, i18.dashboard.PENDING];
    return List.generate(
        list.length,
        (index) =>
            '${ApplicationLocalizations.of(context).translate(list[index])} (${getCollectionsCount(index)})');
  }

  bool isTabSelected(int index) {
    if (selectedTab == Constants.ALL && index == 0) return true;
    if ((selectedTab == Constants.PENDING && index == 2) ||
        (selectedTab == Constants.PAID && index == 1)) return true;
    return false;
  }

  List<TableHeader> get collectionHeaderList => [
        TableHeader(i18.common.CONNECTION_ID,
            isSortingRequired: true,
            isAscendingOrder:
                sortBy != null && sortBy!.key == 'connectionNumber'
                    ? sortBy!.isAscending
                    : null,
            apiKey: 'connectionNumber',
            callBack: onSort),
        TableHeader(i18.common.NAME, isSortingRequired: false),
        TableHeader(i18.common.GENDER, isSortingRequired: false),
        TableHeader(i18.consumer.FATHER_SPOUSE_NAME, isSortingRequired: false),
        TableHeader(i18.common.MOBILE_NUMBER, isSortingRequired: false),
        TableHeader(i18.consumer.OLD_CONNECTION_ID, isSortingRequired: false),
        TableHeader(i18.consumer.CONSUMER_CATEGORY, isSortingRequired: false),
        TableHeader(i18.consumer.CONSUMER_SUBCATEGORY,
            isSortingRequired: false),
        TableHeader(i18.searchWaterConnection.PROPERTY_TYPE,
            isSortingRequired: false),
        TableHeader(i18.searchWaterConnection.CONNECTION_TYPE,
            isSortingRequired: false),
        TableHeader(i18.demandGenerate.METER_READING_DATE,
            isSortingRequired: false),
        TableHeader(i18.searchWaterConnection.METER_NUMBER,
            isSortingRequired: false),
        TableHeader(i18.demandGenerate.PREV_METER_READING_LABEL,
            isSortingRequired: false),
        TableHeader(i18.consumer.ARREARS_ON_CREATION, isSortingRequired: false),
        TableHeader(i18.consumer.CORE_PENALTY_ON_CREATION,
            isSortingRequired: false),
        TableHeader(i18.consumer.CORE_ADVANCE_ON_CREATION,
            isSortingRequired: false),
        TableHeader(i18.common.CORE_TOTAL_BILL_AMOUNT,
            isSortingRequired: false),
        TableHeader(i18.billDetails.TOTAL_AMOUNT_COLLECTED,
            isSortingRequired: false),
        TableHeader(i18.common.CORE_ADVANCE_AS_ON_TODAY,
            isSortingRequired: false),
        TableHeader(i18.householdRegister.PENDING_COLLECTIONS,
            isSortingRequired: true,
            isAscendingOrder:
                sortBy != null && sortBy!.key == 'collectionPendingAmount'
                    ? sortBy!.isAscending
                    : null,
            apiKey: 'collectionPendingAmount',
            callBack: onSort),
        TableHeader(i18.common.CREATED_ON_DATE, isSortingRequired: false),
        TableHeader(i18.householdRegister.LAST_BILL_GEN_DATE,
            isSortingRequired: true,
            apiKey: 'lastDemandGeneratedDate',
            isAscendingOrder:
                sortBy != null && sortBy!.key == 'lastDemandGeneratedDate'
                    ? sortBy!.isAscending
                    : null,
            callBack: onSort),
        TableHeader(i18.householdRegister.ACTIVE_INACTIVE,
            isSortingRequired: false, apiKey: 'leadgerReport'),
        // TableHeader("Ledger", apiKey: '/viewLeadger')
      ];
  List<TableHeader> get collectionHeaderListOLd => [
        TableHeader(i18.common.CONNECTION_ID,
            isSortingRequired: true,
            isAscendingOrder:
                sortBy != null && sortBy!.key == 'connectionNumber'
                    ? sortBy!.isAscending
                    : null,
            apiKey: 'connectionNumber',
            callBack: onSort),
        TableHeader(
          i18.consumer.OLD_CONNECTION_ID,
          isSortingRequired: false,
        ),
        TableHeader(i18.common.NAME,
            isSortingRequired: true,
            isAscendingOrder: sortBy != null && sortBy!.key == 'name'
                ? sortBy!.isAscending
                : null,
            apiKey: 'name',
            callBack: onSort),
        TableHeader(i18.consumer.FATHER_SPOUSE_NAME,
            isSortingRequired: false,
            isAscendingOrder:
                sortBy != null && sortBy!.key == 'fatherOrHusbandName'
                    ? sortBy!.isAscending
                    : null,
            apiKey: 'fatherOrHusbandName',
            callBack: onSort),
        TableHeader(i18.householdRegister.PENDING_COLLECTIONS,
            isSortingRequired: true,
            isAscendingOrder:
                sortBy != null && sortBy!.key == 'collectionPendingAmount'
                    ? sortBy!.isAscending
                    : null,
            apiKey: 'collectionPendingAmount',
            callBack: onSort),
        TableHeader(i18.common.CORE_ADVANCE,
            isSortingRequired: true,
            isAscendingOrder:
                sortBy != null && sortBy!.key == 'collectionPendingAmount'
                    ? sortBy!.isAscending
                    : null,
            apiKey: 'collectionPendingAmount',
            callBack: onSort),
        TableHeader(i18.householdRegister.ACTIVE_INACTIVE, apiKey: 'status'),
        TableHeader(i18.householdRegister.LAST_BILL_GEN_DATE,
            isSortingRequired: true,
            apiKey: 'lastDemandGeneratedDate',
            isAscendingOrder:
                sortBy != null && sortBy!.key == 'lastDemandGeneratedDate'
                    ? sortBy!.isAscending
                    : null,
            callBack: onSort),
      ];

  List<TableDataRow> getCollectionsData(List<WaterConnection> list) {
    return list.map((e) => getCollectionRow(e)).toList();
  }

  getDownloadList() {
    return collectionCountHolder[selectedTab] ?? 0;
  }

  int getCollectionsCount(int index) {
    switch (index) {
      case 0:
        return collectionCountHolder[Constants.ALL] ?? 0;
      case 1:
        return collectionCountHolder[Constants.PAID] ?? 0;
      case 2:
        return collectionCountHolder[Constants.PENDING] ?? 0;
      default:
        return 0;
    }
  }

  String? truncateWithEllipsis(String? myString) {
    return (myString!.length <= 20)
        ? myString
        : '${myString.substring(0, 20)}...';
  }

  TableDataRow getCollectionRow(WaterConnection connection) {
    String? name =
        truncateWithEllipsis(connection.connectionHolders?.first.name ?? 'NA');
    String? fatherName = truncateWithEllipsis(
        connection.connectionHolders?.first.fatherOrHusbandName);
    return TableDataRow([
      TableData(
          '${connection.connectionNo?.split('/').first ?? ''}/...${connection.connectionNo?.split('/').last ?? ''} ${connection.connectionType == 'Metered' ? '- M' : ''}',
          callBack: onClickOfCollectionNo,
          iconButtonCallBack: viewLeadger,
          apiKey: connection.connectionNo),
      TableData(
        '${name ?? 'NA'}',
      ),
      TableData(
        '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(connection.connectionHolders?.first.gender ?? 'NA')}',
      ),
      TableData(
        '${fatherName ?? 'NA'}',
      ),
      TableData(
        maskMobileNumber(
            '${connection.connectionHolders?.first.mobileNumber ?? 'NA'}'),
      ),
      TableData(
        '${connection.oldConnectionNo ?? 'NA'}',
      ),
      TableData(
        '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(connection.additionalDetails?.category ?? 'NA')}',
      ),
      TableData(
        '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(connection.additionalDetails?.subCategory ?? 'NA')}',
      ),
      TableData(
        '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(connection.additionalDetails?.propertyType ?? 'NA')}',
      ),
      TableData(
        '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(connection.connectionType ?? 'NA')}',
      ),
      TableData(
        '${connection.connectionType == 'Metered' ? connection.additionalDetails?.lastDemandGeneratedDate != null && connection.additionalDetails?.lastDemandGeneratedDate != '' ? DateFormats.timeStampToDate(int.parse(connection.additionalDetails?.lastDemandGeneratedDate ?? 'NA')) : 'NA' : 'NA'}',
      ),
      TableData(
        '${connection.connectionType == 'Metered' ? connection.meterId : 'NA'}',
      ),
      TableData(
        '${connection.connectionType == 'Metered' ? connection.additionalDetails?.meterReading : 'NA'}',
      ),
      TableData(
        '${connection.arrears != null ? '₹ ${connection.arrears}' : '-'}',
      ),
      TableData(
        '${connection.penalty != null ? '₹ ${connection.penalty}' : '-'}',
      ),
      TableData(
        '${connection.advance != null ? '₹ ${connection.advance}' : '-'}',
      ),
      TableData(
        '${connection.additionalDetails?.totalAmount != null ? '₹ ${connection.additionalDetails?.totalAmount}' : '-'}',
      ),
      TableData(
        '${connection.additionalDetails?.collectionAmount != null ? '₹ ${connection.additionalDetails?.collectionAmount}' : '-'}',
      ),
      TableData(
        '${connection.additionalDetails?.collectionPendingAmount != null ? double.parse(connection.additionalDetails?.collectionPendingAmount ?? '') < 0.0 ? '₹ ${double.parse(connection.additionalDetails?.collectionPendingAmount ?? '0').abs()}' : '-' : '-'}',
      ),
      TableData(
        '${connection.additionalDetails?.collectionPendingAmount != null ? double.parse(connection.additionalDetails?.collectionPendingAmount ?? '') < 0.0 ? '-' : '₹ ${double.parse(connection.additionalDetails?.collectionPendingAmount ?? '0').abs()}' : '-'}',
      ),
      TableData(
        '${connection.additionalDetails?.appCreatedDate != null ? DateFormats.timeStampToDate(connection.additionalDetails?.appCreatedDate?.toInt()) : '-'}',
      ),
      TableData(
        '${connection.additionalDetails?.lastDemandGeneratedDate != null && connection.additionalDetails?.lastDemandGeneratedDate != '' ? DateFormats.timeStampToDate(int.parse(connection.additionalDetails?.lastDemandGeneratedDate ?? '')) : '-'}',
      ),
      TableData(
          '${connection.status.toString().toLowerCase() == Constants.CONNECTION_STATUS.last.toLowerCase() ? 'Y' : 'N'}',
          style: TextStyle(
              color: connection.status.toString() ==
                      Constants.CONNECTION_STATUS.last
                  ? ColorCodes.ACTIVE_COL
                  : ColorCodes.INACTIVE_COL)),
    ]);
  }

  onClickOfCollectionNo(TableData tableData) {
    var waterConnection = waterConnectionsDetails?.waterConnection
        ?.firstWhere((element) => element.connectionNo == tableData.apiKey);
    Navigator.pushNamed(navigatorKey.currentContext!, Routes.HOUSEHOLD_DETAILS,
        arguments: {
          'waterconnections': waterConnection,
          'mode': 'collect',
          'status': waterConnection?.status
        });
  }

  viewLeadger(TableData tableData) {
    var waterConnection = waterConnectionsDetails?.waterConnection
        ?.firstWhere((element) => element.connectionNo == tableData.apiKey);
    Navigator.pushNamed(navigatorKey.currentContext!, Routes.LEDGER_REPORTS,
        arguments: {
          'waterconnections': waterConnection,
        });
  }

  onSort(TableHeader header) {
    if (sortBy != null && sortBy!.key == header.apiKey) {
      header.isAscendingOrder = !sortBy!.isAscending;
    } else if (header.isAscendingOrder == null) {
      header.isAscendingOrder = true;
    } else {
      header.isAscendingOrder = !(header.isAscendingOrder ?? false);
    }
    sortBy = SortBy(header.apiKey ?? '', header.isAscendingOrder!);
    notifyListeners();
    fetchHouseholdDetails(navigatorKey.currentContext!, limit, 1, true);
  }

  void onSearch(String val, BuildContext context) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      fetchDetails(context, limit, 1, true);
    });
  }

  void onChangeOfPageLimit(PaginationResponse response, BuildContext context) {
    fetchDetails(
        context, response.limit, response.offset, response.isPageChange);
  }

  fetchDetails(BuildContext context,
      [int? localLimit, int? localOffSet, bool isSearch = false]) {
    if (isLoaderEnabled) return;

    fetchHouseholdDetails(
        context, localLimit ?? limit, localOffSet ?? 1, isSearch);
  }

  String maskMobileNumber(String mobileNumber) {
    if (mobileNumber.length != 10) {
      // Check if the mobile number has the expected length
      return mobileNumber;
    }

    // Mask the mobile number
    String maskedNumber =
        mobileNumber.substring(0, 2) + 'xxxx' + mobileNumber.substring(6);

    return maskedNumber;
  }

  void createExcelOrPdfForAllConnections(BuildContext context, bool isDownload,
      {bool isExcelDownload = false}) async {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    WaterConnections? waterConnectionsDetails;

    var query = {
      'tenantId': commonProvider.userDetails?.selectedtenant?.code,
      'limit': '-1',
      'toDate': '${DateTime.now().millisecondsSinceEpoch}',
      'isCollectionCount': 'true',
    };

    if (selectedTab != Constants.ALL) {
      query.addAll(
          {'isBillPaid': (selectedTab == Constants.PAID) ? 'true' : 'false'});
    }

    if (sortBy != null) {
      query.addAll({
        'sortOrder': sortBy!.isAscending ? 'ASC' : 'DESC',
        'sortBy': sortBy!.key
      });
    }

    if (searchController.text.trim().isNotEmpty) {
      query.addAll({
        'textSearch': searchController.text.trim(),
        // 'name' : searchController.text.trim(),
        'freeSearch': 'true',
      });
    }

    query
        .removeWhere((key, value) => (value is String && value.trim().isEmpty));

    Loaders.showLoadingDialog(context);
    try {
      waterConnectionsDetails =
          await SearchConnectionRepository().getconnection(query);

      Navigator.pop(context);
    } catch (e, s) {
      Navigator.pop(context);
      ErrorHandler().allExceptionsHandler(context, e, s);
      return;
    }

    if (waterConnectionsDetails.waterConnection == null ||
        waterConnectionsDetails.waterConnection!.isEmpty) return;

    var headerList = [
      i18.common.CONNECTION_ID,
      i18.consumer.OLD_CONNECTION_ID,
      i18.common.NAME,
      i18.consumer.FATHER_SPOUSE_NAME,
      i18.householdRegister.PENDING_COLLECTIONS,
      i18.common.CORE_ADVANCE,
      i18.householdRegister.ACTIVE_INACTIVE,
      i18.householdRegister.LAST_BILL_GEN_DATE
    ];
    var pdfHeaderList = [
      i18.common.CONNECTION_ID,
      i18.common.NAME,
      i18.common.GENDER,
      i18.consumer.FATHER_SPOUSE_NAME,
      i18.common.MOBILE_NUMBER,
      i18.consumer.OLD_CONNECTION_ID,
      i18.consumer.CONSUMER_CATEGORY,
      i18.consumer.CONSUMER_SUBCATEGORY,
      i18.searchWaterConnection.PROPERTY_TYPE,
      i18.searchWaterConnection.CONNECTION_TYPE,
      i18.demandGenerate.METER_READING_DATE,
      i18.searchWaterConnection.METER_NUMBER,
      i18.demandGenerate.PREV_METER_READING_LABEL,
      i18.consumer.ARREARS_ON_CREATION,
      i18.consumer.CORE_PENALTY_ON_CREATION,
      i18.consumer.CORE_ADVANCE_ON_CREATION,
      i18.common.CORE_TOTAL_BILL_AMOUNT,
      i18.billDetails.TOTAL_AMOUNT_COLLECTED,
      i18.common.CORE_ADVANCE_AS_ON_TODAY,
      i18.common.CORE_BALANCE_AS_ON_TODAY,
      i18.common.CREATED_ON_DATE,
      i18.householdRegister.LAST_BILL_GEN_DATE,
      i18.householdRegister.ACTIVE_INACTIVE
    ];
    var downloadHeaderList = [
      i18.common.VILLAGE_CODE,
      i18.common.VILLAGE_NAME,
      i18.common.TENANT_ID,
      i18.common.NAME,
      i18.common.GENDER,
      i18.consumer.FATHER_SPOUSE_NAME,
      i18.common.MOBILE_NUMBER,
      i18.consumer.OLD_CONNECTION_ID,
      i18.common.CONNECTION_ID,
      i18.consumer.CONSUMER_CATEGORY,
      i18.consumer.CONSUMER_SUBCATEGORY,
      i18.searchWaterConnection.PROPERTY_TYPE,
      i18.searchWaterConnection.CONNECTION_TYPE,
      i18.demandGenerate.METER_READING_DATE,
      i18.searchWaterConnection.METER_NUMBER,
      i18.demandGenerate.PREV_METER_READING_LABEL,
      i18.consumer.ARREARS_ON_CREATION,
      i18.consumer.CORE_PENALTY_ON_CREATION,
      i18.consumer.CORE_ADVANCE_ON_CREATION,
      i18.common.CORE_TOTAL_BILL_AMOUNT,
      i18.billDetails.TOTAL_AMOUNT_COLLECTED,
      i18.common.CORE_ADVANCE_AS_ON_TODAY,
      i18.common.CORE_BALANCE_AS_ON_TODAY,
      i18.common.CREATED_ON_DATE,
      i18.householdRegister.LAST_BILL_GEN_DATE,
      i18.householdRegister.ACTIVE_INACTIVE
    ];

    var pdfTableData = waterConnectionsDetails.waterConnection
            ?.map<List<String>>((connection) => [
                  '${connection.connectionNo ?? ''} ${connection.connectionType == 'Metered' ? '- M' : ''}',
                  '${connection.connectionHolders?.first.name ?? ''}',
                  '${connection.connectionHolders?.first.fatherOrHusbandName ?? ''}',
                  '${connection.additionalDetails?.collectionPendingAmount != null ? double.parse(connection.additionalDetails?.collectionPendingAmount ?? '') < 0.0 ? '-' : '₹ ${double.parse(connection.additionalDetails?.collectionPendingAmount ?? '0').abs()}' : '-'}',
                  '${connection.additionalDetails?.collectionPendingAmount != null ? double.parse(connection.additionalDetails?.collectionPendingAmount ?? '') < 0.0 ? '₹ ${double.parse(connection.additionalDetails?.collectionPendingAmount ?? '0').abs()}' : '₹ 0' : '₹ 0'}',
                  '${connection.status.toString() == Constants.CONNECTION_STATUS.last ? 'Y' : 'N'}',
                  '${connection.additionalDetails?.lastDemandGeneratedDate != null && connection.additionalDetails?.lastDemandGeneratedDate != '' ? DateFormats.timeStampToDate(int.parse(connection.additionalDetails?.lastDemandGeneratedDate ?? '')) : '-'}'
                ])
            .toList() ??
        [];
    var excelTableData = waterConnectionsDetails.waterConnection
            ?.map<List<String>>((connection) => [
                  '${commonProvider.userDetails?.selectedtenant?.city?.code ?? 'NA'}',
                  '${ApplicationLocalizations.of(context).translate(connection.tenantId ?? 'NA')}',
                  '${connection.tenantId ?? 'NA'}',
                  '${connection.connectionHolders?.first.name ?? 'NA'}',
                  '${ApplicationLocalizations.of(context).translate(connection.connectionHolders?.first.gender ?? 'NA')}',
                  '${connection.connectionHolders?.first.fatherOrHusbandName ?? 'NA'}',
                  maskMobileNumber(
                      '${connection.connectionHolders?.first.mobileNumber ?? 'NA'}'),
                  '${connection.oldConnectionNo ?? 'NA'}',
                  '${connection.connectionNo ?? 'NA'}',
                  '${ApplicationLocalizations.of(context).translate(connection.additionalDetails?.category ?? 'NA')}',
                  '${ApplicationLocalizations.of(context).translate(connection.additionalDetails?.subCategory ?? 'NA')}',
                  '${ApplicationLocalizations.of(context).translate(connection.additionalDetails?.propertyType ?? 'NA')}',
                  '${ApplicationLocalizations.of(context).translate(connection.connectionType ?? 'NA')}',
                  '${connection.connectionType == 'Metered' ? connection.additionalDetails?.lastDemandGeneratedDate != null && connection.additionalDetails?.lastDemandGeneratedDate != '' ? DateFormats.timeStampToDate(int.parse(connection.additionalDetails?.lastDemandGeneratedDate ?? 'NA')) : 'NA' : 'NA'}',
                  '${connection.connectionType == 'Metered' ? connection.meterId : 'NA'}',
                  '${connection.connectionType == 'Metered' ? connection.additionalDetails?.meterReading : 'NA'}',
                  '${connection.arrears != null ? '₹ ${connection.arrears}' : '-'}',
                  '${connection.penalty != null ? '₹ ${connection.penalty}' : '-'}',
                  '${connection.advance != null ? '₹ ${connection.advance}' : '-'}',
                  '${connection.additionalDetails?.totalAmount != null ? '₹ ${connection.additionalDetails?.totalAmount}' : '-'}',
                  '${connection.additionalDetails?.collectionAmount != null ? '₹ ${connection.additionalDetails?.collectionAmount}' : '-'}',
                  '${connection.additionalDetails?.collectionPendingAmount != null ? double.parse(connection.additionalDetails?.collectionPendingAmount ?? '') < 0.0 ? '₹ ${double.parse(connection.additionalDetails?.collectionPendingAmount ?? '0').abs()}' : '-' : '-'}',
                  '${connection.additionalDetails?.collectionPendingAmount != null ? double.parse(connection.additionalDetails?.collectionPendingAmount ?? '') < 0.0 ? '-' : '₹ ${double.parse(connection.additionalDetails?.collectionPendingAmount ?? '0').abs()}' : '-'}',
                  '${connection.additionalDetails?.appCreatedDate != null ? DateFormats.timeStampToDate(connection.additionalDetails?.appCreatedDate?.toInt()) : '-'}',
                  '${connection.additionalDetails?.lastDemandGeneratedDate != null && connection.additionalDetails?.lastDemandGeneratedDate != '' ? DateFormats.timeStampToDate(int.parse(connection.additionalDetails?.lastDemandGeneratedDate ?? '')) : '-'}',
                  '${connection.status.toString() == Constants.CONNECTION_STATUS.last ? 'Y' : 'N'}',
                ])
            .toList() ??
        [];

    isExcelDownload
        ? generateExcel(
            downloadHeaderList
                .map<String>((e) =>
                    '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(e)}')
                .toList(),
            excelTableData)
        : await HouseholdPdfCreator(
                context,
                headerList
                    .where((e) => e != i18.consumer.OLD_CONNECTION_ID)
                    .map<String>((e) =>
                        '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(e)}')
                    .toList(),
                pdfTableData,
                isDownload)
            .pdfPreview();
    Navigator.pop(context);
  }

  bool removeOverLay(_overlayEntry) {
    try {
      if (_overlayEntry == null) return false;
      _overlayEntry?.remove();
      return true;
    } catch (e) {
      return false;
    }
  }
}
