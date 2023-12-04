// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_dashboard.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Revenue _$RevenueFromJson(Map<String, dynamic> json) {
  return Revenue()
    ..month = json['month'] as int?
    ..demand = json['demand'] as String?
    ..pendingCollection = json['pendingCollection'] as String?
    ..arrears = json['arrears'] as String?
    ..actualCollection = json['actualCollection'] as String?;
}

Map<String, dynamic> _$RevenueToJson(Revenue instance) => <String, dynamic>{
      'month': instance.month,
      'demand': instance.demand,
      'pendingCollection': instance.pendingCollection,
      'arrears': instance.arrears,
      'actualCollection': instance.actualCollection,
    };

Expense _$ExpenseFromJson(Map<String, dynamic> json) {
  return Expense()
    ..month = json['month'] as int?
    ..totalExpenditure = json['totalExpenditure'] as String?
    ..amountUnpaid = json['amountUnpaid'] as String?
    ..amountPaid = json['amountPaid'] as String?;
}

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'month': instance.month,
      'totalExpenditure': instance.totalExpenditure,
      'amountUnpaid': instance.amountUnpaid,
      'amountPaid': instance.amountPaid,
    };
