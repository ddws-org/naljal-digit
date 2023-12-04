import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'forgot_password.g.dart';

@JsonSerializable()
class ForgotPasswordOTP {
  @JsonKey(name: "mobileNumber")
  String? mobileNumber;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "type")
  String? type;
  @JsonKey(name: "userType")
  String? userType;
  @JsonKey(ignore: true)
  var mobileNumberCtrl = new TextEditingController();


  ForgotPasswordOTP();

  getText() {
    mobileNumber = mobileNumberCtrl.text;
  }

  factory ForgotPasswordOTP.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordOTPFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordOTPToJson(this);
}