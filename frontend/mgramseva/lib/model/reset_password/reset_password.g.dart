// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_password.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResetPasswordDetails _$ResetPasswordDetailsFromJson(Map<String, dynamic> json) {
  return ResetPasswordDetails()
    ..otpReference = json['otpReference'] as String?
    ..userName = json['userName'] as String?
    ..newPassword = json['newPassword'] as String?
    ..tenantId = json['tenantId'] as String?
    ..type = json['type'] as String?;
}

Map<String, dynamic> _$ResetPasswordDetailsToJson(
        ResetPasswordDetails instance) =>
    <String, dynamic>{
      'otpReference': instance.otpReference,
      'userName': instance.userName,
      'newPassword': instance.newPassword,
      'tenantId': instance.tenantId,
      'type': instance.type,
    };
