import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
part 'search_connection.g.dart';

@JsonSerializable()
class SearchConnection {
  @JsonKey(name: "oldConnectionNumber")
  String? oldConnectionNumber;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "connectionNumber")
  String? connectionNumber;

  @JsonKey(name: "mobileNumber")
  String? mobileNumber;

  @JsonKey(ignore: true)
  var mobileCtrl = new TextEditingController();

  @JsonKey(ignore: true)
  var nameCtrl = new TextEditingController();

  @JsonKey(ignore: true)
  var oldConnectionCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var newConnectionCtrl = TextEditingController();

  @JsonKey(ignore: true)
  static var ownername;
  @JsonKey(ignore: true)
  static var mobile;
  @JsonKey(ignore: true)
  static var oldConnectionId;
  @JsonKey(ignore: true)
  static var newConnectionId;

  @JsonKey(ignore: true)
  var controllers = [ownername, mobile, oldConnectionId, newConnectionId];

  getdetails(value, controller) {
    controllers.forEach((element) {
      element = true;
    });
    controllers[controller] = false;
  }

  setValues() {
    name = nameCtrl.text;
    connectionNumber = newConnectionCtrl.text;
    mobileNumber = mobileCtrl.text;
    oldConnectionNumber = oldConnectionCtrl.text;
  }

  SearchConnection();

  factory SearchConnection.fromJson(Map<String, dynamic> json) =>
      _$SearchConnectionFromJson(json);
  Map<String, dynamic> toJson() => _$SearchConnectionToJson(this);
}
