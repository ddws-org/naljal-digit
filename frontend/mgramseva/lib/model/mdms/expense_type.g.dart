// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) {
  return Expense()
    ..expenseList = (json['ExpenseType'] as List<dynamic>?)
        ?.map((e) => ExpenseType.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'ExpenseType': instance.expenseList,
    };

ExpenseType _$ExpenseTypeFromJson(Map<String, dynamic> json) {
  return ExpenseType()
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..taxHeadCode = json['taxHeadCode'] as String?
    ..isActive = json['active'] as bool?;
}

Map<String, dynamic> _$ExpenseTypeToJson(ExpenseType instance) =>
    <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'taxHeadCode': instance.taxHeadCode,
      'active': instance.isActive,
    };
