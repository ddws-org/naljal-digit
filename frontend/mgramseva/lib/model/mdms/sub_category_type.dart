import 'package:json_annotation/json_annotation.dart';

part 'sub_category_type.g.dart';

@JsonSerializable()
class SubCategory {
  @JsonKey(name: "SubCategory")
  List<SubCategoryType>? subcategoryList;

  SubCategory();

  factory SubCategory.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$SubCategoryToJson(this);
}

@JsonSerializable()
class SubCategoryType {
  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "code")
  String? code;

  @JsonKey(name: "taxHeadCode")
  String? taxHeadCode;

  @JsonKey(name: "isActive")
  bool? isActive;

  SubCategoryType();

  factory SubCategoryType.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryTypeFromJson(json);

  Map<String, dynamic> toJson() => _$SubCategoryTypeToJson(this);
}
