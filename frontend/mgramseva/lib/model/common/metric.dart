import 'package:json_annotation/json_annotation.dart';

part 'metric.g.dart';

@JsonSerializable()
class Metric {

  @JsonKey(name: "label")
  String? label;

  @JsonKey(name: "value")
  String? value;

  @JsonKey(name: "type")
  String? type;

  Metric({this.label, this.value, this.type});

  factory Metric.fromJson(Map<String, dynamic> json) =>
      _$MetricFromJson(json);

  Map<String, dynamic> toJson() => _$MetricToJson(this);
}