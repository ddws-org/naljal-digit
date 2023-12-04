// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expenses_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpensesDetailsWithPagination _$ExpensesDetailsWithPaginationFromJson(
    Map<String, dynamic> json) {
  return ExpensesDetailsWithPagination()
    ..totalCount = json['totalCount'] as int?
    ..billDataCount = json['billData'] == null
        ? null
        : BillDataCount.fromJson(json['billData'] as Map<String, dynamic>)
    ..expenseDetailList = (json['challans'] as List<dynamic>?)
        ?.map((e) => ExpensesDetailsModel.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$ExpensesDetailsWithPaginationToJson(
        ExpensesDetailsWithPagination instance) =>
    <String, dynamic>{
      'totalCount': instance.totalCount,
      'challans': instance.expenseDetailList,
    };

ExpensesDetailsModel _$ExpensesDetailsModelFromJson(Map<String, dynamic> json) {
  return ExpensesDetailsModel()
    ..citizen = json['citizen'] == null
        ? null
        : Citizen.fromJson(json['citizen'] as Map<String, dynamic>)
    ..auditDetails = json['auditDetails'] == null
        ? null
        : AuditDetails.fromJson(json['auditDetails'] as Map<String, dynamic>)
    ..id = json['id'] as String?
    ..tenantId = json['tenantId'] as String?
    ..businessService = json['businessService'] as String?
    ..consumerType = json['consumerType'] as String?
    ..expenseType = json['typeOfExpense'] as String?
    ..vendorId = json['vendor'] as String?
    ..vendorName = json['vendorName'] as String?
    ..expensesAmount = (json['amount'] as List<dynamic>?)
        ?.map((e) => ExpensesAmount.fromJson(e as Map<String, dynamic>))
        .toList()
    ..billDate = json['billDate'] as int?
    ..paidDate = json['paidDate'] as int?
    ..billIssuedDate = json['billIssuedDate'] as int?
    ..challanNo = json['challanNo'] as String?
    ..accountId = json['accountId'] as String?
    ..applicationStatus = json['applicationStatus'] as String?
    ..totalAmount = (json['totalAmount'] as num?)?.toDouble()
    ..isBillPaid = json['isBillPaid'] as bool? ?? false
    ..fileStoreId = json['filestoreid'] as String?
    ..taxPeriodFrom = json['taxPeriodFrom'] as int?
    ..taxPeriodTo = json['taxPeriodTo'] as int?;
}

Map<String, dynamic> _$ExpensesDetailsModelToJson(
        ExpensesDetailsModel instance) =>
    <String, dynamic>{
      'citizen': instance.citizen,
      'auditDetails': instance.auditDetails,
      'id': instance.id,
      'tenantId': instance.tenantId,
      'businessService': instance.businessService,
      'consumerType': instance.consumerType,
      'typeOfExpense': instance.expenseType,
      'vendor': instance.vendorId,
      'vendorName': instance.vendorName,
      'amount': instance.expensesAmount,
      'billDate': instance.billDate,
      'paidDate': instance.paidDate,
      'billIssuedDate': instance.billIssuedDate,
      'challanNo': instance.challanNo,
      'accountId': instance.accountId,
      'applicationStatus': instance.applicationStatus,
      'totalAmount': instance.totalAmount,
      'isBillPaid': instance.isBillPaid,
      'filestoreid': instance.fileStoreId,
      'taxPeriodFrom': instance.taxPeriodFrom,
      'taxPeriodTo': instance.taxPeriodTo,
    };

ExpensesAmount _$ExpensesAmountFromJson(Map<String, dynamic> json) {
  return ExpensesAmount()
    ..taxHeadCode = json['taxHeadCode'] as String?
    ..amount = json['amount'] as String?;
}

Map<String, dynamic> _$ExpensesAmountToJson(ExpensesAmount instance) =>
    <String, dynamic>{
      'taxHeadCode': instance.taxHeadCode,
      'amount': instance.amount,
    };

Citizen _$CitizenFromJson(Map<String, dynamic> json) {
  return Citizen()
    ..id = json['id'] as int?
    ..uuid = json['uuid'] as String?
    ..userName = json['userName'] as String?
    ..name = json['name'] as String?
    ..mobileNumber = json['mobileNumber'] as String?;
}

Map<String, dynamic> _$CitizenToJson(Citizen instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'userName': instance.userName,
      'name': instance.name,
      'mobileNumber': instance.mobileNumber,
    };

AuditDetails _$AuditDetailsFromJson(Map<String, dynamic> json) {
  return AuditDetails()
    ..createdBy = json['createdBy'] as String?
    ..lastModifiedBy = json['lastModifiedBy'] as String?
    ..createdTime = json['createdTime'] as int?
    ..lastModifiedTime = json['lastModifiedTime'] as int?;
}

Map<String, dynamic> _$AuditDetailsToJson(AuditDetails instance) =>
    <String, dynamic>{
      'createdBy': instance.createdBy,
      'lastModifiedBy': instance.lastModifiedBy,
      'createdTime': instance.createdTime,
      'lastModifiedTime': instance.lastModifiedTime,
    };

BillDataCount _$BillDataCountFromJson(Map<String, dynamic> json) {
  return BillDataCount()
    ..notPaidCount = json['notPaidcount'] as String?
    ..paidCount = json['paidcount'] as String?;
}