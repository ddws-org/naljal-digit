import 'package:json_annotation/json_annotation.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;

import '../../screeens/dashboard/revenue_expense_dashboard/revenue.dart';

part 'revenue_chart.g.dart';

@JsonSerializable()
class RevenueGraph {
  @JsonKey(name: "chartType")
  String? chartType;

  @JsonKey(name: "visualizationCode")
  String? visualizationCode;

  @JsonKey(name: "data")
  List<RevenueGraphData>? data;

  @JsonKey(ignore: true)
  List<charts.Series<RevenueGraphModel, dynamic>>? graphData;


  RevenueGraph();

  factory RevenueGraph.fromJson(Map<String, dynamic> json) =>
      _$RevenueGraphFromJson(json);
}


@JsonSerializable()
class RevenueGraphData {
  @JsonKey(name: "headerName")
  String? headerName;

  @JsonKey(name: "headerValue")
  int? headerValue;

  @JsonKey(name: "headerSymbol")
  String? headerSymbol;

  @JsonKey(name: "plots")
  List<RevenuePlot>? plots;


  RevenueGraphData();

  factory RevenueGraphData.fromJson(Map<String, dynamic> json) =>
      _$RevenueGraphDataFromJson(json);
}


@JsonSerializable()
class RevenuePlot {
  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "value")
  int? value;

  @JsonKey(name: "symbol")
  String? symbol;

  RevenuePlot();

  factory RevenuePlot.fromJson(Map<String, dynamic> json) =>
      _$RevenuePlotFromJson(json);
}