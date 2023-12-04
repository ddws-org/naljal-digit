

import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:mgramseva/model/dashboard/revenue_dashboard.dart';
import 'package:mgramseva/model/dashboard/revenue_chart.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:mgramseva/utils/models.dart';

class RevenueDataHolder {

  RevenueGraph? stackedBar;
  List<Revenue>? revenueTrendLine;
  List<Expense>? expenseTrendLine;
  List<TableDataRow>? revenueTable;
  List<charts.Series<RevenueGraphModel, dynamic>>? graphData;
  var stackLoader = false;
  var trendLineLoader = false;
  var tableLoader = false;
  var expenseLabels = <Legend>[];
  var revenueLabels = <Legend>[];

  resetData(){
    stackedBar = null;
    revenueTrendLine = null;
    expenseTrendLine = null;
    revenueTable = null;
    expenseLabels.clear();
    revenueLabels.clear();
  }
}

class RevenueGraphModel {
  final int month;
  final int trend;
  final String year;
  Color? color;

  RevenueGraphModel({this.month = 1, required this.trend, this.year = '', this.color});
}
