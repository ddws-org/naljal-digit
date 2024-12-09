// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FetchBill _$FetchBillFromJson(Map<String, dynamic> json) => FetchBill()
  ..id = json['id'] as String?
  ..mobileNumber = json['mobileNumber'] as String?
  ..payerName = json['payerName'] as String?
  ..status = json['status'] as String?
  ..totalAmount = (json['totalAmount'] as num?)?.toDouble()
  ..businessService = json['businessService'] as String?
  ..billNumber = json['billNumber'] as String?
  ..billDate = json['billDate'] as int?
  ..consumerCode = json['consumerCode'] as String?
  ..billDetails = (json['billDetails'] as List<dynamic>?)
      ?.map((e) => BillDetails.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$FetchBillToJson(FetchBill instance) => <String, dynamic>{
      'id': instance.id,
      'mobileNumber': instance.mobileNumber,
      'payerName': instance.payerName,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'businessService': instance.businessService,
      'billNumber': instance.billNumber,
      'billDate': instance.billDate,
      'consumerCode': instance.consumerCode,
      'billDetails': instance.billDetails,
    };

BillDetails _$BillDetailsFromJson(Map<String, dynamic> json) => BillDetails()
  ..id = json['id'] as String?
  ..tenantId = json['tenantId'] as String?
  ..demandId = json['demandId'] as String?
  ..billId = json['billId'] as String?
  ..expiryDate = json['expiryDate'] as int?
  ..amount = (json['amount'] as num?)?.toDouble()
  ..fromPeriod = json['fromPeriod'] as int?
  ..toPeriod = json['toPeriod'] as int?
  ..billAccountDetails = (json['billAccountDetails'] as List<dynamic>?)
      ?.map((e) => BillAccountDetails.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$BillDetailsToJson(BillDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'demandId': instance.demandId,
      'billId': instance.billId,
      'expiryDate': instance.expiryDate,
      'amount': instance.amount,
      'fromPeriod': instance.fromPeriod,
      'toPeriod': instance.toPeriod,
      'billAccountDetails': instance.billAccountDetails,
    };

BillAccountDetails _$BillAccountDetailsFromJson(Map<String, dynamic> json) =>
    BillAccountDetails()
      ..id = json['id'] as String?
      ..tenantId = json['tenantId'] as String?
      ..billDetailId = json['billDetailId'] as String?
      ..demandDetailId = json['demandDetailId'] as String?
      ..order = json['order'] as int?
      ..amount = (json['amount'] as num).toDouble()
      ..adjustedAmount = (json['adjustedAmount'] as num?)?.toDouble()
      ..advanceAdjustedAmount =
          (json['advanceAdjustedAmount'] as num?)?.toDouble()
      ..taxHeadCode = json['taxHeadCode'] as String;

Map<String, dynamic> _$BillAccountDetailsToJson(BillAccountDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'billDetailId': instance.billDetailId,
      'demandDetailId': instance.demandDetailId,
      'order': instance.order,
      'amount': instance.amount,
      'adjustedAmount': instance.adjustedAmount,
      'advanceAdjustedAmount': instance.advanceAdjustedAmount,
      'taxHeadCode': instance.taxHeadCode,
    };
