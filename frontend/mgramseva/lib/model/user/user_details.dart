import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/model/mdms/tenants.dart';

part 'user_details.g.dart';

@JsonSerializable()
class UserDetails {
  @JsonKey(name: "access_token")
  String? accessToken;
  @JsonKey(name: "tokenType")
  String? tokenType;
  @JsonKey(name: "refreshToken")
  String? refreshToken;
  @JsonKey(name: "expiresIn")
  int? expiresIn;
  @JsonKey(name: "scope")
  String? scope;
  @JsonKey(name: "UserRequest")
  UserRequest? userRequest;
  @JsonKey(name: "selectedLanguage")
  Languages? selectedLanguage;

  @JsonKey(name: "selectedTenant")
  Tenants? selectedtenant;

  @JsonKey(name: 'isFirstTimeLogin')
  bool? isFirstTimeLogin;

  UserDetails();

  factory UserDetails.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailsToJson(this);
}

@JsonSerializable()
class UserRequest {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "uuid")
  String? uuid;
  @JsonKey(name: "userName")
  String? userName;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "mobileNumber")
  String? mobileNumber;
  @JsonKey(name: "emailId")
  String? emailId;
  @JsonKey(name: "locale")
  String? locale;
  @JsonKey(name: "type")
  String? type;
  @JsonKey(name: "roles")
  List<Roles>? roles;
  @JsonKey(name: "active")
  bool? active;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "permanentCity")
  String? permanentCity;

  UserRequest();
  factory UserRequest.fromJson(Map<String, dynamic> json) =>
      _$UserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UserRequestToJson(this);
}

@JsonSerializable()
class Roles {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "tenantId")
  String? tenantId;
  Roles();

  factory Roles.fromJson(Map<String, dynamic> json) => _$RolesFromJson(json);

  Map<String, dynamic> toJson() => _$RolesToJson(this);
}
