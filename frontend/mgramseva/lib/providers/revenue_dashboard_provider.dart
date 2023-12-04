import 'dart:async';

import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:mgramseva/model/dashboard/revenue_dashboard.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/repository/dashboard.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';
import 'package:mgramseva/model/dashboard/revenue_dashboard.dart' as expense;

import '../screeens/dashboard/revenue_expense_dashboard/revenue.dart';
import 'dashboard_provider.dart';

class RevenueDashboard with ChangeNotifier {
  int selectedIndex = 0;
  var revenueStreamController = StreamController.broadcast();
  var revenueDataHolder = RevenueDataHolder();


  @override
  void dispose() {
    revenueStreamController.close();
    super.dispose();
  }

  void loadGraphicalDashboard(BuildContext context) {
    revenueDataHolder.resetData();
    loadRevenueExpenseTrendLineTableDetails(context);
    // loadRevenueTrendGraphDetails(context);
    /// Enable loadRevenueTrendGraphDetails(context) if you want data from Elastic Search getChartAPI
    /// Stacked Graph not implemented due to Backend API response finalization is pending
   // loadRevenueStackedGraphDetails(context);
  }

  Map requestQuery([bool isLineChart = false]){
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    var dashBoardProvider = Provider.of<DashBoardProvider>(
        navigatorKey.currentContext!, listen: false);

      return {
        "aggregationRequestDto": {
          "visualizationType": "METRIC",
          "visualizationCode": isLineChart ? "revenueAndExpenditureTrendTwo" : "revenueAndExpenditureTrendOne",
          "queryType": "",
          "filters": {
            "tenantId": [commonProvider.userDetails?.selectedtenant?.code]
          },
          "moduleLevel": "",
          "aggregationFactors": null,
          "requestDate": {
            "startDate": dashBoardProvider.selectedMonth.startDate.millisecondsSinceEpoch,
            "endDate": dashBoardProvider.selectedMonth.endDate.millisecondsSinceEpoch,
            "interval": "month",
            "title": ""
          }
        },
        "headers": {
          "tenantId": commonProvider.userDetails?.selectedtenant?.code
        },
        "RequestInfo": {
          "apiId": "Rainmaker",
          "authToken": commonProvider.userDetails?.accessToken,
        }
      };
  }

  /// Use loadRevenueTrendGraphDetails if you want data from Elastic Search getChartAPI
  // Future<void> loadRevenueTrendGraphDetails(BuildContext context) async {
  //   var dashBoardProvider = Provider.of<DashBoardProvider>(
  //       navigatorKey.currentContext!, listen: false);
  //   revenueDataHolder.trendLineLoader = true;
  //   notifyListeners();
  //   try {
  //     var res = await DashBoardRepository().getGraphicalDashboard(requestQuery(true));
  //     if (res != null) {
  //       revenueDataHolder.trendLine = res;
  //       revenueDataHolder.trendLine?.graphData = trendGraphDataBinding(res);
  //     }
  //   } catch (e, s) {
  //     ErrorHandler().allExceptionsHandler(context, e, s);
  //   }
  //   revenueDataHolder.trendLineLoader = false;
  //   notifyListeners();
  // }
  /// Stacked Graph not implemented due to Backend API response finalization is pending
  // Future<void> loadRevenueStackedGraphDetails(BuildContext context) async {
  //   revenueDataHolder.stackLoader = true;
  //   revenueDataHolder.resetData();
  //   notifyListeners();
  //   try {
  //     var res = await DashBoardRepository().getGraphicalDashboard(requestQuery());
  //     if (res != null) {
  //       revenueDataHolder.stackedBar = res;
  //       revenueDataHolder.stackedBar?.graphData = stackedGraphDataBinding(res);
  //     }
  //   } catch (e, s) {
  //     ErrorHandler().allExceptionsHandler(context, e, s);
  //   }
  //   revenueDataHolder.stackLoader = false;
  //   notifyListeners();
  // }

