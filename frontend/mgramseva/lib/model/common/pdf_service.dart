import 'package:json_annotation/json_annotation.dart';

part 'pdf_service.g.dart';

@JsonSerializable()
class PDFServiceResponse {
  @JsonKey(name: "message")
  String? message;
  @JsonKey(name: "filestoreIds")
  List<String>? filestoreIds;
  @JsonKey(name: "jobid")
  String? jobid;
  @JsonKey(name: "createdtime")
  int? createdtime;
  @JsonKey(name: "endtime")
  int? endtime;
  @JsonKey(name: "tenantid")
  String? tenantid;
  @JsonKey(name: "totalcount")
  int? totalcount;
  @JsonKey(name: "key")
  String? key;
  @JsonKey(name: "documentType")
  String? documentType;

  @JsonKey(name: "moduleName")
  String? moduleName;

  PDFServiceResponse();

  factory PDFServiceResponse.fromJson(Map<String, dynamic> json) =>
      _$PDFServiceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PDFServiceResponseToJson(this);
}
