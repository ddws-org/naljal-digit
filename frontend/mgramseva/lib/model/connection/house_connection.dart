import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'house_connection.g.dart';

@JsonSerializable()
class HouseConnection {
  @JsonKey(name: "consumerName")
  String? consumerName;

  @JsonKey(name: "gender")
  String? gender;

  @JsonKey(name: "fatherOrSpouse")
  String? fatherOrSpouse;

  @JsonKey(name: "phoneNumber")
  String? phoneNumber;

  @JsonKey(name: "oldConnectionId")
  String? oldConnectionId;

  @JsonKey(name: "doorNumber")
  String? doorNumber;

  @JsonKey(name: "streetNameOrNumber")
  String? streetNameOrNumber;

  @JsonKey(name: "ward")
  String? ward;

  @JsonKey(name: "gramaPanchayatName")
  String? gramaPanchayatName;

  @JsonKey(name: "propertyType")
  String? propertyType;

  @JsonKey(name: "serviceType")
  String? serviceType;

  @JsonKey(name: "arrears")
  double? arrears;

  @JsonKey(ignore: true)
  var consumerNameCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var fatherOrSpouseCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var phoneNumberCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var oldConnectionIdCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var doorNumberCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var streetNameOrNumberCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var arrearsCtrl = TextEditingController();

  HouseConnection();

  setText() {
    consumerNameCtrl.text = consumerName ?? '';
    fatherOrSpouseCtrl.text = fatherOrSpouse ?? '';
    phoneNumberCtrl.text = phoneNumber ?? '';
    oldConnectionIdCtrl.text = oldConnectionId ?? '';
    fatherOrSpouseCtrl.text = fatherOrSpouse ?? '';
    phoneNumberCtrl.text = phoneNumber ?? '';
    doorNumberCtrl.text = doorNumber ?? '';
    streetNameOrNumberCtrl.text = streetNameOrNumber ?? '';
    arrearsCtrl.text = arrears?.toString() ?? '';
  }

  getText() {
    consumerName = consumerNameCtrl.text;
    fatherOrSpouse = fatherOrSpouseCtrl.text;
    phoneNumber = phoneNumberCtrl.text;
    oldConnectionId = oldConnectionIdCtrl.text;
    fatherOrSpouse = fatherOrSpouseCtrl.text;
    phoneNumber = phoneNumberCtrl.text;
    doorNumber = doorNumberCtrl.text;
    streetNameOrNumber = streetNameOrNumberCtrl.text;
    arrears = arrearsCtrl.text.trim().isNotEmpty
        ? double.parse(arrearsCtrl.text.trim())
        : 0.0;
  }

  factory HouseConnection.fromJson(Map<String, dynamic> json) =>
      _$HouseConnectionFromJson(json);
}
