// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_connections.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaterConnections _$WaterConnectionsFromJson(Map<String, dynamic> json) =>
    WaterConnections()
      ..waterConnection = (json['WaterConnection'] as List<dynamic>?)
          ?.map((e) => WaterConnection.fromJson(e as Map<String, dynamic>))
          .toList()
      ..waterConnectionData = (json['waterConnectionData'] as List<dynamic>?)
              ?.map((e) => WaterConnection.fromJson(e as Map<String, dynamic>))
              .toList() ??
          []
      ..tabData = json['propertyCount'] as Map<String, dynamic>?
      ..collectionDataCount = json['collectionDataCount'] == null
          ? null
          : CollectionDataCount.fromJson(
              json['collectionDataCount'] as Map<String, dynamic>)
      ..totalCount = json['totalCount'] as int? ?? 0;

Map<String, dynamic> _$WaterConnectionsToJson(WaterConnections instance) =>
    <String, dynamic>{
      'WaterConnection': instance.waterConnection,
      'waterConnectionData': instance.waterConnectionData,
      'propertyCount': instance.tabData,
      'collectionDataCount': instance.collectionDataCount,
      'totalCount': instance.totalCount,
    };

CollectionDataCount _$CollectionDataCountFromJson(Map<String, dynamic> json) =>
    CollectionDataCount()
      ..collectionPending = json['collectionPending'] as int?
      ..collectionPaid = json['collectionPaid'] as int?;

Map<String, dynamic> _$CollectionDataCountToJson(
        CollectionDataCount instance) =>
    <String, dynamic>{
      'collectionPending': instance.collectionPending,
      'collectionPaid': instance.collectionPaid,
    };
