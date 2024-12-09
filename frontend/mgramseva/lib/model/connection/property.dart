import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/user/user_details.dart';

part 'property.g.dart';

@JsonSerializable()
class Property {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "propertyId")
  String? propertyId;
  @JsonKey(name: "status")
  String? status;

  @JsonKey(name: "workflow")
  String? workflow;

  @JsonKey(name: "acknowldgementNumber")
  String? acknowldgementNumber;
  @JsonKey(name: "accountId")
  String? accountId;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "address")
  Address address = Address();
  @JsonKey(name: "ownershipCategory")
  String? ownershipCategory;
  @JsonKey(name: "owners")
  List<Owners>? owners;
  @JsonKey(name: "institution")
  Institution? institution;
  @JsonKey(name: "documents")
  List<Documents>? documents;
  @JsonKey(name: "units")
  List<Units>? units;
  @JsonKey(name: "landArea")
  double? landArea;
  @JsonKey(name: "propertyType")
  String? propertyType;
  @JsonKey(name: "noOfFloors")
  int? noOfFloors;
  @JsonKey(name: "superBuiltUpArea")
  String? superBuiltUpArea;
  @JsonKey(name: "usageCategory")
  String? usageCategory;
  @JsonKey(name: "additionalDetails")
  AdditionalDetails? additionalDetails;
  @JsonKey(name: "creationReason")
  String? creationReason;
  @JsonKey(name: "source")
  String? source;
  @JsonKey(name: "channel")
  String? channel;

  onChangeOflocaity() {}
  Property();
  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyToJson(this);
}

@JsonSerializable()
class Address {
  @JsonKey(name: "city")
  String? city;
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "locality")
  Locality? locality;
  @JsonKey(name: "street")
  String? street;
  @JsonKey(name: "geoLocation")
  GeoLocation? geoLocation;
  @JsonKey(name: "doorNo")
  String? doorNo;
  @JsonKey(name: "landmark")
  String? landmark;
  @JsonKey(name: "documents")
  List<Documents>? documents;

  @JsonKey(ignore: true)
  var doorNumberCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var streetNameOrNumberCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var gpNameCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var gpNameCityCodeCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var propertyCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var localityCtrl;

  Address();

  setText() {
    doorNo = doorNumberCtrl.text;
    street = streetNameOrNumberCtrl.text;
  }

  getText() {
    doorNumberCtrl.text = doorNo ?? '';
    streetNameOrNumberCtrl.text = street ?? '';
  }

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}

@JsonSerializable()
class Locality {
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "area")
  String? area;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "label")
  String? label;

  Locality();
  factory Locality.fromJson(Map<String, dynamic> json) =>
      _$LocalityFromJson(json);
  Map<String, dynamic> toJson() => _$LocalityToJson(this);
}

@JsonSerializable()
class Owners {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "uuid")
  String? uuid;
  @JsonKey(name: "userName")
  String? userName;
  @JsonKey(name: "password")
  String? password;
  @JsonKey(name: "aadhaarNumber")
  String? aadhaarNumber;
  @JsonKey(name: "permanentAddress")
  String? permanentAddress;
  @JsonKey(name: "permanentCity")
  String? permanentCity;
  @JsonKey(name: "permanentPinCode")
  String? permanentPinCode;
  @JsonKey(name: "correspondenceCity")
  String? correspondenceCity;
  @JsonKey(name: "correspondencePinCode")
  String? correspondencePinCode;
  @JsonKey(name: "correspondenceAddress")
  String? correspondenceAddress;
  @JsonKey(name: "pwdExpiryDate")
  int? pwdExpiryDate;
  @JsonKey(name: "accountLocked")
  bool? accountLocked;
  @JsonKey(name: "active")
  bool? active;
  @JsonKey(name: "type")
  String? type;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "altContactNumber")
  String? altContactNumber;
  @JsonKey(name: "ownerInfoUuid")
  String? ownerInfoUuid;
  @JsonKey(name: "isPrimaryOwner")
  String? isPrimaryOwner;
  @JsonKey(name: "ownerShipPercentage")
  String? ownerShipPercentage;
  @JsonKey(name: "institutionId")
  String? institutionId;
  @JsonKey(name: "designation")
  String? designation;
  @JsonKey(name: "emailId")
  String? emailId;
  @JsonKey(name: "isCorrespondenceAddress")
  bool? isCorrespondenceAddress;
  @JsonKey(name: "mobileNumber")
  String? mobileNumber;
  @JsonKey(name: "fatherOrHusbandName")
  String? fatherOrHusbandName;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "remarks")
  String? remarks;
  @JsonKey(name: "status")
  String? status;
  @JsonKey(name: "gender")
  String? gender;

  @JsonKey(name: "ownerType")
  String? ownerType;
  @JsonKey(name: "documents")
  List<Documents>? documents;

  @JsonKey(name: "roles")
  List<Roles>? roles;

  @JsonKey(ignore: true)
  var consumerNameCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var consumerRemarksCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var fatherOrSpouseCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var phoneNumberCtrl = TextEditingController();

  Owners();

  setText() {
    name = consumerNameCtrl.text.trim();
    remarks = consumerRemarksCtrl.text.trim();
    mobileNumber = phoneNumberCtrl.text;
    fatherOrHusbandName = fatherOrSpouseCtrl.text.trim();
  }

  getText() {
    consumerNameCtrl.text = name ?? '';
    phoneNumberCtrl.text = mobileNumber ?? '';
    fatherOrSpouseCtrl.text = fatherOrHusbandName ?? '';
    consumerRemarksCtrl.text = remarks ?? '';
  }

  factory Owners.fromJson(Map<String, dynamic> json) => _$OwnersFromJson(json);
  Map<String, dynamic> toJson() => _$OwnersToJson(this);
}

