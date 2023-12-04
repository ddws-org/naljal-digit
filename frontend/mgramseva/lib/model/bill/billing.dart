import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/bill/meter_demand_details.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
part 'billing.g.dart';

@JsonSerializable()
class BillList {
  @JsonKey(name: "Bill")
  List<Bill>? bill;
  BillList();

  factory BillList.fromJson(Map<String, dynamic> json) =>
      _$BillListFromJson(json);

  Map<String, dynamic> toJson(List list) => _$BillListToJson(this);
}

@JsonSerializable()
class Bill {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "mobileNumber")
  String? mobileNumber;
  @JsonKey(name: "payerName")
  String? payerName;
  @JsonKey(name: "payerAddress")
  String? payerAddress;
  @JsonKey(name: "payerEmail")
  String? payerEmail;
  @JsonKey(name: "status")
  String? status;
  @JsonKey(name: "totalAmount")
  double? totalAmount;
  @JsonKey(name: "penalty")
  double? penalty;
  @JsonKey(name: "netAmountDueWithPenalty")
  double? netAmountDueWithPenalty;
  @JsonKey(name: "businessService")
  String? businessService;
  @JsonKey(name: "billNumber")
  String? billNumber;
  @JsonKey(name: "billDate")
  int? billDate;
  @JsonKey(name: "consumerCode")
  String? consumerCode;
  @JsonKey(name: "billDetails")
  List<BillDetails>? billDetails;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "fileStoreId")
  String? fileStoreId;
  @JsonKey(name: "auditDetails")
  AuditDetails? auditDetails;
  @JsonKey(name: "meterReadings")
  List<MeterReadings>? meterReadings;

  @JsonKey(name: "waterconnection")
  WaterConnection? waterConnection;
  Bill();

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

  Map<String, dynamic> toJson() => _$BillToJson(this);
}

@JsonSerializable()
class BillDetails {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "tenantId")
  String? tenantId;

  @JsonKey(name: "demandId")
  String? demandId;
  @JsonKey(name: "billId")
  String? billId;
  @JsonKey(name: "expiryDate")
  int? expiryDate;
  @JsonKey(name: "amount")
  double? amount;
  @JsonKey(name: "fromPeriod")
  int? fromPeriod;
  @JsonKey(name: "toPeriod")
  int? toPeriod;
  @JsonKey(name: "billAccountDetails")
  List<BillAccountDetails>? billAccountDetails;
  BillDetails();

  factory BillDetails.fromJson(Map<String, dynamic> json) =>
      _$BillDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BillDetailsToJson(this);
}

@JsonSerializable()
class BillAccountDetails {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "billDetailId")
  String? billDetailId;
  @JsonKey(name: "demandDetailId")
  String? demandDetailId;
  @JsonKey(name: "order")
  int? order;
  @JsonKey(name: "amount")
  double? amount;
  @JsonKey(name: "adjustedAmount")
  double? adjustedAmount;
  @JsonKey(name: "taxHeadCode")
  String? taxHeadCode;
  BillAccountDetails();

  factory BillAccountDetails.fromJson(Map<String, dynamic> json) =>
      _$BillAccountDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BillAccountDetailsToJson(this);
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
