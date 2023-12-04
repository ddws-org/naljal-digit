// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_demand_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateDemandList _$UpdateDemandListFromJson(Map<String, dynamic> json) {
  return UpdateDemandList()
    ..demands = (json['Demands'] as List<dynamic>?)
        ?.map((e) => UpdateDemands.fromJson(e as Map<String, dynamic>))
        .toList()
    ..totalApplicablePenalty =
    (json['totalApplicablePenalty'] as num?)?.toDouble();
}

Map<String, dynamic> _$UpdateDemandListToJson(UpdateDemandList instance) =>
    <String, dynamic>{
      'Demands': instance.demands,
    };

UpdateDemands _$UpdateDemandsFromJson(Map<String, dynamic> json) {
  return UpdateDemands()
    ..id = json['id'] as String?
    ..tenantId = json['tenantId'] as String?
    ..consumerCode = json['consumerCode'] as String?
    ..consumerType = json['consumerType'] as String?
    ..businessService = json['businessService'] as String?
    ..payer = json['payer'] == null
        ? null
        : UpdatePayer.fromJson(json['payer'] as Map<String, dynamic>)
    ..taxPeriodFrom = json['taxPeriodFrom'] as int?
    ..taxPeriodTo = json['taxPeriodTo'] as int?
    ..demandDetails = (json['demandDetails'] as List<dynamic>?)
        ?.map((e) => UpdateDemandDetails.fromJson(e as Map<String, dynamic>))
        .toList()
    ..auditDetails = json['auditDetails'] == null
        ? null
        : UpdateAuditDetails.fromJson(
            json['auditDetails'] as Map<String, dynamic>)
    ..billExpiryTime = json['billExpiryTime'] as int?
    ..minimumAmountPayable = (json['minimumAmountPayable'] as num?)?.toDouble()
    ..status = json['status'] as String?
    ..isPaymentCompleted = json['isPaymentCompleted'] as bool?;
}

Map<String, dynamic> _$UpdateDemandsToJson(UpdateDemands instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'consumerCode': instance.consumerCode,
      'consumerType': instance.consumerType,
      'businessService': instance.businessService,
      'payer': instance.payer?.toJson(),
      'taxPeriodFrom': instance.taxPeriodFrom,
      'taxPeriodTo': instance.taxPeriodTo,
      'demandDetails': instance.demandDetails?.map((e) => e.toJson()).toList(),
      'auditDetails': instance.auditDetails?.toJson(),
      'billExpiryTime': instance.billExpiryTime,
      'minimumAmountPayable': instance.minimumAmountPayable,
      'status': instance.status,
    };

UpdatePayer _$UpdatePayerFromJson(Map<String, dynamic> json) {
  return UpdatePayer()
    ..uuid = json['uuid'] as String?
    ..id = json['id'] as int?
    ..userName = json['userName'] as String?
    ..type = json['type'] as String?
    ..salutation = json['salutation'] as String?
    ..name = json['name'] as String?
    ..gender = json['gender'] as String?
    ..mobileNumber = json['mobileNumber'] as String?
    ..emailId = json['emailId'] as String?
    ..altContactNumber = json['altContactNumber'] as String?
    ..pan = json['pan'] as String?
    ..aadhaarNumber = json['aadhaarNumber'] as String?
    ..permanentAddress = json['permanentAddress'] as String?
    ..permanentCity = json['permanentCity'] as String?
    ..permanentPinCode = json['permanentPinCode'] as String?
    ..correspondenceAddress = json['correspondenceAddress'] as String?
    ..correspondenceCity = json['correspondenceCity'] as String?
    ..correspondencePinCode = json['correspondencePinCode'] as String?
    ..active = json['active'] as bool?
    ..tenantId = json['tenantId'] as String?;
}

Map<String, dynamic> _$UpdatePayerToJson(UpdatePayer instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'id': instance.id,
      'userName': instance.userName,
      'type': instance.type,
      'salutation': instance.salutation,
      'name': instance.name,
      'gender': instance.gender,
      'mobileNumber': instance.mobileNumber,
      'emailId': instance.emailId,
      'altContactNumber': instance.altContactNumber,
      'pan': instance.pan,
      'aadhaarNumber': instance.aadhaarNumber,
      'permanentAddress': instance.permanentAddress,
      'permanentCity': instance.permanentCity,
      'permanentPinCode': instance.permanentPinCode,
      'correspondenceAddress': instance.correspondenceAddress,
      'correspondenceCity': instance.correspondenceCity,
      'correspondencePinCode': instance.correspondencePinCode,
      'active': instance.active,
      'tenantId': instance.tenantId,
    };

UpdateDemandDetails _$UpdateDemandDetailsFromJson(Map<String, dynamic> json) {
  return UpdateDemandDetails()
    ..id = json['id'] as String?
    ..demandId = json['demandId'] as String?
    ..taxHeadMasterCode = json['taxHeadMasterCode'] as String?
    ..taxAmount = (json['taxAmount'] as num?)?.toDouble()
    ..collectionAmount = (json['collectionAmount'] as num?)?.toDouble()
    ..auditDetails = json['auditDetails'] == null
        ? null
        : UpdateAuditDetails.fromJson(
            json['auditDetails'] as Map<String, dynamic>)
    ..tenantId = json['tenantId'] as String?;
}

Map<String, dynamic> _$UpdateDemandDetailsToJson(
        UpdateDemandDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'demandId': instance.demandId,
      'taxHeadMasterCode': instance.taxHeadMasterCode,
      'taxAmount': instance.taxAmount,
      'collectionAmount': instance.collectionAmount,
      'auditDetails': instance.auditDetails,
      'tenantId': instance.tenantId,
    };

UpdateAuditDetails _$UpdateAuditDetailsFromJson(Map<String, dynamic> json) {
  return UpdateAuditDetails()
    ..createdBy = json['createdBy'] as String?
    ..lastModifiedBy = json['lastModifiedBy'] as String?
    ..createdTime = json['createdTime'] as int?
    ..lastModifiedTime = json['lastModifiedTime'] as int?;
}

Map<String, dynamic> _$UpdateAuditDetailsToJson(UpdateAuditDetails instance) =>
    <String, dynamic>{
      'createdBy': instance.createdBy,
      'lastModifiedBy': instance.lastModifiedBy,
      'createdTime': instance.createdTime,
      'lastModifiedTime': instance.lastModifiedTime,
    };
