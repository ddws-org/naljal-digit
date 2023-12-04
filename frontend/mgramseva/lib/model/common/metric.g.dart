// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'metric.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Metric _$MetricFromJson(Map<String, dynamic> json) {
  return Metric()
    ..label = json['label'] as String?
    ..value = json['value'] as String?
    ..type = json['type'] as String?;
}

Map<String, dynamic> _$MetricToJson(Metric instance) => <String, dynamic>{
      'label': instance.label,
      'value': instance.value,
      'type': instance.type,
    };
