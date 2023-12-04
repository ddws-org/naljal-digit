import 'package:json_annotation/json_annotation.dart';

part 'vendor.g.dart';

@JsonSerializable()
class Vendor {

  @JsonKey(name: "name")
  String name;

  @JsonKey(name: "id")
  String id;

  @JsonKey(name: "owner")
  Owner? owner;

  Vendor(this.name, this.id, [this.owner]);

  factory Vendor.fromJson(Map<String, dynamic> json) =>
      _$VendorFromJson(json);

  Map<String, dynamic> toJson() => _$VendorToJson(this);
}


@JsonSerializable()
class Owner {

  @JsonKey(name: "mobileNumber")
  String mobileNumber;

  Owner(this.mobileNumber);

  factory Owner.fromJson(Map<String, dynamic> json) =>
      _$OwnerFromJson(json);
}