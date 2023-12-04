import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';

part 'reset_password.g.dart';

@JsonSerializable()
class ResetPasswordDetails {
  @JsonKey(name: "otpReference")
  String? otpReference;
  @JsonKey(name: "userName")
  String? userName;
  @JsonKey(name: "newPassword")
  String? newPassword;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "type")
  String? type;
  @JsonKey(ignore: true)
  var otpReferenceCtrl = new TextEditingController();


  ResetPasswordDetails();

  getText() {
    otpReference = otpReferenceCtrl.text;
  }

  factory ResetPasswordDetails.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordDetailsToJson(this);
}