  Future<void> loadRevenueExpenseTrendLineTableDetails(BuildContext context) async {
    revenueDataHolder.tableLoader = true;
    revenueDataHolder.trendLineLoader = true;
    notifyListeners();
    try {
      var commonProvider = Provider.of<CommonProvider>(
          navigatorKey.currentContext!,
          listen: false);
      var dashBoardProvider = Provider.of<DashBoardProvider>(
          navigatorKey.currentContext!, listen: false);
      var query = {
        "tenantId" : commonProvider.userDetails?.selectedtenant?.code,
        "fromDate" : dashBoardProvider.selectedMonth.startDate.millisecondsSinceEpoch.toString(),
        "toDate" : dashBoardProvider.selectedMonth.endDate.millisecondsSinceEpoch.toString()
      };

      var res1 = await DashBoardRepository().fetchRevenueDetails(query);
      var res2 = await DashBoardRepository().fetchExpenseDetails(query);
      var filteredList = <TableDataRow>[];
      if (res1 != null && res1.isNotEmpty && res2 != null && res2.isNotEmpty) {
        var totalDetails = TotalDetails();

        /// If any month is missing it will set the default values for that month
        setDefaultTableValue(res1, res2);
        revenueDataHolder.revenueTrendLine = res1;
        revenueDataHolder.expenseTrendLine = res2;
        revenueDataHolder.graphData = trendGraphDataBinding(res1, res2);
        for(int i =0 ; i < res1.length ; i++) {
          var collection = res1[i];
          var expense = res2[i];
          var surplus = int.parse(collection.pendingCollection ?? '0') - int.parse(expense.amountUnpaid ?? '0');
          filteredList.add(
              TableDataRow([
                TableData('${DateFormats.getMonthAndYearFromDateTime(
                    DateFormats.getFormattedDateToDateTime(
                        DateFormats.timeStampToDate(collection.month))!)}',
                    callBack: onTapOfMonth,
                apiKey: collection.month.toString()),
                TableData('${surplus.abs()}', style: TextStyle(color: surplus.isNegative ?
                Color.fromRGBO(255, 0, 0, 1) :
                Color.fromRGBO(0, 128, 0, 1))),
                TableData('${collection.demand ?? '-'}(${collection.arrears})'),
                TableData('${collection.pendingCollection ?? '-'}'),
                TableData('${collection.actualCollection ?? '-'}'),
                TableData('${expense.totalExpenditure ?? '-'}'),
                TableData('${expense.amountUnpaid ?? '-'}'),
                TableData('${expense.amountPaid ?? '-'}'),
              ]));

          totalDetails.surplus += surplus;
          totalDetails.demand += num.parse(collection.demand ?? '0');
          if(i == res1.length - 1) totalDetails.arrears += num.parse(collection.arrears ?? '0') + num.parse(collection.pendingCollection ?? '0');
          totalDetails.pendingCollection += num.parse(collection.pendingCollection ?? '0');
          totalDetails.actualCollection += num.parse(collection.actualCollection ?? '0');
          totalDetails.totalExpenditure += num.parse(expense.totalExpenditure ?? '0');
          totalDetails.amountUnpaid += num.parse(expense.amountUnpaid ?? '0');
          totalDetails.amountPaid += num.parse(expense.amountPaid ?? '0');

        }



        filteredList.add(TableDataRow([
          TableData(i18.common.TOTAL,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black
            )
              ),
          TableData('${totalDetails.surplus.abs()}', style: TextStyle(color: totalDetails.surplus.isNegative ?
          Color.fromRGBO(255, 0, 0, 1) :
          Color.fromRGBO(0, 128, 0, 1))),
          TableData('${totalDetails.demand}(${totalDetails.arrears})'),
          TableData('${totalDetails.pendingCollection}'),
          TableData('${totalDetails.actualCollection}'),
          TableData('${totalDetails.totalExpenditure}'),
          TableData('${totalDetails.amountUnpaid}'),
          TableData('${totalDetails.amountPaid}'),
        ]));

      }
      revenueDataHolder.revenueTable = filteredList;
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(context, e, s);
    }
    revenueDataHolder.trendLineLoader = false;
    revenueDataHolder.tableLoader = false;
    notifyListeners();
  }

  setDefaultTableValue(List<Revenue> revenues, List<expense.Expense> expenses){
    try{
      for(int i = 0; i < revenues.length; i++){
        var index = expenses.indexWhere((e) => e.month == revenues[i].month);
        if(index == -1){
          var expenditure = expense.Expense()
          ..month = revenues[i].month
          ..amountPaid = '0'
          ..amountUnpaid = '0'
          ..totalExpenditure = '0';
          expenses.insert(i, expenditure);
        }
      }

      for(int i = 0; i < expenses.length; i++){
        var index = revenues.indexWhere((e) => e.month == expenses[i].month);
        if(index == -1){
          var revenue = Revenue()
            ..month = expenses[i].month
            ..demand = '0'
            ..pendingCollection = '0'
            ..actualCollection = '0'
            ..arrears = '0';
          revenues.insert(i, revenue);
        }
      }
    }catch(e,s){
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e,s);
    }
  }

  void setSelectedTab(int index) {
    /// Disabled tapping functionality
    // return;
    // selectedIndex = index;
    // notifyListeners();
  }

  List<String> getTabs(BuildContext context) {
    return [
      /// Stacked Graph not implemented due to Backend API response finalization is pending
      //i18.dashboard.STACKED_BAR,
      i18.dashboard.TREND_LINE
    ];
  }

  List<TableHeader> get revenueHeaderList =>
      [
        TableHeader(i18.common.MONTH),
        TableHeader(i18.dashboard.SURPLUS_DEFICIT),
        TableHeader(i18.dashboard.DEMAND_ARREARS),
        TableHeader(i18.dashboard.PENIDNG_COLLECTIONS),
        TableHeader(i18.dashboard.ACTUAL_COLLECTIONS),
        TableHeader(i18.dashboard.EXPENDITURE),
        TableHeader(i18.dashboard.PENDING_EXPENDITURE),
        TableHeader(i18.dashboard.ACTUAL_PAYMENT),
      ];

  void onTapOfMonth(TableData tableData) {
    var dashBoardProvider = Provider.of<DashBoardProvider>(
        navigatorKey.currentContext!, listen: false);

    var monthIndex = DateTime.fromMillisecondsSinceEpoch(int.parse(tableData.apiKey.toString())).month;
    var date = monthIndex >= 4
        ? dashBoardProvider.selectedMonth.startDate
        : dashBoardProvider.selectedMonth.endDate;
    dashBoardProvider.onChangeOfDate(DatePeriod(
        DateTime(date.year, monthIndex, 1),
        DateTime(date.year, monthIndex + 1, 0,  23,59, 59, 999), DateType.MONTH),
        navigatorKey.currentContext!);
    dashBoardProvider.scrollController.jumpTo(0.0);
  }

  List<charts.Series<RevenueGraphModel, int>>? trendGraphDataBinding(
      List<Revenue> revenues, List<expense.Expense> expenses) {
    Map revenueData = {};
    Map expenseData = {};
    var list = <charts.Series<RevenueGraphModel, int>>[];

    ///TO GET TREND LINE DATA FROM REVENUE and CHALLAN COLLECTION USE BELOW LOGIC
    revenues.forEach((e) {
      revenueData[i18.dashboard.REVENUE] ??= {};
      revenueData[i18.dashboard.REVENUE]['${DateFormats.getMonth(
          DateFormats.getFormattedDateToDateTime(
              DateFormats.timeStampToDate(e.month))!)}'] = int.parse(e.actualCollection.toString());
    });
    expenses.forEach((e) {
      expenseData[i18.dashboard.EXPENDITURE] ??= {};
      expenseData[i18.dashboard.EXPENDITURE]['${DateFormats.getMonth(
          DateFormats.getFormattedDateToDateTime(
              DateFormats.timeStampToDate(e.month))!)}'] = int.parse(e.amountPaid.toString());
    });

    ///TO GET DATA FROM ELASTIC SEARCH USE BELOW COMMENTED LOGIC.
    // revenueGraph.data?.firstWhere((e) =>  e.headerName == "WaterService").plots?.forEach((e) {
    //   revenueData[i18.dashboard.REVENUE] ??= {};
    //   revenueData[i18.dashboard.REVENUE][e.name] = e.value;
    // });

    // revenueGraph.data?.firstWhere((e) => e.headerName == "ExpenseService").plots?.forEach((e) {
    //   expenseData[i18.dashboard.EXPENDITURE] ??= {};
    //   expenseData[i18.dashboard.EXPENDITURE][e.name] = e.value;
    // });

    revenueData.forEach((key, value) {
      var data = <RevenueGraphModel>[];
      var index = 0;
      value.forEach((month, value) {
        data.add(RevenueGraphModel(month : index, trend : value, color: charts.Color.fromHex(code: '#406ABB')));
        index++;
      });
      list.add(charts.Series<RevenueGraphModel, int>(
        id: 'Trend1',
        colorFn: (RevenueGraphModel sales, _) => sales.color ?? charts.MaterialPalette.blue.shadeDefault ,
        domainFn: (RevenueGraphModel sales, _) => sales.month,
        measureFn: (RevenueGraphModel sales, _) => sales.trend,
        labelAccessorFn: (RevenueGraphModel sales, _) => sales.trend.toString(),
        data: data,
      ));
    });

    expenseData.forEach((key, value) {
      var data = <RevenueGraphModel>[];
      var index = 0;
      value.forEach((month, value) {
        data.add(RevenueGraphModel(month : index, trend : value, color: charts.Color.fromHex(code: '#FF0000')));
        index++;
      });
      list.add(charts.Series<RevenueGraphModel, int>(
        id: 'Trend2',
        colorFn: (RevenueGraphModel sales, _) => sales.color ?? charts.MaterialPalette.red.shadeDefault,
        domainFn: (RevenueGraphModel sales, _) => sales.month,
        measureFn: (RevenueGraphModel sales, _) => sales.trend,
        labelAccessorFn: (RevenueGraphModel sales, _) => sales.trend.toString(),
        data: data,
      ));
    });

    return list;
  }

