import 'package:json_annotation/json_annotation.dart';
part 'meter_demand_details.g.dart';

@JsonSerializable()
class MeterDemand {
  @JsonKey(name: "meterReadings")
  List<MeterReadings>? meterReadings;
  MeterDemand();

  factory MeterDemand.fromJson(Map<String, dynamic> json) =>
      _$MeterDemandFromJson(json);

  Map<String, dynamic> toJson() => _$MeterDemandToJson(this);
}

@JsonSerializable()
class MeterReadings {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "billingPeriod")
  String? billingPeriod;
  @JsonKey(name: "meterStatus")
  String? meterStatus;
  @JsonKey(name: "lastReading")
  int? lastReading;
  @JsonKey(name: "lastReadingDate")
  int? lastReadingDate;
  @JsonKey(name: "currentReading")
  int? currentReading;
  @JsonKey(name: "currentReadingDate")
  int? currentReadingDate;
  @JsonKey(name: "connectionNo")
  String? connectionNo;
  @JsonKey(name: "consumption")
  String? consumption;
  @JsonKey(name: "generateDemand")
  bool? generateDemand;
  @JsonKey(name: "tenantId")
  String? tenantId;
  MeterReadings();

  factory MeterReadings.fromJson(Map<String, dynamic> json) =>
      _$MeterReadingsFromJson(json);

  Map<String, dynamic> toJson() => _$MeterReadingsToJson(this);
}
