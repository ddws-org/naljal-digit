// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateTransactionDetails _$UpdateTransactionDetailsFromJson(
    Map<String, dynamic> json) {
  return UpdateTransactionDetails()
    ..transaction = (json['Transaction'] as List<dynamic>?)
        ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$UpdateTransactionDetailsToJson(
        UpdateTransactionDetails instance) =>
    <String, dynamic>{
      'Transaction': instance.transaction,
    };
