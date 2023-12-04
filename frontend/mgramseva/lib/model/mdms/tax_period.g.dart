// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_period.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxPeriodListModel _$TaxPeriodListModelFromJson(Map<String, dynamic> json) {
  return TaxPeriodListModel()
    ..TaxPeriodList = (json['TaxPeriod'] as List<dynamic>?)
        ?.map((e) => TaxPeriod.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$TaxPeriodListModelToJson(TaxPeriodListModel instance) =>
    <String, dynamic>{
      'TaxPeriod': instance.TaxPeriodList,
    };

TaxPeriod _$TaxPeriodFromJson(Map<String, dynamic> json) {
  return TaxPeriod()
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..financialYear = json['financialYear'] as String?
    ..periodCycle = json['periodCycle'] as String?
    ..service = json['service'] as String?
    ..fromDate = json['fromDate'] as int?
    ..toDate = json['toDate'] as int?;
}

Map<String, dynamic> _$TaxPeriodToJson(TaxPeriod instance) => <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'financialYear': instance.financialYear,
      'periodCycle': instance.periodCycle,
      'service': instance.service,
      'fromDate': instance.fromDate,
      'toDate': instance.toDate,
    };
