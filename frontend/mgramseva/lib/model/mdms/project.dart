/*
  * @author Saloni
  * saloni.bajaj@egovernments.org
  *
  * */

import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

@JsonSerializable()
class Project {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "expenditureId")
  String? expenditureId;
  @JsonKey(name: "departmentEntityIds",includeIfNull: false)
  List<dynamic>? departmentEntityIds;
  @JsonKey(name: "locationIds",includeIfNull: false)
  List<dynamic>? locationIds;

  Project();

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

@JsonSerializable()
class ProjectRequest {
  @JsonKey(name: "departmentEntityId")
  String? departmentEntityId;
  @JsonKey(name: "tenantId")
  String? tenantId;

  ProjectRequest();

  factory ProjectRequest.fromJson(Map<String, dynamic> json) =>
      _$ProjectRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectRequestToJson(this);
}
