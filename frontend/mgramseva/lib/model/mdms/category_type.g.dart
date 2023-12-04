// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category()
    ..categoryList = (json['Category'] as List<dynamic>?)
        ?.map((e) => CategoryType.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'Category': instance.categoryList,
    };

CategoryType _$CategoryTypeFromJson(Map<String, dynamic> json) {
  return CategoryType()
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..taxHeadCode = json['taxHeadCode'] as String?
    ..isActive = json['isActive'] as bool?;
}

Map<String, dynamic> _$CategoryTypeToJson(CategoryType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'taxHeadCode': instance.taxHeadCode,
      'isActive': instance.isActive,
    };
