// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_generation_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillGenerationDetails _$BillGenerationDetailsFromJson(
        Map<String, dynamic> json) =>
    BillGenerationDetails()
      ..tenantId = json['tenantId'] as String?
      ..currentReading = json['currentReading'] as int?
      ..currentReadingDate = json['currentReadingDate'] as int?
      ..connectionNo = json['connectionNo'] as String?
      ..billingPeriod = json['billingPeriod'] as String?
      ..lastReading = json['lastReading'] as int?
      ..meterStatus = json['meterStatus'] as String?
      ..lastReadingDate = json['lastReadingDate'] as int?
      ..generateDemand = json['generateDemand'] as bool?
      ..connectionCategory = json['connectionCategory'] as String?
      ..serviceCat = json['serviceCat'] as String?
      ..serviceType = json['serviceType'] as String?
      ..propertyType = json['propertyType'] as String?
      ..billYear = json['billYear'] == null
          ? null
          : TaxPeriod.fromJson(json['billYear'] as Map<String, dynamic>)
      ..billCycle = json['billCycle'] as String?
      ..meterNumber = json['meterNumber'] as String?
      ..oldMeterReading = json['oldMeterReading'] as String?
      ..newMeterReading = json['newMeterReading'] as String?
      ..meterReadingDate = json['meterReadingDate'] as int?;

Map<String, dynamic> _$BillGenerationDetailsToJson(
        BillGenerationDetails instance) =>
    <String, dynamic>{
      'tenantId': instance.tenantId,
      'currentReading': instance.currentReading,
      'currentReadingDate': instance.currentReadingDate,
      'connectionNo': instance.connectionNo,
      'billingPeriod': instance.billingPeriod,
      'lastReading': instance.lastReading,
      'meterStatus': instance.meterStatus,
      'lastReadingDate': instance.lastReadingDate,
      'generateDemand': instance.generateDemand,
      'connectionCategory': instance.connectionCategory,
      'serviceCat': instance.serviceCat,
      'serviceType': instance.serviceType,
      'propertyType': instance.propertyType,
      'billYear': instance.billYear,
      'billCycle': instance.billCycle,
      'meterNumber': instance.meterNumber,
      'oldMeterReading': instance.oldMeterReading,
      'newMeterReading': instance.newMeterReading,
      'meterReadingDate': instance.meterReadingDate,
    };
