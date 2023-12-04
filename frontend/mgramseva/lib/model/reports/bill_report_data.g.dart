// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_report_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillReportData _$BillReportDataFromJson(Map<String, dynamic> json) =>
    BillReportData()
      ..tenantName = json['tenantName'] as String?
      ..consumerName = json['consumerName'] as String?
      ..connectionNo = json['connectionNo'] as String?
      ..oldConnectionNo = json['oldConnectionNo'] as String?
      ..consumerCreatedOnDate = json['consumerCreatedOnDate'] as String?
      ..penalty = (json['penalty'] as num?)?.toDouble()
      ..advance = (json['advance'] as num?)?.toDouble()
      ..demandAmount = (json['demandAmount'] as num?)?.toDouble()
      ..userId = json['userId'] as String?;

Map<String, dynamic> _$BillReportDataToJson(BillReportData instance) =>
    <String, dynamic>{
      'tenantName': instance.tenantName,
      'consumerName': instance.consumerName,
      'connectionNo': instance.connectionNo,
      'oldConnectionNo': instance.oldConnectionNo,
      'consumerCreatedOnDate': instance.consumerCreatedOnDate,
      'penalty': instance.penalty,
      'advance': instance.advance,
      'demandAmount': instance.demandAmount,
      'userId': instance.userId,
    };
