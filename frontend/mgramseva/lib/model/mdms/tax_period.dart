import 'package:json_annotation/json_annotation.dart';
part 'tax_period.g.dart';
@JsonSerializable()
class TaxPeriodListModel {
  @JsonKey(name: "TaxPeriod")
  List<TaxPeriod>? TaxPeriodList;
  TaxPeriodListModel();
  factory TaxPeriodListModel.fromJson(Map<String, dynamic> json) =>
      _$TaxPeriodListModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaxPeriodListModelToJson(this);
}
@JsonSerializable()
class TaxPeriod {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "code")
  String? code;
  @JsonKey(name: "financialYear")
  String? financialYear;
  @JsonKey(name: "periodCycle")
  String? periodCycle;
  @JsonKey(name: "service")
  String? service;
  @JsonKey(name: "fromDate")
  int? fromDate;
  @JsonKey(name: "toDate")
  int? toDate;
  TaxPeriod();
  factory TaxPeriod.fromJson(Map<String, dynamic> json) =>
      _$TaxPeriodFromJson(json);
  Map<String, dynamic> toJson() => _$TaxPeriodToJson(this);

  @override
  String toString() {
    return '$financialYear';
  }
}














