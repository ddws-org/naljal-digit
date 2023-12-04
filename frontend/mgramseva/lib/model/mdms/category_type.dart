import 'package:json_annotation/json_annotation.dart';

part 'category_type.g.dart';

@JsonSerializable()
class Category {
  @JsonKey(name: "Category")
  List<CategoryType>? categoryList;

  Category();

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class CategoryType {
  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "code")
  String? code;

  @JsonKey(name: "taxHeadCode")
  String? taxHeadCode;

  @JsonKey(name: "isActive")
  bool? isActive;

  CategoryType();

  factory CategoryType.fromJson(Map<String, dynamic> json) =>
      _$CategoryTypeFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryTypeToJson(this);
}
