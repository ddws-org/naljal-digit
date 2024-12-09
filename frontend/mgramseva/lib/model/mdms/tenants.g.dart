// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenants.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Tenant _$TenantFromJson(Map<String, dynamic> json) {
  return Tenant()
    ..tenantsList = (json['tenants'] as List<dynamic>?)
        ?.map((e) => Tenants.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$TenantToJson(Tenant instance) => <String, dynamic>{
      'tenants': instance.tenantsList,
    };

Tenants _$TenantsFromJson(Map<String, dynamic> json) {
  return Tenants()
    ..code = json['code'] as String?
    ..name = json['name'] as String?
    ..description = json['description'] as String?
    ..logoId = json['logoId'] as String?
    ..imageId = json['imageId'] as String?
    ..domainUrl = json['domainUrl'] as String?
    ..type = json['type'] as String?
    ..twitterUrl = json['twitterUrl'] as String?
    ..facebookUrl = json['facebookUrl'] as String?
    ..emailId = json['emailId'] as String?
    ..officeTimings = json['officeTimings'] == null
        ? null
        : OfficeTimings.fromJson(json['officeTimings'] as Map<String, dynamic>)
    ..city = json['city'] == null
        ? null
        : City.fromJson(json['city'] as Map<String, dynamic>)
    ..address = json['address'] as String?
    ..pincode =
        (json['pincode'] as List<dynamic>?)?.map((e) => e as int).toList()
    ..contactNumber = json['contactNumber'] as String?
    ..pdfHeader = json['pdfHeader'] as String?
    ..pdfContactDetails = json['pdfContactDetails'] as String?
    ..helpLineNumber = json['helpLineNumber'] as String?;
}

Map<String, dynamic> _$TenantsToJson(Tenants instance) => <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'logoId': instance.logoId,
      'imageId': instance.imageId,
      'domainUrl': instance.domainUrl,
      'type': instance.type,
      'twitterUrl': instance.twitterUrl,
      'facebookUrl': instance.facebookUrl,
      'emailId': instance.emailId,
      'officeTimings': instance.officeTimings,
      'city': instance.city,
      'address': instance.address,
      'pincode': instance.pincode,
      'contactNumber': instance.contactNumber,
      'pdfHeader': instance.pdfHeader,
      'pdfContactDetails': instance.pdfContactDetails,
      'helpLineNumber': instance.helpLineNumber,
    };

OfficeTimings _$OfficeTimingsFromJson(Map<String, dynamic> json) {
  return OfficeTimings()
    ..monFri = json['monFri'] as String?
    ..sat = json['sat'] as String?;
}

Map<String, dynamic> _$OfficeTimingsToJson(OfficeTimings instance) =>
    <String, dynamic>{
      'monFri': instance.monFri,
      'sat': instance.sat,
    };

City _$CityFromJson(Map<String, dynamic> json) {
  return City()
    ..name = json['name'] as String?
    ..localName = json['localName'] as String?
    ..districtCode = json['districtCode'] as String?
    ..districtName = json['districtName'] as String?
    ..regionName = json['regionName'] as String?
    ..ulbGrade = json['ulbGrade'] as String?
    ..longitude = json['longitude']
    ..latitude = json['latitude']
    ..code = json['code'] as String?
    ..ddrName = json['ddrName'] as String?
    ..regionCode = json['cateregionCodegory'] as String?
    ..municipalityName = json['municipalityName'] as String?;
}

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
      'name': instance.name,
      'localName': instance.localName,
      'districtCode': instance.districtCode,
      'districtName': instance.districtName,
      'regionName': instance.regionName,
      'ulbGrade': instance.ulbGrade,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'code': instance.code,
      'ddrName': instance.ddrName,
      'cateregionCodegory': instance.regionCode,
      'municipalityName': instance.municipalityName,
    };
