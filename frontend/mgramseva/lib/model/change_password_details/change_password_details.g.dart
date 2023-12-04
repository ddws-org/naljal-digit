// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordDetails _$ChangePasswordDetailsFromJson(
    Map<String, dynamic> json) {
  return ChangePasswordDetails()
    ..userName = json['userName'] as String?
    ..existingPassword = json['existingPassword'] as String?
    ..newPassword = json['newPassword'] as String?
    ..tenantId = json['tenantId'] as String?
    ..type = json['type'] as String?;
}

Map<String, dynamic> _$ChangePasswordDetailsToJson(
        ChangePasswordDetails instance) =>
    <String, dynamic>{
      'userName': instance.userName,
      'existingPassword': instance.existingPassword,
      'newPassword': instance.newPassword,
      'tenantId': instance.tenantId,
      'type': instance.type,
    };
