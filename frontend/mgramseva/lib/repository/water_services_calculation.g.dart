// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'water_services_calculation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WCBillingSlabs _$WCBillingSlabsFromJson(Map<String, dynamic> json) =>
    WCBillingSlabs()
      ..wCBillingSlabs = (json['WCBillingSlab'] as List<dynamic>?)
          ?.map((e) => WCBillingSlab.fromJson(e as Map<String, dynamic>))
          .toList();

Map<String, dynamic> _$WCBillingSlabsToJson(WCBillingSlabs instance) =>
    <String, dynamic>{
      'WCBillingSlab': instance.wCBillingSlabs,
    };
