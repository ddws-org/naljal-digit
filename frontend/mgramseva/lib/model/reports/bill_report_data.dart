import 'package:json_annotation/json_annotation.dart';

part 'bill_report_data.g.dart';

@JsonSerializable()
class BillReportData {
  @JsonKey(name: "tenantName")
  String? tenantName;
  @JsonKey(name: "consumerName")
  String? consumerName;
  @JsonKey(name: "connectionNo")
  String? connectionNo;
  @JsonKey(name: "oldConnectionNo")
  String? oldConnectionNo;
  @JsonKey(name: "consumerCreatedOnDate")
  String? consumerCreatedOnDate;
  @JsonKey(name: "penalty")
  double? penalty;
  @JsonKey(name: "advance")
  double? advance;
  @JsonKey(name: "demandAmount")
  double? demandAmount;
  @JsonKey(name: "userId")
  String? userId;

  @override
  String toString() {
    return 'BillReportData{tenantName: $tenantName, consumerName: $consumerName, connectionNo: $connectionNo, oldConnectionNo: $oldConnectionNo, consumerCreatedOnDate: $consumerCreatedOnDate, advance: $advance, penalty: $penalty, demandAmount: $demandAmount, userId: $userId}';
  }

  BillReportData();

  factory BillReportData.fromJson(Map<String, dynamic> json) =>
      _$BillReportDataFromJson(json);

  Map<String, dynamic> toJson(List list) => _$BillReportDataToJson(this);
}
