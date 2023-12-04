// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PDFServiceResponse _$PDFServiceResponseFromJson(Map<String, dynamic> json) {
  return PDFServiceResponse()
    ..message = json['message'] as String?
    ..filestoreIds = (json['filestoreIds'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList()
    ..jobid = json['jobid'] as String?
    ..createdtime = json['createdtime'] as int?
    ..endtime = json['endtime'] as int?
    ..tenantid = json['tenantid'] as String?
    ..totalcount = json['totalcount'] as int?
    ..key = json['key'] as String?
    ..documentType = json['documentType'] as String?
    ..moduleName = json['moduleName'] as String?;
}

Map<String, dynamic> _$PDFServiceResponseToJson(PDFServiceResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'filestoreIds': instance.filestoreIds,
      'jobid': instance.jobid,
      'createdtime': instance.createdtime,
      'endtime': instance.endtime,
      'tenantid': instance.tenantid,
      'totalcount': instance.totalcount,
      'key': instance.key,
      'documentType': instance.documentType,
      'moduleName': instance.moduleName,
    };
