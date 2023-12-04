import 'package:json_annotation/json_annotation.dart';
part 'property_type.g.dart';

@JsonSerializable()
class PropertyTax {
  @JsonKey(name: "PropertyType")
  List<PropertyType>? PropertyTypeList;

  PropertyTax();

  factory PropertyTax.fromJson(Map<String, dynamic> json) =>
      _$PropertyTaxFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyTaxToJson(this);
}

@JsonSerializable()
class PropertyType {
  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "code")
  String? code;

  @JsonKey(name: "isActive")
  bool? isActive;

  PropertyType();

  factory PropertyType.fromJson(Map<String, dynamic> json) =>
      _$PropertyTypeFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyTypeToJson(this);
}
