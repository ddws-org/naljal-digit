// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wc_billing_slab.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WCBillingSlab _$WCBillingSlabFromJson(Map<String, dynamic> json) =>
    WCBillingSlab()
      ..buildingType = json['buildingType'] as String?
      ..connectionType = json['connectionType'] as String?
      ..calculationAttribute = json['calculationAttribute'] as String?
      ..minimumCharge = json['minimumCharge'] as num?
      ..slabs = (json['slabs'] as List<dynamic>?)
          ?.map((e) => Slabs.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$WCBillingSlabToJson(WCBillingSlab instance) =>
    <String, dynamic>{
      'buildingType': instance.buildingType,
      'connectionType': instance.connectionType,
      'calculationAttribute': instance.calculationAttribute,
      'minimumCharge': instance.minimumCharge,
      'slabs': instance.slabs,
    };

Slabs _$SlabsFromJson(Map<String, dynamic> json) => Slabs()
  ..from = json['from'] as int?
  ..to = json['to'] as int?
  ..charge = json['charge'] as num?
  ..meterCharge = json['meterCharge'] as num?;

Map<String, dynamic> _$SlabsToJson(Slabs instance) => <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'charge': instance.charge,
      'meterCharge': instance.meterCharge,
    };
