// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Property _$PropertyFromJson(Map<String, dynamic> json) {
  return Property()
    ..id = json['id'] as String?
    ..propertyId = json['propertyId'] as String?
    ..status = json['status'] as String?
    ..workflow = json['workflow'] as String?
    ..acknowldgementNumber = json['acknowldgementNumber'] as String?
    ..accountId = json['accountId'] as String?
    ..tenantId = json['tenantId'] as String?
    ..address = Address.fromJson(json['address'] as Map<String, dynamic>)
    ..ownershipCategory = json['ownershipCategory'] as String?
    ..owners = (json['owners'] as List<dynamic>?)
        ?.map((e) => Owners.fromJson(e as Map<String, dynamic>))
        .toList()
    ..institution = json['institution'] == null
        ? null
        : Institution.fromJson(json['institution'] as Map<String, dynamic>)
    ..documents = (json['documents'] as List<dynamic>?)
        ?.map((e) => Documents.fromJson(e as Map<String, dynamic>))
        .toList()
    ..units = (json['units'] as List<dynamic>?)
        ?.map((e) => Units.fromJson(e as Map<String, dynamic>))
        .toList()
    ..landArea = (json['landArea'] as num?)?.toDouble()
    ..propertyType = json['propertyType'] as String?
    ..noOfFloors = json['noOfFloors'] as int?
    ..superBuiltUpArea = json['superBuiltUpArea'] as String?
    ..usageCategory = json['usageCategory'] as String?
    ..additionalDetails = json['additionalDetails'] == null
        ? null
        : AdditionalDetails.fromJson(
            json['additionalDetails'] as Map<String, dynamic>)
    ..creationReason = json['creationReason'] as String?
    ..source = json['source'] as String?
    ..channel = json['channel'] as String?;
}

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
      'id': instance.id,
      'propertyId': instance.propertyId,
      'status': instance.status,
      'workflow': instance.workflow,
      'acknowldgementNumber': instance.acknowldgementNumber,
      'accountId': instance.accountId,
      'tenantId': instance.tenantId,
      'address': instance.address,
      'ownershipCategory': instance.ownershipCategory,
      'owners': instance.owners,
      'institution': instance.institution,
      'documents': instance.documents,
      'units': instance.units,
      'landArea': instance.landArea,
      'propertyType': instance.propertyType,
      'noOfFloors': instance.noOfFloors,
      'superBuiltUpArea': instance.superBuiltUpArea,
      'usageCategory': instance.usageCategory,
      'additionalDetails': instance.additionalDetails,
      'creationReason': instance.creationReason,
      'source': instance.source,
      'channel': instance.channel,
    };

