// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FileStore _$FileStoreFromJson(Map<String, dynamic> json) {
  return FileStore(
    json['fileStoreId'] as String?,
    json['tenantId'] as String?,
  )
    ..id = json['id'] as String?
    ..url = json['url'] as String?;
}

Map<String, dynamic> _$FileStoreToJson(FileStore instance) => <String, dynamic>{
      'fileStoreId': instance.fileStoreId,
      'tenantId': instance.tenantId,
      'id': instance.id,
      'url': instance.url,
    };
