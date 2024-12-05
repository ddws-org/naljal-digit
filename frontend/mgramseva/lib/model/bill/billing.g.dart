// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillList _$BillListFromJson(Map<String, dynamic> json) => BillList()
  ..bill = (json['Bill'] as List<dynamic>?)
      ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$BillListToJson(BillList instance) => <String, dynamic>{
      'Bill': instance.bill,
    };

Bill _$BillFromJson(Map<String, dynamic> json) => Bill()
  ..id = json['id'] as String?
  ..mobileNumber = json['mobileNumber'] as String?
  ..payerName = json['payerName'] as String?
  ..payerAddress = json['payerAddress'] as String?
  ..payerEmail = json['payerEmail'] as String?
  ..status = json['status'] as String?
  ..totalAmount = (json['totalAmount'] as num?)?.toDouble()
  ..penalty = (json['penalty'] as num?)?.toDouble()
  ..netAmountDueWithPenalty =
      (json['netAmountDueWithPenalty'] as num?)?.toDouble()
  ..businessService = json['businessService'] as String?
  ..billNumber = json['billNumber'] as String?
  ..billDate = (json['billDate'] as num?)?.toInt()
  ..consumerCode = json['consumerCode'] as String?
  ..billDetails = (json['billDetails'] as List<dynamic>?)
      ?.map((e) => BillDetails.fromJson(e as Map<String, dynamic>))
      .toList()
  ..tenantId = json['tenantId'] as String?
  ..fileStoreId = json['fileStoreId'] as String?
  ..auditDetails = json['auditDetails'] == null
      ? null
      : AuditDetails.fromJson(json['auditDetails'] as Map<String, dynamic>)
  ..meterReadings = (json['meterReadings'] as List<dynamic>?)
      ?.map((e) => MeterReadings.fromJson(e as Map<String, dynamic>))
      .toList()
  ..waterConnection = json['waterconnection'] == null
      ? null
      : WaterConnection.fromJson(
          json['waterconnection'] as Map<String, dynamic>);

Map<String, dynamic> _$BillToJson(Bill instance) => <String, dynamic>{
      'id': instance.id,
      'mobileNumber': instance.mobileNumber,
      'payerName': instance.payerName,
      'payerAddress': instance.payerAddress,
      'payerEmail': instance.payerEmail,
      'status': instance.status,
      'totalAmount': instance.totalAmount,
      'penalty': instance.penalty,
      'netAmountDueWithPenalty': instance.netAmountDueWithPenalty,
      'businessService': instance.businessService,
      'billNumber': instance.billNumber,
      'billDate': instance.billDate,
      'consumerCode': instance.consumerCode,
      'billDetails': instance.billDetails,
      'tenantId': instance.tenantId,
      'fileStoreId': instance.fileStoreId,
      'auditDetails': instance.auditDetails,
      'meterReadings': instance.meterReadings,
      'waterconnection': instance.waterConnection,
    };

BillDetails _$BillDetailsFromJson(Map<String, dynamic> json) => BillDetails()
  ..id = json['id'] as String?
  ..tenantId = json['tenantId'] as String?
  ..demandId = json['demandId'] as String?
  ..billId = json['billId'] as String?
  ..expiryDate = (json['expiryDate'] as num?)?.toInt()
  ..amount = (json['amount'] as num?)?.toDouble()
  ..fromPeriod = (json['fromPeriod'] as num?)?.toInt()
  ..toPeriod = (json['toPeriod'] as num?)?.toInt()
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
      ..order = (json['order'] as num?)?.toInt()
      ..amount = (json['amount'] as num?)?.toDouble()
      ..adjustedAmount = (json['adjustedAmount'] as num?)?.toDouble()
      ..taxHeadCode = json['taxHeadCode'] as String?;

Map<String, dynamic> _$BillAccountDetailsToJson(BillAccountDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'billDetailId': instance.billDetailId,
      'demandDetailId': instance.demandDetailId,
      'order': instance.order,
      'amount': instance.amount,
      'adjustedAmount': instance.adjustedAmount,
      'taxHeadCode': instance.taxHeadCode,
    };

AuditDetails _$AuditDetailsFromJson(Map<String, dynamic> json) => AuditDetails()
  ..createdBy = json['createdBy'] as String?
  ..lastModifiedBy = json['lastModifiedBy'] as String?
  ..createdTime = (json['createdTime'] as num?)?.toInt()
  ..lastModifiedTime = (json['lastModifiedTime'] as num?)?.toInt();

Map<String, dynamic> _$AuditDetailsToJson(AuditDetails instance) =>
    <String, dynamic>{
      'createdBy': instance.createdBy,
      'lastModifiedBy': instance.lastModifiedBy,
      'createdTime': instance.createdTime,
      'lastModifiedTime': instance.lastModifiedTime,
    };
