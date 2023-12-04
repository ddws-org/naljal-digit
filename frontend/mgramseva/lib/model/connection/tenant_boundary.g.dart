// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_boundary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenantBoundary _$TenantBoundaryFromJson(Map<String, dynamic> json) {
  return TenantBoundary()
    ..hierarchyType = json['hierarchyType'] == null
        ? null
        : HierarchyType.fromJson(json['hierarchyType'] as Map<String, dynamic>)
    ..boundary = (json['boundary'] as List<dynamic>?)
        ?.map((e) => Boundary.fromJson(e as Map<String, dynamic>))
        .toList()
    ..tenantId = json['tenantId'] as String?;
}

Map<String, dynamic> _$TenantBoundaryToJson(TenantBoundary instance) =>
    <String, dynamic>{
      'hierarchyType': instance.hierarchyType,
      'boundary': instance.boundary,
      'tenantId': instance.tenantId,
    };

HierarchyType _$HierarchyTypeFromJson(Map<String, dynamic> json) {
  return HierarchyType()
    ..id = json['id'] as String?
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..localName = json['localName'] as String?
    ..tenantId = json['tenantId'] as String?
    ..createdBy = json['createdBy'] as String?
    ..createdDate = json['createdDate'] as String?
    ..lastModifiedBy = json['lastModifiedBy'] as String?
    ..lastModifiedDate = json['lastModifiedDate'] as String?
    ..version = json['version'] as int?;
}

Map<String, dynamic> _$HierarchyTypeToJson(HierarchyType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'localName': instance.localName,
      'tenantId': instance.tenantId,
      'createdBy': instance.createdBy,
      'createdDate': instance.createdDate,
      'lastModifiedBy': instance.lastModifiedBy,
      'lastModifiedDate': instance.lastModifiedDate,
      'version': instance.version,
    };

Boundary _$BoundaryFromJson(Map<String, dynamic> json) {
  return Boundary()
    ..code = json['code'] as String?
    ..name = json['name'] as String?
    ..label = json['label'] as String?
    ..latitude = json['latitude'] as String?
    ..longitude = json['longitude'] as String?
    ..area = json['area'] as String?
    ..boundaryNum = json['boundaryNum'] as int?
    ..children = json['children'] as List<dynamic>?;
}

Map<String, dynamic> _$BoundaryToJson(Boundary instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'label': instance.label,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'area': instance.area,
      'boundaryNum': instance.boundaryNum,
      'children': instance.children,
    };
