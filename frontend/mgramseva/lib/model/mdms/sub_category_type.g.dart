// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sub_category_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubCategory _$SubCategoryFromJson(Map<String, dynamic> json) {
  return SubCategory()
    ..subcategoryList = (json['SubCategory'] as List<dynamic>?)
        ?.map((e) => SubCategoryType.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$SubCategoryToJson(SubCategory instance) =>
    <String, dynamic>{
      'SubCategory': instance.subcategoryList,
    };

SubCategoryType _$SubCategoryTypeFromJson(Map<String, dynamic> json) {
  return SubCategoryType()
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..taxHeadCode = json['taxHeadCode'] as String?
    ..isActive = json['isActive'] as bool?;
}

Map<String, dynamic> _$SubCategoryTypeToJson(SubCategoryType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'taxHeadCode': instance.taxHeadCode,
      'isActive': instance.isActive,
    };
