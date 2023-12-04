// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'house_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HouseConnection _$HouseConnectionFromJson(Map<String, dynamic> json) {
  return HouseConnection()
    ..consumerName = json['consumerName'] as String?
    ..gender = json['gender'] as String?
    ..fatherOrSpouse = json['fatherOrSpouse'] as String?
    ..phoneNumber = json['phoneNumber'] as String?
    ..oldConnectionId = json['oldConnectionId'] as String?
    ..doorNumber = json['doorNumber'] as String?
    ..streetNameOrNumber = json['streetNameOrNumber'] as String?
    ..ward = json['ward'] as String?
    ..gramaPanchayatName = json['gramaPanchayatName'] as String?
    ..propertyType = json['propertyType'] as String?
    ..serviceType = json['serviceType'] as String?
    ..arrears = (json['arrears'] as num?)?.toDouble();
}

Map<String, dynamic> _$HouseConnectionToJson(HouseConnection instance) =>
    <String, dynamic>{
      'consumerName': instance.consumerName,
      'gender': instance.gender,
      'fatherOrSpouse': instance.fatherOrSpouse,
      'phoneNumber': instance.phoneNumber,
      'oldConnectionId': instance.oldConnectionId,
      'doorNumber': instance.doorNumber,
      'streetNameOrNumber': instance.streetNameOrNumber,
      'ward': instance.ward,
      'gramaPanchayatName': instance.gramaPanchayatName,
      'propertyType': instance.propertyType,
      'serviceType': instance.serviceType,
      'arrears': instance.arrears,
    };
