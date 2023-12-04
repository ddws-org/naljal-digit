import 'package:json_annotation/json_annotation.dart';
part 'tenant_boundary.g.dart';

@JsonSerializable()
class TenantBoundary {
  HierarchyType? hierarchyType;
  List<Boundary>? boundary;
  String? tenantId;
  TenantBoundary();

  factory TenantBoundary.fromJson(Map<String, dynamic> json) =>
      _$TenantBoundaryFromJson(json);
}

@JsonSerializable()
class HierarchyType {
  String? id;
  String? name;
  String? code;
  String? localName;
  String? tenantId;
  String? createdBy;
  String? createdDate;
  String? lastModifiedBy;
  String? lastModifiedDate;
  int? version;
  HierarchyType();
  factory HierarchyType.fromJson(Map<String, dynamic> json) =>
      _$HierarchyTypeFromJson(json);
}

@JsonSerializable()
class Boundary {
  String? code;
  String? name;
  String? label;
  String? latitude;
  String? longitude;
  String? area;
  int? boundaryNum;
  List? children;
  Boundary();
  factory Boundary.fromJson(Map<String, dynamic> json) =>
      _$BoundaryFromJson(json);
}
