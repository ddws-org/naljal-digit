// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyTax _$PropertyTaxFromJson(Map<String, dynamic> json) {
  return PropertyTax()
    ..PropertyTypeList = (json['PropertyType'] as List<dynamic>?)
        ?.map((e) => PropertyType.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$PropertyTaxToJson(PropertyTax instance) =>
    <String, dynamic>{
      'PropertyType': instance.PropertyTypeList,
    };

PropertyType _$PropertyTypeFromJson(Map<String, dynamic> json) {
  return PropertyType()
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..isActive = json['isActive'] as bool?;
}

Map<String, dynamic> _$PropertyTypeToJson(PropertyType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'isActive': instance.isActive,
    };
