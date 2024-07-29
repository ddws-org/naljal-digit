import 'package:json_annotation/json_annotation.dart';

part 'scheme_type.g.dart';

@JsonSerializable()
class Scheme {
  @JsonKey(name: "schemeType")
  List<SchemeType>? schemeType;

  Scheme();

  factory Scheme.fromJson(Map<String, dynamic> json) =>
      _$SchemeFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionToJson(this);
}

@JsonSerializable()
class SchemeType {
  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "code")
  String? code;

  @JsonKey(name: "isActive")
  bool? isActive;

  SchemeType();

  factory SchemeType.fromJson(Map<String, dynamic> json) =>
      _$SchemeTypeFromJson(json);

  Map<String, dynamic> toJson() => _$SchemeTypeToJson(this);
}
