// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) {
  return Vendor(
    json['name'] as String,
    json['id'] as String,
      Owner.fromJson(json['owner'] as Map<String, dynamic>)
  );
}

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
    };


Owner _$OwnerFromJson(Map<String, dynamic> json) {
  return Owner(
    json['mobileNumber'] as String,
  );
}