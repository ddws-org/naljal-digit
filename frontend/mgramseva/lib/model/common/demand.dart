import 'package:json_annotation/json_annotation.dart';

part 'demand.g.dart';

@JsonSerializable()
class Demand {
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

  @JsonKey(name: "billExpiryTime")
  int? billExpiryTime;

  @JsonKey(name: "status")
  String? status;

  @JsonKey(name: "minimumAmountPayable")
  double? minimumAmountPayable;

  @JsonKey(name: "isPaymentCompleted")
  bool? isPaymentCompleted;

  Demand();

  factory Demand.fromJson(Map<String, dynamic> json) => _$DemandFromJson(json);

  Map<String, dynamic> toJson() => _$DemandToJson(this);
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

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "gender")
  String? gender;

  @JsonKey(name: "mobileNumber")
  String? mobileNumber;

  @JsonKey(name: "tenantId")
  String? tenantId;

  @JsonKey(name: "active")
  bool? active;

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
  String taxHeadMasterCode = '';

  @JsonKey(name: "taxAmount")
  double taxAmount = 0.0;

  @JsonKey(name: "collectionAmount")
  double? collectionAmount;

  @JsonKey(name: "tenantId")
  String? tenantId;

  DemandDetails();

  factory DemandDetails.fromJson(Map<String, dynamic> json) =>
      _$DemandDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$DemandDetailsToJson(this);
}
