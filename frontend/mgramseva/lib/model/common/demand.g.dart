// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demand.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Demand _$DemandFromJson(Map<String, dynamic> json) {
  return Demand()
    ..id = json['id'] as String?
    ..tenantId = json['tenantId'] as String?
    ..consumerCode = json['consumerCode'] as String?
    ..consumerType = json['consumerType'] as String?
    ..businessService = json['businessService'] as String?
    ..payer = json['payer'] == null
        ? null
        : Payer.fromJson(json['payer'] as Map<String, dynamic>)
    ..taxPeriodFrom = json['taxPeriodFrom'] as int?
    ..taxPeriodTo = json['taxPeriodTo'] as int?
    ..demandDetails = (json['demandDetails'] as List<dynamic>?)
        ?.map((e) => DemandDetails.fromJson(e as Map<String, dynamic>))
        .toList()
    ..billExpiryTime = json['billExpiryTime'] as int?
    ..status = json['status'] as String?
    ..isPaymentCompleted = json['isPaymentCompleted'] as bool?
    ..minimumAmountPayable = (json['minimumAmountPayable'] as num?)?.toDouble();
}

Map<String, dynamic> _$DemandToJson(Demand instance) => <String, dynamic>{
      'id': instance.id,
      'tenantId': instance.tenantId,
      'consumerCode': instance.consumerCode,
      'consumerType': instance.consumerType,
      'businessService': instance.businessService,
      'payer': instance.payer,
      'taxPeriodFrom': instance.taxPeriodFrom,
      'taxPeriodTo': instance.taxPeriodTo,
      'demandDetails': instance.demandDetails,
      'billExpiryTime': instance.billExpiryTime,
      'status': instance.status,
      'minimumAmountPayable': instance.minimumAmountPayable,
    };

Payer _$PayerFromJson(Map<String, dynamic> json) {
  return Payer()
    ..uuid = json['uuid'] as String?
    ..id = json['id'] as int?
    ..userName = json['userName'] as String?
    ..type = json['type'] as String?
    ..name = json['name'] as String?
    ..gender = json['gender'] as String?
    ..mobileNumber = json['mobileNumber'] as String?
    ..tenantId = json['tenantId'] as String?
    ..active = json['active'] as bool?;
}

Map<String, dynamic> _$PayerToJson(Payer instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'id': instance.id,
      'userName': instance.userName,
      'type': instance.type,
      'name': instance.name,
      'gender': instance.gender,
      'mobileNumber': instance.mobileNumber,
      'tenantId': instance.tenantId,
      'active': instance.active,
    };

DemandDetails _$DemandDetailsFromJson(Map<String, dynamic> json) {
  return DemandDetails()
    ..id = json['id'] as String?
    ..demandId = json['demandId'] as String?
    ..taxHeadMasterCode = json['taxHeadMasterCode'] as String
    ..taxAmount = (json['taxAmount'] as num).toDouble()
    ..collectionAmount = (json['collectionAmount'] as num?)?.toDouble()
    ..tenantId = json['tenantId'] as String?;
}

Map<String, dynamic> _$DemandDetailsToJson(DemandDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'demandId': instance.demandId,
      'taxHeadMasterCode': instance.taxHeadMasterCode,
      'taxAmount': instance.taxAmount,
      'collectionAmount': instance.collectionAmount,
      'tenantId': instance.tenantId,
    };
