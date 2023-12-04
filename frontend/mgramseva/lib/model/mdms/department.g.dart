// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GPWSCRateModel _$GPWSCRateModelFromJson(Map<String, dynamic> json) =>
    GPWSCRateModel()
      ..departmentEntity = (json['departmentEntity'] as List<dynamic>?)
          ?.map((e) => Department.fromJson(e as Map<String, dynamic>))
          .toList()
      ..project = (json['project'] as List<dynamic>?)
          ?.map((e) => Project.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$GPWSCRateModelToJson(GPWSCRateModel instance) =>
    <String, dynamic>{
      'departmentEntity': instance.departmentEntity,
      'project': instance.project,
    };

Department _$DepartmentFromJson(Map<String, dynamic> json) => Department()
  ..id = json['id'] as String?
  ..tenantId = json['tenantId'] as String?
  ..code = json['code'] as String?
  ..name = json['name'] as String?
  ..departmentId = json['departmentId'] as String?
  ..children = (json['children'] as List<dynamic>?)
      ?.map((e) => Department.fromJson(e as Map<String, dynamic>))
      .toList()
  ..hierarchyLevel = json['hierarchyLevel'] as int?;

Map<String, dynamic> _$DepartmentToJson(Department instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'code': instance.code,
      'name': instance.name,
      'departmentId': instance.departmentId,
      'children': instance.children,
      'hierarchyLevel': instance.hierarchyLevel,
    };
