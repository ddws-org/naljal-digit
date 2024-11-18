// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_payments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillPayments _$BillPaymentsFromJson(Map<String, dynamic> json) => BillPayments()
  ..payments = (json['Payments'] as List<dynamic>?)
      ?.map((e) => Payments.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$BillPaymentsToJson(BillPayments instance) =>
    <String, dynamic>{
      'Payments': instance.payments,
    };

Payments _$PaymentsFromJson(Map<String, dynamic> json) => Payments()
  ..id = json['id'] as String?
  ..tenantId = json['tenantId'] as String?
  ..totalDue = (json['totalDue'] as num?)?.toDouble()
  ..totalAmountPaid = (json['totalAmountPaid'] as num?)?.toDouble()
  ..transactionNumber = json['transactionNumber'] as String?
  ..transactionDate = json['transactionDate'] as int?
  ..paymentMode = json['paymentMode'] as String?
  ..instrumentDate = json['instrumentDate'] as int?
  ..instrumentNumber = json['instrumentNumber'] as String?
  ..instrumentStatus = json['instrumentStatus'] as String?
  ..ifscCode = json['ifscCode'] as String?
  ..auditDetails = json['auditDetails'] == null
      ? null
      : AuditDetails.fromJson(json['auditDetails'] as Map<String, dynamic>)
  ..paymentDetails = (json['paymentDetails'] as List<dynamic>?)
      ?.map((e) => PaymentDetails.fromJson(e as Map<String, dynamic>))
      .toList()
  ..paidBy = json['paidBy'] as String?
  ..mobileNumber = json['mobileNumber'] as String?
  ..payerName = json['payerName'] as String?
  ..payerAddress = json['payerAddress'] as String?
  ..payerEmail = json['payerEmail'] as String?
  ..payerId = json['payerId'] as String?
  ..paymentStatus = json['paymentStatus'] as String?
  ..fileStoreId = json['fileStoreId'] as String?;

Map<String, dynamic> _$PaymentsToJson(Payments instance) => <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'totalDue': instance.totalDue,
      'totalAmountPaid': instance.totalAmountPaid,
      'transactionNumber': instance.transactionNumber,
      'transactionDate': instance.transactionDate,
      'paymentMode': instance.paymentMode,
      'instrumentDate': instance.instrumentDate,
      'instrumentNumber': instance.instrumentNumber,
      'instrumentStatus': instance.instrumentStatus,
      'ifscCode': instance.ifscCode,
      'auditDetails': instance.auditDetails,
      'paymentDetails': instance.paymentDetails,
      'paidBy': instance.paidBy,
      'mobileNumber': instance.mobileNumber,
      'payerName': instance.payerName,
      'payerAddress': instance.payerAddress,
      'payerEmail': instance.payerEmail,
      'payerId': instance.payerId,
      'paymentStatus': instance.paymentStatus,
      'fileStoreId': instance.fileStoreId,
    };

AuditDetails _$AuditDetailsFromJson(Map<String, dynamic> json) => AuditDetails()
  ..createdBy = json['id'] as String?
  ..createdTime = json['createdTime'] as int?
  ..lastModifiedBy = json['lastModifiedBy'] as String?
  ..lastModifiedTime = json['lastModifiedTime'] as int?;

Map<String, dynamic> _$AuditDetailsToJson(AuditDetails instance) =>
    <String, dynamic>{
      'id': instance.createdBy,
      'createdTime': instance.createdTime,
      'lastModifiedBy': instance.lastModifiedBy,
      'lastModifiedTime': instance.lastModifiedTime,
    };

PaymentDetails _$PaymentDetailsFromJson(Map<String, dynamic> json) =>
    PaymentDetails()
      ..paymentId = json['paymentId'] as String?
      ..id = json['id'] as String?
      ..tenantId = json['tenantId'] as String?
      ..totalDue = (json['totalDue'] as num?)?.toDouble()
      ..totalAmountPaid = (json['totalAmountPaid'] as num?)?.toDouble()
      ..receiptNumber = json['receiptNumber'] as String?
      ..manualReceiptNumber = json['manualReceiptNumber'] as String?
      ..manualReceiptDate = json['manualReceiptDate'] as int?
      ..receiptDate = json['receiptDate'] as int?
      ..receiptType = json['receiptType'] as String?
      ..businessService = json['businessService'] as String?
      ..billId = json['billId'] as String?
      ..bill = json['bill'] == null
          ? null
          : Bill.fromJson(json['bill'] as Map<String, dynamic>)
      ..auditDetails = json['auditDetails'] == null
          ? null
          : AuditDetails.fromJson(json['auditDetails'] as Map<String, dynamic>);

Map<String, dynamic> _$PaymentDetailsToJson(PaymentDetails instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'id': instance.id,
      'tenantId': instance.tenantId,
      'totalDue': instance.totalDue,
      'totalAmountPaid': instance.totalAmountPaid,
      'receiptNumber': instance.receiptNumber,
      'manualReceiptNumber': instance.manualReceiptNumber,
      'manualReceiptDate': instance.manualReceiptDate,
      'receiptDate': instance.receiptDate,
      'receiptType': instance.receiptType,
      'businessService': instance.businessService,
      'billId': instance.billId,
      'bill': instance.bill,
      'auditDetails': instance.auditDetails,
    };
