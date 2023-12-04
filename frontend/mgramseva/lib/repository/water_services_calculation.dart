import 'package:json_annotation/json_annotation.dart';

import '../model/mdms/wc_billing_slab.dart';

part 'water_services_calculation.g.dart';

@JsonSerializable()
class WCBillingSlabs {
  @JsonKey(name: "WCBillingSlab")
  List<WCBillingSlab>? wCBillingSlabs;

  WCBillingSlabs();

  factory WCBillingSlabs.fromJson(Map<String, dynamic> json) =>
      _$WCBillingSlabsFromJson(json);

  Map<String, dynamic> toJson() => _$WCBillingSlabsToJson(this);
}
