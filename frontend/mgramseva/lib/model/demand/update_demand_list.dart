import 'package:json_annotation/json_annotation.dart';
part 'update_demand_list.g.dart';

@JsonSerializable()
class UpdateDemandList {
  @JsonKey(name: "Demands")
  List<UpdateDemands>? demands;
  UpdateDemandList();

  @JsonKey(name: "totalApplicablePenalty")
  double? totalApplicablePenalty;

  factory UpdateDemandList.fromJson(Map<String, dynamic> json) =>
      _$UpdateDemandListFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDemandListToJson(this);
}

@JsonSerializable()
class UpdateDemands {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "consumerCode")
  String? consumerCode;
  @JsonKey(name: "consumerType")
  String? consumerType;
  @JsonKey(name: "businessService")
  String? businessService;
  @JsonKey(name: "payer")
  UpdatePayer? payer;
  @JsonKey(name: "taxPeriodFrom")
  int? taxPeriodFrom;
  @JsonKey(name: "taxPeriodTo")
  int? taxPeriodTo;
  @JsonKey(name: "demandDetails")
  List<UpdateDemandDetails>? demandDetails;
  @JsonKey(name: "auditDetails")
  UpdateAuditDetails? auditDetails;
  @JsonKey(name: "billExpiryTime")
  int? billExpiryTime;
  @JsonKey(name: "minimumAmountPayable")
  double? minimumAmountPayable;
  @JsonKey(name: "status")
  String? status;
  @JsonKey(name: "isPaymentCompleted")
  bool? isPaymentCompleted = false;
  @JsonKey(ignore: true)
  double? totalApplicablePenalty;
  UpdateDemands();
  factory UpdateDemands.fromJson(Map<String, dynamic> json) =>
      _$UpdateDemandsFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDemandsToJson(this);
}

@JsonSerializable()
class UpdatePayer {
  @JsonKey(name: "uuid")
  String? uuid;
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "userName")
  String? userName;
  @JsonKey(name: "type")
  String? type;
  @JsonKey(name: "salutation")
  String? salutation;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "gender")
  String? gender;
  @JsonKey(name: "mobileNumber")
  String? mobileNumber;
  @JsonKey(name: "emailId")
  String? emailId;
  @JsonKey(name: "altContactNumber")
  String? altContactNumber;
  @JsonKey(name: "pan")
  String? pan;
  @JsonKey(name: "aadhaarNumber")
  String? aadhaarNumber;
  @JsonKey(name: "permanentAddress")
  String? permanentAddress;
  @JsonKey(name: "permanentCity")
  String? permanentCity;
  @JsonKey(name: "permanentPinCode")
  String? permanentPinCode;
  @JsonKey(name: "correspondenceAddress")
  String? correspondenceAddress;
  @JsonKey(name: "correspondenceCity")
  String? correspondenceCity;
  @JsonKey(name: "correspondencePinCode")
  String? correspondencePinCode;
  @JsonKey(name: "active")
  bool? active;
  @JsonKey(name: "tenantId")
  String? tenantId;
  UpdatePayer();

  factory UpdatePayer.fromJson(Map<String, dynamic> json) => _$UpdatePayerFromJson(json);

  Map<String, dynamic> toJson() => _$UpdatePayerToJson(this);
}

@JsonSerializable()
class UpdateDemandDetails {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "demandId")
  String? demandId;
  @JsonKey(name: "taxHeadMasterCode")
  String? taxHeadMasterCode;
  @JsonKey(name: "taxAmount")
  double? taxAmount;
  @JsonKey(name: "collectionAmount")
  double? collectionAmount;
  @JsonKey(name: "auditDetails")
  UpdateAuditDetails? auditDetails;
  @JsonKey(name: "tenantId")
  String? tenantId;
  UpdateDemandDetails();

  factory UpdateDemandDetails.fromJson(Map<String, dynamic> json) =>
      _$UpdateDemandDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateDemandDetailsToJson(this);
}

@JsonSerializable()
class UpdateAuditDetails {
  @JsonKey(name: "createdBy")
  String? createdBy;
  @JsonKey(name: "lastModifiedBy")
  String? lastModifiedBy;
  @JsonKey(name: "createdTime")
  int? createdTime;
  @JsonKey(name: "lastModifiedTime")
  int? lastModifiedTime;
  UpdateAuditDetails();
  factory UpdateAuditDetails.fromJson(Map<String, dynamic> json) =>
      _$UpdateAuditDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateAuditDetailsToJson(this);
}