/// Stacked Graph not implemented due to Backend API response finalization is pending
  // List<charts.Series<RevenueGraphModel, String>>? stackedGraphDataBinding(
  //     RevenueGraph revenueGraph) {
  //   Map revenueData = {};
  //   Map expenseData = {};
  //
  //   var color = {
  //     'RESIDENTIAL' :  '#4069bb',
  //     'COMMERCIAL' : '#bcd3ff',
  //     'SALARY' : '#2fc5e5',
  //     "OM" : '#fbc02d',
  //     "ELECTRICITY_BILL" : '#13d8cc'
  //   };
  //
  //   var list = <charts.Series<RevenueGraphModel, String>>[];
  //
  //   revenueGraph.waterService?.buckets?.forEach((e) {
  //     var date = DateTime.fromMillisecondsSinceEpoch(e.key ?? 0);
  //     e.propertyType?.bucket?.forEach((bucket) {
  //       revenueData[bucket.key] ??= {};
  //       revenueData[bucket.key][date.year] = bucket.count?['value'] ?? '';
  //     });
  //   });
  //
  //   revenueData.forEach((key, value) {
  //     var data = <RevenueGraphModel>[];
  //     value.forEach((year, value) {
  //       var legendColor = charts.Color.fromHex(code: color[key] ?? '#4069bb');
  //       revenueDataHolder.revenueLabels.add(Legend(key, color[key] ?? '#4069bb'));
  //       data.add(RevenueGraphModel(year : year.toString(), trend : value.toInt(), color: legendColor));
  //     });
  //     list.add(charts.Series<RevenueGraphModel, String>(
  //       id: 'Tablet A',
  //       seriesCategory: 'Revenue',
  //       domainFn: (RevenueGraphModel sales, _) => sales.year,
  //       measureFn: (RevenueGraphModel sales, _) => sales.trend,
  //       colorFn: (RevenueGraphModel sales, _) => sales.color ??  charts.MaterialPalette.yellow.shadeDefault,
  //       data: data,
  //     ));
  //   });
  //
  //   revenueGraph.expense?.buckets?.forEach((e) {
  //     var date = DateTime.fromMillisecondsSinceEpoch(e.key ?? 0);
  //     e.expenseType?.bucket?.forEach((bucket) {
  //       expenseData[bucket.key] ??= {};
  //       expenseData[bucket.key][date.year] = bucket.count?['value'] ?? '';
  //     });
  //   });
  //
  //   expenseData.forEach((key, value) {
  //     var data = <RevenueGraphModel>[];
  //     value.forEach((year, value) {
  //       var legendColor = charts.Color.fromHex(code: color[key] ?? '#4069bb');
  //       revenueDataHolder.expenseLabels.add(Legend(key,  color[key] ?? '#4069bb'));
  //       data.add(RevenueGraphModel(year : year.toString(), trend : value.toInt(), color: legendColor));
  //     });
  //     list.add(charts.Series<RevenueGraphModel, String>(
  //       id: 'Tablet B',
  //       seriesCategory: 'expense',
  //       domainFn: (RevenueGraphModel sales, _) => sales.year,
  //       measureFn: (RevenueGraphModel sales, _) => sales.trend,
  //       colorFn: (RevenueGraphModel sales, _) => sales.color ??  charts.MaterialPalette.red.shadeDefault,
  //       data: data,
  //     ));
  //   });
  //
  //   return list;
  // }
}