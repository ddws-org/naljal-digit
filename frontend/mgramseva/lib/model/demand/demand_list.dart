import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/bill/meter_demand_details.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
part 'demand_list.g.dart';

@JsonSerializable()
class DemandList {
  @JsonKey(name: "Demands")
  List<Demands>? demands;
  DemandList();

  factory DemandList.fromJson(Map<String, dynamic> json) =>
      _$DemandListFromJson(json);

  Map<String, dynamic> toJson() => _$DemandListToJson(this);
}

@JsonSerializable()
class Demands {
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
  Payer? payer;
  @JsonKey(name: "taxPeriodFrom")
  int? taxPeriodFrom;
  @JsonKey(name: "taxPeriodTo")
  int? taxPeriodTo;
  @JsonKey(name: "demandDetails")
  List<DemandDetails>? demandDetails;
  @JsonKey(name: "auditDetails")
  AuditDetails? auditDetails;
  @JsonKey(name: "billExpiryTime")
  int? billExpiryTime;
  @JsonKey(name: "minimumAmountPayable")
  double? minimumAmountPayable;
  @JsonKey(name: "status")
  String? status;
  @JsonKey(name: "meterReadings")
  List<MeterReadings>? meterReadings;
  @JsonKey(name: "isPaymentCompleted")
  bool? isPaymentCompleted = false;
  Demands();
  factory Demands.fromJson(Map<String, dynamic> json) =>
      _$DemandsFromJson(json);

  Map<String, dynamic> toJson() => _$DemandsToJson(this);
}

@JsonSerializable()
class Payer {
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
  Payer();

  factory Payer.fromJson(Map<String, dynamic> json) => _$PayerFromJson(json);

  Map<String, dynamic> toJson() => _$PayerToJson(this);
}

@JsonSerializable()
class DemandDetails {
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
  @JsonKey(name: "additionalDetails")
  AdditionalDetails? additionalDetails;
  @JsonKey(name: "auditDetails")
  AuditDetails? auditDetails;
  @JsonKey(name: "tenantId")
  String? tenantId;
  DemandDetails();

  factory DemandDetails.fromJson(Map<String, dynamic> json) =>
      _$DemandDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$DemandDetailsToJson(this);
}

@JsonSerializable()
class AggragateDemandDetails {
  @JsonKey(name: "advanceAvailable")
  double? advanceAvailable;
  @JsonKey(name: "advanceAdjusted")
  double? advanceAdjusted;
  @JsonKey(name: "remainingAdvance")
  double? remainingAdvance;
  @JsonKey(name: "currentmonthBill")
  double? currentmonthBill;
  @JsonKey(name: "currentMonthPenalty")
  double? currentMonthPenalty;
  @JsonKey(name: "currentmonthTotalDue")
  double? currentmonthTotalDue;
  @JsonKey(name: "currentmonthRoundOff")
  double? currentmonthRoundOff;
  @JsonKey(name: "totalAreas")
  double? totalAreas;
  @JsonKey(name: "totalAreasWithPenalty")
  double? totalAreasWithPenalty;
  @JsonKey(name: "netdue")
  double? netdue;
  @JsonKey(name: "netDueWithPenalty")
  double? netDueWithPenalty;
  @JsonKey(name: "totalApplicablePenalty")
  double? totalApplicablePenalty;
  @JsonKey(name: "latestDemandCreatedTime")
  double? latestDemandCreatedTime;
  @JsonKey(name: "latestDemandPenaltyCreatedtime")
  double? latestDemandPenaltyCreatedtime;
  @JsonKey(name: "mapOfDemandDetailList")
  List<Map<String, List<DemandDetails>>>? mapOfDemandDetailList;
  AggragateDemandDetails();

  factory AggragateDemandDetails.fromJson(Map<String, dynamic> json) =>
      _$AggragateDemandDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$AggragateDemandDetailsToJson(this);
}

@JsonSerializable()
class AggregateDemandDetailsList {
  // Renamed class to match JSON element
  final List<Map<String, List<DemandDetails>>> mapOfDemandDetailList;

  AggregateDemandDetailsList({required this.mapOfDemandDetailList});

  factory AggregateDemandDetailsList.fromJson(Map<String, dynamic> json) =>
      _$AggregateDemandDetailsListFromJson(json);

  Map<String, dynamic> toJson() => _$AggregateDemandDetailsListToJson(this);
}

@JsonSerializable()
class AuditDetails {
  @JsonKey(name: "createdBy")
  String? createdBy;
  @JsonKey(name: "lastModifiedBy")
  String? lastModifiedBy;
  @JsonKey(name: "createdTime")
  int? createdTime;
  @JsonKey(name: "lastModifiedTime")
  int? lastModifiedTime;
  AuditDetails();
  factory AuditDetails.fromJson(Map<String, dynamic> json) =>
      _$AuditDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$AuditDetailsToJson(this);
}
