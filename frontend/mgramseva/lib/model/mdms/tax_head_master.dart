
import 'package:json_annotation/json_annotation.dart';

part 'tax_head_master.g.dart';

@JsonSerializable()
class TaxHeadMaster {

  @JsonKey(name: "category")
  String? category;

  @JsonKey(name: "service")
  String? service;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "code")
  String? code;

  @JsonKey(name: "isDebit")
  bool? isDebit;

  @JsonKey(name: "isActualDemand")
  bool? isActualDemand;

  @JsonKey(name: "order")
  String? order;

  @JsonKey(name: "isRequired")
  bool? isRequired;

  TaxHeadMaster();

  factory TaxHeadMaster.fromJson(Map<String, dynamic> json) =>
      _$TaxHeadMasterFromJson(json);

  Map<String, dynamic> toJson() => _$TaxHeadMasterToJson(this);
}