Address _$AddressFromJson(Map<String, dynamic> json) {
  return Address()
    ..city = json['city'] as String?
    ..id = json['id'] as String?
    ..locality = json['locality'] == null
        ? null
        : Locality.fromJson(json['locality'] as Map<String, dynamic>)
    ..street = json['street'] as String?
    ..geoLocation = json['geoLocation'] == null
        ? null
        : GeoLocation.fromJson(json['geoLocation'] as Map<String, dynamic>)
    ..doorNo = json['doorNo'] as String?
    ..landmark = json['landmark'] as String?
    ..documents = (json['documents'] as List<dynamic>?)
        ?.map((e) => Documents.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'city': instance.city,
      'id': instance.id,
      'locality': instance.locality,
      'street': instance.street,
      'geoLocation': instance.geoLocation,
      'doorNo': instance.doorNo,
      'landmark': instance.landmark,
      'documents': instance.documents,
    };

Locality _$LocalityFromJson(Map<String, dynamic> json) {
  return Locality()
    ..code = json['code'] as String?
    ..area = json['area'] as String?
    ..name = json['name'] as String?
    ..label = json['label'] as String?;
}

Map<String, dynamic> _$LocalityToJson(Locality instance) => <String, dynamic>{
      'code': instance.code,
      'area': instance.area,
      'name': instance.name,
      'label': instance.label,
    };

Owners _$OwnersFromJson(Map<String, dynamic> json) {
  return Owners()
    ..id = json['id'] as int?
    ..uuid = json['uuid'] as String?
    ..userName = json['userName'] as String?
    ..password = json['password'] as String?
    ..aadhaarNumber = json['aadhaarNumber'] as String?
    ..permanentAddress = json['permanentAddress'] as String?
    ..permanentCity = json['permanentCity'] as String?
    ..permanentPinCode = json['permanentPinCode'] as String?
    ..correspondenceCity = json['correspondenceCity'] as String?
    ..correspondencePinCode = json['correspondencePinCode'] as String?
    ..correspondenceAddress = json['correspondenceAddress'] as String?
    ..pwdExpiryDate = json['pwdExpiryDate'] as int?
    ..accountLocked = json['accountLocked'] as bool?
    ..active = json['active'] as bool?
    ..type = json['type'] as String?
    ..tenantId = json['tenantId'] as String?
    ..altContactNumber = json['altContactNumber'] as String?
    ..ownerInfoUuid = json['ownerInfoUuid'] as String?
    ..isPrimaryOwner = json['isPrimaryOwner'] as String?
    ..ownerShipPercentage = json['ownerShipPercentage'] as String?
    ..institutionId = json['institutionId'] as String?
    ..designation = json['designation'] as String?
    ..emailId = json['emailId'] as String?
    ..isCorrespondenceAddress = json['isCorrespondenceAddress'] as bool?
    ..mobileNumber = json['mobileNumber'] as String?
    ..fatherOrHusbandName = json['fatherOrHusbandName'] as String?
    ..name = json['name'] as String?
    ..remarks = json['remarks'] as String?
    ..status = json['status'] as String?
    ..gender = json['gender'] as String?
    ..ownerType = json['ownerType'] as String?
    ..documents = (json['documents'] as List<dynamic>?)
        ?.map((e) => Documents.fromJson(e as Map<String, dynamic>))
        .toList()
    ..roles = (json['roles'] as List<dynamic>?)
        ?.map((e) => Roles.fromJson(e as Map<String, dynamic>))
        .toList();
}

Map<String, dynamic> _$OwnersToJson(Owners instance) => <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'userName': instance.userName,
      'password': instance.password,
      'aadhaarNumber': instance.aadhaarNumber,
      'permanentAddress': instance.permanentAddress,
      'permanentCity': instance.permanentCity,
      'permanentPinCode': instance.permanentPinCode,
      'correspondenceCity': instance.correspondenceCity,
      'correspondencePinCode': instance.correspondencePinCode,
      'correspondenceAddress': instance.correspondenceAddress,
      'pwdExpiryDate': instance.pwdExpiryDate,
      'accountLocked': instance.accountLocked,
      'active': instance.active,
      'type': instance.type,
      'tenantId': instance.tenantId,
      'altContactNumber': instance.altContactNumber,
      'ownerInfoUuid': instance.ownerInfoUuid,
      'isPrimaryOwner': instance.isPrimaryOwner,
      'ownerShipPercentage': instance.ownerShipPercentage,
      'institutionId': instance.institutionId,
      'designation': instance.designation,
      'emailId': instance.emailId,
      'isCorrespondenceAddress': instance.isCorrespondenceAddress,
      'mobileNumber': instance.mobileNumber,
      'fatherOrHusbandName': instance.fatherOrHusbandName,
      'name': instance.name,
      'remarks': instance.remarks,
      'status': instance.status,
      'gender': instance.gender,
      'ownerType': instance.ownerType,
      'documents': instance.documents,
      'roles': instance.roles,
    };

Documents _$DocumentsFromJson(Map<String, dynamic> json) {
  return Documents()
    ..fileStoreId = json['fileStoreId'] as String?
    ..documentType = json['documentType'] as String?;
}

Map<String, dynamic> _$DocumentsToJson(Documents instance) => <String, dynamic>{
      'fileStoreId': instance.fileStoreId,
      'documentType': instance.documentType,
    };

Institution _$InstitutionFromJson(Map<String, dynamic> json) {
  return Institution()
    ..designation = json['designation'] as String?
    ..name = json['name'] as String?
    ..nameOfAuthorizedPerson = json['nameOfAuthorizedPerson'] as String?
    ..tenantId = json['tenantId'] as String?
    ..type = json['type'] as String?;
}

Map<String, dynamic> _$InstitutionToJson(Institution instance) =>
    <String, dynamic>{
      'designation': instance.designation,
      'name': instance.name,
      'nameOfAuthorizedPerson': instance.nameOfAuthorizedPerson,
      'tenantId': instance.tenantId,
      'type': instance.type,
    };

GeoLocation _$GeoLocationFromJson(Map<String, dynamic> json) {
  return GeoLocation()
    ..latitude = (json['latitude'] as num?)?.toDouble()
    ..longitude = (json['longitude'] as num?)?.toDouble();
}

