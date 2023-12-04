import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/bill/billing.dart';

part 'bill_payments.g.dart';

@JsonSerializable()
class BillPayments {
  @JsonKey(name: "Payments")
  List<Payments>? payments;
  BillPayments();

  factory BillPayments.fromJson(Map<String, dynamic> json) =>
      _$BillPaymentsFromJson(json);

  Map<String, dynamic> toJson() => _$BillPaymentsToJson(this);
}

@JsonSerializable()
class Payments {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "totalDue")
  double? totalDue;
  @JsonKey(name: "totalAmountPaid")
  double? totalAmountPaid;
  @JsonKey(name: "transactionNumber")
  String? transactionNumber;
  @JsonKey(name: "transactionDate")
  int? transactionDate;
  @JsonKey(name: "paymentMode")
  String? paymentMode;
  @JsonKey(name: "instrumentDate")
  int? instrumentDate;
  @JsonKey(name: "instrumentNumber")
  String? instrumentNumber;
  @JsonKey(name: "instrumentStatus")
  String? instrumentStatus;
  @JsonKey(name: "ifscCode")
  String? ifscCode;
  @JsonKey(name: "auditDetails")
  AuditDetails? auditDetails;
  @JsonKey(name: "paymentDetails")
  List<PaymentDetails>? paymentDetails;
  @JsonKey(name: "paidBy")
  String? paidBy;
  @JsonKey(name: "mobileNumber")
  String? mobileNumber;
  @JsonKey(name: "payerName")
  String? payerName;
  @JsonKey(name: "payerAddress")
  String? payerAddress;
  @JsonKey(name: "payerEmail")
  String? payerEmail;
  @JsonKey(name: "payerId")
  String? payerId;
  @JsonKey(name: "paymentStatus")
  String? paymentStatus;
  @JsonKey(name: "fileStoreId")
  String? fileStoreId;
  Payments();
  factory Payments.fromJson(Map<String, dynamic> json) =>
      _$PaymentsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentsToJson(this);
}

@JsonSerializable()
class AuditDetails {
  @JsonKey(name: "id")
  String? createdBy;
  @JsonKey(name: "createdTime")
  int? createdTime;
  @JsonKey(name: "lastModifiedBy")
  String? lastModifiedBy;
  @JsonKey(name: "lastModifiedTime")
  int? lastModifiedTime;
  AuditDetails();

  factory AuditDetails.fromJson(Map<String, dynamic> json) =>
      _$AuditDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$AuditDetailsToJson(this);
}

@JsonSerializable()
class PaymentDetails {
  @JsonKey(name: "paymentId")
  String? paymentId;
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "totalDue")
  double? totalDue;
  @JsonKey(name: "totalAmountPaid")
  double? totalAmountPaid;
  @JsonKey(name: "receiptNumber")
  String? receiptNumber;
  @JsonKey(name: "manualReceiptNumber")
  String? manualReceiptNumber;
  @JsonKey(name: "manualReceiptDate")
  int? manualReceiptDate;
  @JsonKey(name: "receiptDate")
  int? receiptDate;
  @JsonKey(name: "receiptType")
  String? receiptType;
  @JsonKey(name: "businessService")
  String? businessService;
  @JsonKey(name: "billId")
  String? billId;
  @JsonKey(name: "bill")
  Bill? bill;
  @JsonKey(name: "auditDetails")
  AuditDetails? auditDetails;
  PaymentDetails();

  factory PaymentDetails.fromJson(Map<String, dynamic> json) =>
      _$PaymentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentDetailsToJson(this);
}
