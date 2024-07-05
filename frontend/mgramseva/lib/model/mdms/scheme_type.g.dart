// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheme_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Scheme _$SchemeFromJson(Map<String, dynamic> json) {
  return Scheme()
    ..schemeType = (json['schemeType'] as List<dynamic>?)
        ?.map((e) => SchemeType.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ConnectionToJson(Scheme instance) =>
    <String, dynamic>{
      'schemeType': instance.schemeType,
    };

SchemeType _$SchemeTypeFromJson(Map<String, dynamic> json) {
  return SchemeType()
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..isActive = json['isActive'] as bool?;
}

Map<String, dynamic> _$SchemeTypeToJson(SchemeType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'isActive': instance.isActive,
    };