Map<String, dynamic> _$GeoLocationToJson(GeoLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

Units _$UnitsFromJson(Map<String, dynamic> json) {
  return Units()
    ..occupancyType = json['occupancyType'] as String?
    ..floorNo = json['floorNo'] as int?
    ..constructionDetail = json['constructionDetail'] == null
        ? null
        : ConstructionDetail.fromJson(
            json['constructionDetail'] as Map<String, dynamic>)
    ..tenantId = json['tenantId'] as String?
    ..usageCategory = json['usageCategory'] as String?;
}

Map<String, dynamic> _$UnitsToJson(Units instance) => <String, dynamic>{
      'occupancyType': instance.occupancyType,
      'floorNo': instance.floorNo,
      'constructionDetail': instance.constructionDetail,
      'tenantId': instance.tenantId,
      'usageCategory': instance.usageCategory,
    };

AdditionalDetails _$AdditionalDetailsFromJson(Map<String, dynamic> json) {
  return AdditionalDetails()
    ..inflammable = json['inflammable'] as bool?
    ..heightAbove36Feet = json['heightAbove36Feet'] as bool?
    ..isResdential = json['isResdential'] == null
        ? null
        : IsResdential.fromJson(json['isResdential'] as Map<String, dynamic>)
    ..propertyType = json['propertyType'] == null
        ? null
        : IsResdential.fromJson(json['propertyType'] as Map<String, dynamic>)
    ..subusagetypeofrentedarea = json['subusagetypeofrentedarea'] as String?
    ..subusagetype = json['subusagetype'] as String?
    ..isAnyPartOfThisFloorUnOccupied =
        json['isAnyPartOfThisFloorUnOccupied'] as String?
    ..builtUpArea = json['builtUpArea'] as String?
    ..noOfFloors = json['noOfFloors'] == null
        ? null
        : NoOfFloors.fromJson(json['noOfFloors'] as Map<String, dynamic>)
    ..noOofBasements = json['noOofBasements'] == null
        ? null
        : NoOofBasements.fromJson(
            json['noOofBasements'] as Map<String, dynamic>)
    ..unit = (json['unit'] as List<dynamic>?)
        ?.map((e) => Unit.fromJson(e as Map<String, dynamic>))
        .toList()
    ..basement1 = json['basement1'] as String?
    ..basement2 = json['basement2'] as String?;
}

Map<String, dynamic> _$AdditionalDetailsToJson(AdditionalDetails instance) =>
    <String, dynamic>{
      'inflammable': instance.inflammable,
      'heightAbove36Feet': instance.heightAbove36Feet,
      'isResdential': instance.isResdential,
      'propertyType': instance.propertyType,
      'subusagetypeofrentedarea': instance.subusagetypeofrentedarea,
      'subusagetype': instance.subusagetype,
      'isAnyPartOfThisFloorUnOccupied': instance.isAnyPartOfThisFloorUnOccupied,
      'builtUpArea': instance.builtUpArea,
      'noOfFloors': instance.noOfFloors,
      'noOofBasements': instance.noOofBasements,
      'unit': instance.unit,
      'basement1': instance.basement1,
      'basement2': instance.basement2,
    };

IsResdential _$IsResdentialFromJson(Map<String, dynamic> json) {
  return IsResdential()
    ..i18nKey = json['i18nKey'] as String?
    ..code = json['code'] as String?;
}

Map<String, dynamic> _$IsResdentialToJson(IsResdential instance) =>
    <String, dynamic>{
      'i18nKey': instance.i18nKey,
      'code': instance.code,
    };

NoOfFloors _$NoOfFloorsFromJson(Map<String, dynamic> json) {
  return NoOfFloors()
    ..i18nKey = json['i18nKey'] as String?
    ..code = json['code'] as int?;
}

Map<String, dynamic> _$NoOfFloorsToJson(NoOfFloors instance) =>
    <String, dynamic>{
      'i18nKey': instance.i18nKey,
      'code': instance.code,
    };

NoOofBasements _$NoOofBasementsFromJson(Map<String, dynamic> json) {
  return NoOofBasements()
    ..i18nKey = json['i18nKey'] as String?
    ..code = json['code'] as int?;
}

Map<String, dynamic> _$NoOofBasementsToJson(NoOofBasements instance) =>
    <String, dynamic>{
      'i18nKey': instance.i18nKey,
      'code': instance.code,
    };

Unit _$UnitFromJson(Map<String, dynamic> json) {
  return Unit()
    ..plotSize = json['plotSize'] as String?
    ..builtUpArea = json['builtUpArea'] as String?
    ..selfOccupied = json['selfOccupied'] == null
        ? null
        : IsResdential.fromJson(json['selfOccupied'] as Map<String, dynamic>)
    ..isAnyPartOfThisFloorUnOccupied =
        json['isAnyPartOfThisFloorUnOccupied'] == null
            ? null
            : IsResdential.fromJson(
                json['isAnyPartOfThisFloorUnOccupied'] as Map<String, dynamic>)
    ..constructionDetail = json['constructionDetail'] == null
        ? null
        : ConstructionDetail.fromJson(
            json['constructionDetail'] as Map<String, dynamic>);
}

Map<String, dynamic> _$UnitToJson(Unit instance) => <String, dynamic>{
      'plotSize': instance.plotSize,
      'builtUpArea': instance.builtUpArea,
      'selfOccupied': instance.selfOccupied,
      'isAnyPartOfThisFloorUnOccupied': instance.isAnyPartOfThisFloorUnOccupied,
      'constructionDetail': instance.constructionDetail,
    };

ConstructionDetail _$ConstructionDetailFromJson(Map<String, dynamic> json) {
  return ConstructionDetail()
    ..constructionType = json['constructionType'] as String?
    ..builtUpArea = json['builtUpArea'] as String?;
}

Map<String, dynamic> _$ConstructionDetailToJson(ConstructionDetail instance) =>
    <String, dynamic>{
      'constructionType': instance.constructionType,
      'builtUpArea': instance.builtUpArea,
    };
