// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordOTP _$ForgotPasswordOTPFromJson(Map<String, dynamic> json) {
  return ForgotPasswordOTP()
    ..mobileNumber = json['mobileNumber'] as String?
    ..tenantId = json['tenantId'] as String?
    ..type = json['type'] as String?
    ..userType = json['userType'] as String?;
}

Map<String, dynamic> _$ForgotPasswordOTPToJson(ForgotPasswordOTP instance) =>
    <String, dynamic>{
      'mobileNumber': instance.mobileNumber,
      'tenantId': instance.tenantId,
      'type': instance.type,
      'userType': instance.userType,
    };
