// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchConnection _$SearchConnectionFromJson(Map<String, dynamic> json) {
  return SearchConnection()
    ..oldConnectionNumber = json['oldConnectionNumber'] as String?
    ..name = json['name'] as String?
    ..connectionNumber = json['connectionNumber'] as String?
    ..mobileNumber = json['mobileNumber'] as String?;
}

Map<String, dynamic> _$SearchConnectionToJson(SearchConnection instance) =>
    <String, dynamic>{
      'oldConnectionNumber': instance.oldConnectionNumber,
      'name': instance.name,
      'connectionNumber': instance.connectionNumber,
      'mobileNumber': instance.mobileNumber,
    };
