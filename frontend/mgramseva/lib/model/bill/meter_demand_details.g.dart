// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter_demand_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeterDemand _$MeterDemandFromJson(Map<String, dynamic> json) {
  return MeterDemand()
    ..meterReadings = (json['meterReadings'] as List<dynamic>?)
        ?.map((e) => MeterReadings.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$MeterDemandToJson(MeterDemand instance) =>
    <String, dynamic>{
      'meterReadings': instance.meterReadings,
    };

MeterReadings _$MeterReadingsFromJson(Map<String, dynamic> json) {
  return MeterReadings()
    ..id = json['id'] as String?
    ..billingPeriod = json['billingPeriod'] as String?
    ..meterStatus = json['meterStatus'] as String?
    ..lastReading = (json['lastReading'] as num?)?.toInt()
    ..lastReadingDate = json['lastReadingDate'] as int?
    ..currentReading = (json['currentReading'] as num?)?.toInt()
    ..currentReadingDate = json['currentReadingDate'] as int?
    ..connectionNo = json['connectionNo'] as String?
    ..consumption = json['consumption'] as String?
    ..generateDemand = json['generateDemand'] as bool?
    ..tenantId = json['tenantId'] as String?;
}

Map<String, dynamic> _$MeterReadingsToJson(MeterReadings instance) =>
    <String, dynamic>{
      'id': instance.id,
      'billingPeriod': instance.billingPeriod,
      'meterStatus': instance.meterStatus,
      'lastReading': instance.lastReading,
      'lastReadingDate': instance.lastReadingDate,
      'currentReading': instance.currentReading,
      'currentReadingDate': instance.currentReadingDate,
      'connectionNo': instance.connectionNo,
      'consumption': instance.consumption,
      'generateDemand': instance.generateDemand,
      'tenantId': instance.tenantId,
    };
