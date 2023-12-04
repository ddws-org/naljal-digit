import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  @JsonKey(name: "user")
  List<User>? user;
  UserProfile();
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: "id")
  int? id;

  @JsonKey(name: "userName")
  String? userName;

  @JsonKey(name: "salutation")
  String? salutation;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "gender")
  String? gender;

  @JsonKey(name: "mobileNumber")
  String? mobileNumber;

  @JsonKey(name: "emailId")
  String? emailId;

  @JsonKey(name: "altContactNumber")
  String? altContactNumber;

  @JsonKey(name: "pan")
  String? pan;

  @JsonKey(name: "aadhaarNumber")
  String? aadhaarNumber;

  @JsonKey(name: "permanentAddress")
  String? permanentAddress;

  @JsonKey(name: "permanentCity")
  String? permanentCity;

  @JsonKey(name: "permanentPinCode")
  String? permanentPinCode;

  @JsonKey(name: "correspondenceAddress")
  String? correspondenceAddress;

  @JsonKey(name: "correspondenceCity")
  String? correspondenceCity;

  @JsonKey(name: "correspondencePinCode")
  String? correspondencePinCode;

  @JsonKey(name: "active")
  bool? active;

  @JsonKey(name: "locale")
  String? locale;

  @JsonKey(name: "type")
  String? type;

  @JsonKey(name: "defaultPwdChgd")
  bool? defaultPwdChgd;

  @JsonKey(name: "accountLocked")
  bool? accountLocked;

  @JsonKey(name: "accountLockedDate")
  int? accountLockedDate;

  @JsonKey(name: "fatherOrHusbandName")
  String? fatherOrHusbandName;

  @JsonKey(name: "relationship")
  String? relationship;

  @JsonKey(name: "signature")
  String? signature;

  @JsonKey(name: "bloodGroup")
  String? bloodGroup;

  @JsonKey(name: "photo")
  String? photo;

  @JsonKey(name: "identificationMark")
  String? identificationMark;

  @JsonKey(name: "createdBy")
  int? createdBy;

  @JsonKey(name: "lastModifiedBy")
  int? lastModifiedBy;

  @JsonKey(name: "tenantId")
  String? tenantId;

  @JsonKey(name: "roles")
  List<Roles>? roles;

  @JsonKey(name: "uuid")
  String? uuid;

  @JsonKey(name: "createdDate")
  String? createdDate;

  @JsonKey(name: "lastModifiedDate")
  String? lastModifiedDate;

  @JsonKey(name: "dob", defaultValue: null)
  String? dob;

  @JsonKey(name: "pwdExpiryDate")
  String? pwdExpiryDate;

  @JsonKey(ignore: true)
  var nameCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var phoneNumberCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var emailIdCtrl = TextEditingController();

  User();

  getText() {
    name = nameCtrl.text;
    mobileNumber = phoneNumberCtrl.text;
    emailId = emailIdCtrl.text;
    dob = null;
  }

  setText() {
    nameCtrl.text = name ?? '';
    phoneNumberCtrl.text = mobileNumber ?? '';
    emailIdCtrl.text = emailId ?? '';
    gender = gender ?? '';
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Roles {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "tenantId")
  String? tenantId;
  Roles();

  factory Roles.fromJson(Map<String, dynamic> json) => _$RolesFromJson(json);

  Map<String, dynamic> toJson() => _$RolesToJson(this);
}
