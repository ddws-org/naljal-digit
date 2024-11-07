import 'package:json_annotation/json_annotation.dart';

part 'tenants.g.dart';

@JsonSerializable()
class Tenant {
  @JsonKey(name: "tenants")
  List<Tenants>? tenantsList;

  Tenant();

  factory Tenant.fromJson(Map<String, dynamic> json) => _$TenantFromJson(json);

  Map<String, dynamic> toJson() => _$TenantToJson(this);
}

@JsonSerializable()
class Tenants {
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "description")
  String? description;
  @JsonKey(name: "logoId")
  String? logoId;
  @JsonKey(name: "imageId")
  String? imageId;
  @JsonKey(name: "domainUrl")
  String? domainUrl;
  @JsonKey(name: "type")
  String? type;
  @JsonKey(name: "twitterUrl")
  String? twitterUrl;
  @JsonKey(name: "facebookUrl")
  String? facebookUrl;
  @JsonKey(name: "emailId")
  String? emailId;
  @JsonKey(name: "officeTimings")
  OfficeTimings? officeTimings;
  @JsonKey(name: "city")
  City? city;
  @JsonKey(name: "address")
  String? address;
  @JsonKey(name: "pincode")
  List<int>? pincode;
  @JsonKey(name: "contactNumber")
  String? contactNumber;
  @JsonKey(name: "pdfHeader")
  String? pdfHeader;
  @JsonKey(name: "pdfContactDetails")
  String? pdfContactDetails;
  @JsonKey(name: "helpLineNumber")
  String? helpLineNumber;

  Tenants();

  factory Tenants.fromJson(Map<String, dynamic> json) =>
      _$TenantsFromJson(json);

  @override
  String toString() {
    return '$code';
  }

  Map<String, dynamic> toJson() => _$TenantsToJson(this);
}

@JsonSerializable()
class OfficeTimings {
  @JsonKey(name: "monFri")
  String? monFri;
  @JsonKey(name: "sat")
  String? sat;
  OfficeTimings();
  factory OfficeTimings.fromJson(Map<String, dynamic> json) =>
      _$OfficeTimingsFromJson(json);

  Map<String, dynamic> toJson() => _$OfficeTimingsToJson(this);
}

@JsonSerializable()
class City {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "localName")
  String? localName;
  @JsonKey(name: "districtCode")
  String? districtCode;
  @JsonKey(name: "districtName")
  String? districtName;
  @JsonKey(name: "regionName")
  String? regionName;
  @JsonKey(name: "ulbGrade")
  String? ulbGrade;
  @JsonKey(name: "longitude")
  dynamic? longitude;
  @JsonKey(name: "latitude")
  dynamic? latitude;
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "ddrName")
  String? ddrName;
  @JsonKey(name: "cateregionCodegory")
  String? regionCode;
  @JsonKey(name: "municipalityName")
  String? municipalityName;

  City();
  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);

  Map<String, dynamic> toJson() => _$CityToJson(this);
}
