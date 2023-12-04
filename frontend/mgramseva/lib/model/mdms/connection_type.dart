import 'package:json_annotation/json_annotation.dart';

part 'connection_type.g.dart';

@JsonSerializable()
class Connection {
  @JsonKey(name: "connectionType")
  List<ConnectionType>? connectionTypeList;

  Connection();

  factory Connection.fromJson(Map<String, dynamic> json) =>
      _$ConnectionFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionToJson(this);
}

@JsonSerializable()
class ConnectionType {
  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "code")
  String? code;

  @JsonKey(name: "isActive")
  bool? isActive;

  ConnectionType();

  factory ConnectionType.fromJson(Map<String, dynamic> json) =>
      _$ConnectionTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ConnectionTypeToJson(this);
}
