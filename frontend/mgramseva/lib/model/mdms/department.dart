import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/mdms/project.dart';

part 'department.g.dart';

@JsonSerializable()
class GPWSCRateModel {
  @JsonKey(name: "departmentEntity")
  List<Department>? departmentEntity;
  @JsonKey(name: "project")
  List<Project>? project;

  GPWSCRateModel();

  factory GPWSCRateModel.fromJson(Map<String, dynamic> json) =>
      _$GPWSCRateModelFromJson(json);

  Map<String, dynamic> toJson() => _$GPWSCRateModelToJson(this);
}

@JsonSerializable()
class Department {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "departmentId")
  String? departmentId;
  @JsonKey(name: "children")
  List<Department>? children;
  @JsonKey(name: "hierarchyLevel")
  int? hierarchyLevel;
  @JsonKey(name:"project", includeFromJson: false,includeToJson: true)
  Project? project;
  Department();

  factory Department.fromJson(Map<String, dynamic> json) =>
      _$DepartmentFromJson(json);

  Map<String, dynamic> toJson() => _$DepartmentToJson(this);
}
