import 'package:json_annotation/json_annotation.dart';

part 'wc_billing_slab.g.dart';

@JsonSerializable()
class WCBillingSlab {
  @JsonKey(name: "buildingType")
  String? buildingType;

  @JsonKey(name: "connectionType")
  String? connectionType;

  @JsonKey(name: "calculationAttribute")
  String? calculationAttribute;

  @JsonKey(name: "minimumCharge")
  num? minimumCharge;

  @JsonKey(name: "slabs")
  List<Slabs>? slabs;

  WCBillingSlab();

  factory WCBillingSlab.fromJson(Map<String, dynamic> json) =>
      _$WCBillingSlabFromJson(json);

  Map<String, dynamic> toJson() => _$WCBillingSlabToJson(this);
}

@JsonSerializable()
class Slabs {
  @JsonKey(name: "from")
  int? from;

  @JsonKey(name: "to")
  int? to;

  @JsonKey(name: "charge")
  num? charge;

  @JsonKey(name: "meterCharge")
  num? meterCharge;

  Slabs();

  factory Slabs.fromJson(Map<String, dynamic> json) => _$SlabsFromJson(json);

  Map<String, dynamic> toJson() => _$SlabsToJson(this);
}
