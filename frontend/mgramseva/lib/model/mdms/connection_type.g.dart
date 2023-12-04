// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Connection _$ConnectionFromJson(Map<String, dynamic> json) {
  return Connection()
    ..connectionTypeList = (json['connectionType'] as List<dynamic>?)
        ?.map((e) => ConnectionType.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ConnectionToJson(Connection instance) =>
    <String, dynamic>{
      'connectionType': instance.connectionTypeList,
    };

ConnectionType _$ConnectionTypeFromJson(Map<String, dynamic> json) {
  return ConnectionType()
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..isActive = json['isActive'] as bool?;
}

Map<String, dynamic> _$ConnectionTypeToJson(ConnectionType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'isActive': instance.isActive,
    };
