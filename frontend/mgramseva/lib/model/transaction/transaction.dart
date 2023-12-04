import 'package:json_annotation/json_annotation.dart';

import '../user_profile/user_profile.dart';

part 'transaction.g.dart';

@JsonSerializable()
class TransactionDetails {

  @JsonKey(name: "Transaction")
  Transaction? transaction;

  TransactionDetails();

  factory TransactionDetails.fromJson(Map<String, dynamic> json) =>
      _$TransactionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionDetailsToJson(this);
}

@JsonSerializable()
class Transaction {
  @JsonKey(name: "tenantId")
  String? tenantId;

  @JsonKey(name: "txnAmount")
  String? txnAmount;

  @JsonKey(name: "billId")
  String? billId;

  @JsonKey(name: "module")
  String? module;

  @JsonKey(name: "consumerCode")
  String? consumerCode;

  @JsonKey(ignore: true)
  String? txnUrl;

  @JsonKey(ignore: true)
  String? checkSum;

  @JsonKey(ignore: true)
  String? messageType;

  @JsonKey(ignore: true)
  String? merchantId;

  @JsonKey(ignore: true)
  String? serviceId;

  @JsonKey(ignore: true)
  String? orderId;

  @JsonKey(ignore: true)
  String? customerId;

  @JsonKey(ignore: true)
  String? transactionAmount;

  @JsonKey(ignore: true)
  String? currencyCode;

  @JsonKey(ignore: true)
  String? requestDateTime;

  @JsonKey(ignore: true)
  String? successUrl;

  @JsonKey(ignore: true)
  String? failUrl;

  @JsonKey(ignore: true)
  String? additionalField1;

  @JsonKey(ignore: true)
  String? additionalField2;

  @JsonKey(ignore: true)
  String? additionalField3;

  @JsonKey(ignore: true)
  String? additionalField4;

  @JsonKey(ignore: true)
  String? additionalField5;

  @JsonKey(name: "taxAndPayments")
  List<TaxAndPayments>? demandDetails;

  @JsonKey(name: "productInfo")
  String? productInfo;

  @JsonKey(name: "gateway")
  String? gateway;


  @JsonKey(name: "callbackUrl")
  String? callbackUrl;

  @JsonKey(name: "txnId")
  String? txnId;

  @JsonKey(name: "user")
  User? user;

  @JsonKey(name: "redirectUrl")
  String? redirectUrl;

  @JsonKey(name: "txnStatus")
  String? txnStatus;

  @JsonKey(name: "txnStatusMsg")
  String? txnStatusMsg;

  @JsonKey(name: "gatewayTxnId")
  String? gatewayTxnId;

  @JsonKey(name: "gatewayPaymentMode")
  String? gatewayPaymentMode;

  @JsonKey(name: "gatewayStatusCode")
  String? gatewayStatusCode;

  @JsonKey(name: "gatewayStatusMsg")
  String? gatewayStatusMsg;

  @JsonKey(name: "bankTransactionNo")
  String? bankTransactionNo;

  @JsonKey(name: "additionalDetails")
  TransactionAdditionalDetails? additionalDetails;
  Transaction();

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}

@JsonSerializable()
class TaxAndPayments {

  @JsonKey(name: "taxAmount")
  String? taxAmount;

  @JsonKey(name: "amountPaid")
  int? amountPaid;

  @JsonKey(name: "billId")
  String? billId;



  TaxAndPayments();

  factory TaxAndPayments.fromJson(Map<String, dynamic> json) =>
      _$TaxAndPaymentsFromJson(json);

  Map<String, dynamic> toJson() => _$TaxAndPaymentsToJson(this);
}
@JsonSerializable()
class TransactionAdditionalDetails {

  @JsonKey(name: "connectionType")
  String? connectionType;

  TransactionAdditionalDetails();

  factory TransactionAdditionalDetails.fromJson(Map<String, dynamic> json) =>
      _$TransactionAdditionalDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionAdditionalDetailsToJson(this);
}