// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_details.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetails _$UserDetailsFromJson(Map<String, dynamic> json) {
  return UserDetails()
    ..accessToken = json['access_token'] as String?
    ..tokenType = json['tokenType'] as String?
    ..refreshToken = json['refreshToken'] as String?
    ..expiresIn = json['expiresIn'] as int?
    ..scope = json['scope'] as String?
    ..userRequest = json['UserRequest'] == null
        ? null
        : UserRequest.fromJson(json['UserRequest'] as Map<String, dynamic>)
    ..selectedLanguage = json['selectedLanguage'] == null
        ? null
        : Languages.fromJson(json['selectedLanguage'] as Map<String, dynamic>)
    ..selectedtenant = json['selectedTenant'] == null
        ? null
        : Tenants.fromJson(json['selectedTenant'] as Map<String, dynamic>)
    ..isFirstTimeLogin = json['isFirstTimeLogin'] as bool?;
}

Map<String, dynamic> _$UserDetailsToJson(UserDetails instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'tokenType': instance.tokenType,
      'refreshToken': instance.refreshToken,
      'expiresIn': instance.expiresIn,
      'scope': instance.scope,
      'UserRequest': instance.userRequest,
      'selectedLanguage': instance.selectedLanguage,
      'selectedTenant': instance.selectedtenant,
      'isFirstTimeLogin': instance.isFirstTimeLogin,
    };

UserRequest _$UserRequestFromJson(Map<String, dynamic> json) {
  return UserRequest()
    ..id = json['id'] as int?
    ..uuid = json['uuid'] as String?
    ..userName = json['userName'] as String?
    ..name = json['name'] as String?
    ..mobileNumber = json['mobileNumber'] as String?
    ..emailId = json['emailId'] as String?
    ..locale = json['locale'] as String?
    ..type = json['type'] as String?
    ..roles = (json['roles'] as List<dynamic>?)
        ?.map((e) => Roles.fromJson(e as Map<String, dynamic>))
        .toList()
    ..active = json['active'] as bool?
    ..tenantId = json['tenantId'] as String?
    ..permanentCity = json['permanentCity'] as String?;
}

Map<String, dynamic> _$UserRequestToJson(UserRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'userName': instance.userName,
      'name': instance.name,
      'mobileNumber': instance.mobileNumber,
      'emailId': instance.emailId,
      'locale': instance.locale,
      'type': instance.type,
      'roles': instance.roles,
      'active': instance.active,
      'tenantId': instance.tenantId,
      'permanentCity': instance.permanentCity,
    };

Roles _$RolesFromJson(Map<String, dynamic> json) {
  return Roles()
    ..name = json['name'] as String?
    ..code = json['code'] as String?
    ..tenantId = json['tenantId'] as String?;
}

Map<String, dynamic> _$RolesToJson(Roles instance) => <String, dynamic>{
      'name': instance.name,
      'code': instance.code,
      'tenantId': instance.tenantId,
    };
