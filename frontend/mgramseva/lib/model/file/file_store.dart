import 'package:json_annotation/json_annotation.dart';

part 'file_store.g.dart';

@JsonSerializable()
class FileStore {

  @JsonKey(name: "fileStoreId")
  String? fileStoreId;

  @JsonKey(name: "tenantId")
  String? tenantId;

  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "url")
  String? url;

  FileStore(this.fileStoreId, this.tenantId);

  factory FileStore.fromJson(Map<String, dynamic> json) =>
      _$FileStoreFromJson(json);

  Map<String, dynamic> toJson() => _$FileStoreToJson(this);
}