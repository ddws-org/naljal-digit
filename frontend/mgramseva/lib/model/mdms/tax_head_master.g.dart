// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_head_master.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxHeadMaster _$TaxHeadMasterFromJson(Map<String, dynamic> json) {
  return TaxHeadMaster()
    ..category = json['category'] as String?
    ..service = json['service'] as String?
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..isDebit = json['isDebit'] as bool?
    ..isActualDemand = json['isActualDemand'] as bool?
    ..order = json['order'] as String?
    ..isRequired = json['isRequired'] as bool?;
}

Map<String, dynamic> _$TaxHeadMasterToJson(TaxHeadMaster instance) =>
    <String, dynamic>{
      'category': instance.category,
      'service': instance.service,
      'name': instance.name,
      'code': instance.code,
      'isDebit': instance.isDebit,
      'isActualDemand': instance.isActualDemand,
      'order': instance.order,
      'isRequired': instance.isRequired,
    };
