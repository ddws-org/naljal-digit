// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_chart.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevenueGraph _$RevenueGraphFromJson(Map<String, dynamic> json) {
  return RevenueGraph()
    ..chartType = json['chartType'] as String?
    ..visualizationCode = json['visualizationCode'] as String?
    ..data = (json['data'] as List<dynamic>?)
        ?.map((e) => RevenueGraphData.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$RevenueGraphToJson(RevenueGraph instance) =>
    <String, dynamic>{
      'chartType': instance.chartType,
      'visualizationCode': instance.visualizationCode,
      'data': instance.data,
    };

RevenueGraphData _$RevenueGraphDataFromJson(Map<String, dynamic> json) {
  return RevenueGraphData()
    ..headerName = json['headerName'] as String?
    ..headerValue = json['headerValue'] is double ? json['headerValue'].toInt() : json['headerValue'] as int?
    ..headerSymbol = json['headerSymbol'] as String?
    ..plots = (json['plots'] as List<dynamic>?)
        ?.map((e) => RevenuePlot.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$RevenueGraphDataToJson(RevenueGraphData instance) =>
    <String, dynamic>{
      'headerName': instance.headerName,
      'headerValue': instance.headerValue,
      'headerSymbol': instance.headerSymbol,
      'plots': instance.plots,
    };

RevenuePlot _$RevenuePlotFromJson(Map<String, dynamic> json) {
  return RevenuePlot()
    ..name = json['name'] as String?
    ..value = json['value'] is double ? json['value'].toInt() :  json['value'] as int?
    ..symbol = json['symbol'] as String?;
}

Map<String, dynamic> _$RevenuePlotToJson(RevenuePlot instance) =>
    <String, dynamic>{
      'name': instance.name,
      'value': instance.value,
      'symbol': instance.symbol,
    };