@JsonSerializable()
class Documents {
  @JsonKey(name: "fileStoreId")
  String? fileStoreId;
  @JsonKey(name: "documentType")
  String? documentType;

  Documents();
  factory Documents.fromJson(Map<String, dynamic> json) =>
      _$DocumentsFromJson(json);
}

@JsonSerializable()
class Institution {
  @JsonKey(name: "designation")
  String? designation;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "nameOfAuthorizedPerson")
  String? nameOfAuthorizedPerson;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "type")
  String? type;
  Institution();
  factory Institution.fromJson(Map<String, dynamic> json) =>
      _$InstitutionFromJson(json);
}

@JsonSerializable()
class GeoLocation {
  @JsonKey(name: "latitude")
  double? latitude;
  @JsonKey(name: "longitude")
  double? longitude;

  GeoLocation();
  factory GeoLocation.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationFromJson(json);
  Map<String, dynamic> toJson() => _$GeoLocationToJson(this);
}

@JsonSerializable()
class Units {
  @JsonKey(name: "occupancyType")
  String? occupancyType;
  @JsonKey(name: "floorNo")
  int? floorNo;
  @JsonKey(name: "constructionDetail")
  ConstructionDetail? constructionDetail;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "usageCategory")
  String? usageCategory;

  Units();
  factory Units.fromJson(Map<String, dynamic> json) => _$UnitsFromJson(json);
}

@JsonSerializable()
class AdditionalDetails {
  @JsonKey(name: "inflammable")
  bool? inflammable;
  @JsonKey(name: "heightAbove36Feet")
  bool? heightAbove36Feet;
  @JsonKey(name: "isResdential")
  IsResdential? isResdential;
  @JsonKey(name: "propertyType")
  IsResdential? propertyType;
  @JsonKey(name: "subusagetypeofrentedarea")
  String? subusagetypeofrentedarea;
  @JsonKey(name: "subusagetype")
  String? subusagetype;
  @JsonKey(name: "isAnyPartOfThisFloorUnOccupied")
  String? isAnyPartOfThisFloorUnOccupied;
  @JsonKey(name: "builtUpArea")
  String? builtUpArea;
  @JsonKey(name: "noOfFloors")
  NoOfFloors? noOfFloors;
  @JsonKey(name: "noOofBasements")
  NoOofBasements? noOofBasements;
  @JsonKey(name: "unit")
  List<Unit>? unit;
  @JsonKey(name: "basement1")
  String? basement1;
  @JsonKey(name: "basement2")
  String? basement2;
  AdditionalDetails();
  factory AdditionalDetails.fromJson(Map<String, dynamic> json) =>
      _$AdditionalDetailsFromJson(json);
}

@JsonSerializable()
class IsResdential {
  @JsonKey(name: "i18nKey")
  String? i18nKey;
  @JsonKey(name: "code")
  String? code;
  IsResdential();
  factory IsResdential.fromJson(Map<String, dynamic> json) =>
      _$IsResdentialFromJson(json);
}

@JsonSerializable()
class NoOfFloors {
  @JsonKey(name: "i18nKey")
  String? i18nKey;
  @JsonKey(name: "code")
  int? code;
  NoOfFloors();
  factory NoOfFloors.fromJson(Map<String, dynamic> json) =>
      _$NoOfFloorsFromJson(json);
}

@JsonSerializable()
class NoOofBasements {
  @JsonKey(name: "i18nKey")
  String? i18nKey;
  @JsonKey(name: "code")
  int? code;
  NoOofBasements();
  factory NoOofBasements.fromJson(Map<String, dynamic> json) =>
      _$NoOofBasementsFromJson(json);
}

@JsonSerializable()
class Unit {
  @JsonKey(name: "plotSize")
  String? plotSize;
  @JsonKey(name: "builtUpArea")
  String? builtUpArea;
  @JsonKey(name: "selfOccupied")
  IsResdential? selfOccupied;
  @JsonKey(name: "isAnyPartOfThisFloorUnOccupied")
  IsResdential? isAnyPartOfThisFloorUnOccupied;
  @JsonKey(name: "constructionDetail")
  ConstructionDetail? constructionDetail;

  Unit();
  factory Unit.fromJson(Map<String, dynamic> json) => _$UnitFromJson(json);
}

@JsonSerializable()
class ConstructionDetail {
  @JsonKey(name: "constructionType")
  String? constructionType;

  @JsonKey(name: "builtUpArea")
  String? builtUpArea;

  ConstructionDetail();
  factory ConstructionDetail.fromJson(Map<String, dynamic> json) =>
      _$ConstructionDetailFromJson(json);
}
