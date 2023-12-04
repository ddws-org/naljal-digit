import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';


part 'change_password_details.g.dart';

@JsonSerializable()
class ChangePasswordDetails {
  @JsonKey(name: "userName")
  String? userName;
  @JsonKey(name: "existingPassword")
  String? existingPassword;
  @JsonKey(name: "newPassword")
  String? newPassword;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "type")
  String? type;
  @JsonKey(ignore: true)
  var currentpasswordCtrl = new TextEditingController();
  @JsonKey(ignore: true)
  var newpasswordCtrl = new TextEditingController();
  @JsonKey(ignore: true)
  var confirmpasswordCtrl = new TextEditingController();

  ChangePasswordDetails();

  getText(){
    existingPassword = currentpasswordCtrl.text;
    newPassword = newpasswordCtrl.text;
  }

  factory ChangePasswordDetails.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordDetailsToJson(this);

}