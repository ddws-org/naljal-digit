import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/expenses_details/vendor.dart';
import 'package:mgramseva/model/file/file_store.dart';
import 'package:mgramseva/utils/date_formats.dart';


part 'expenses_details.g.dart';

@JsonSerializable()
class ExpensesDetailsWithPagination {
  @JsonKey(name: "totalCount")
  int? totalCount;

  @JsonKey(name: "billData")
  BillDataCount? billDataCount;

  @JsonKey(name: "challans")
  List<ExpensesDetailsModel>? expenseDetailList = <ExpensesDetailsModel>[];

  ExpensesDetailsWithPagination();

  factory ExpensesDetailsWithPagination.fromJson(Map<String, dynamic> json) =>
      _$ExpensesDetailsWithPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$ExpensesDetailsWithPaginationToJson(this);
}

@JsonSerializable()
class BillDataCount {
  @JsonKey(name: "notPaidcount")
  String? notPaidCount;

  @JsonKey(name: "paidcount")
  String? paidCount;

  BillDataCount();

  factory BillDataCount.fromJson(Map<String, dynamic> json) =>
      _$BillDataCountFromJson(json);
}

@JsonSerializable()
class ExpensesDetailsModel {
  @JsonKey(name: "citizen")
  Citizen? citizen;

  @JsonKey(name: "auditDetails")
  AuditDetails? auditDetails;

  @JsonKey(name: "id")
  String? id;

  @JsonKey(name: "tenantId")
  String? tenantId;

  @JsonKey(name: "businessService")
  String? businessService;

  @JsonKey(name: "consumerType")
  String? consumerType;

  @JsonKey(name: "typeOfExpense")
  String? expenseType;

  @JsonKey(name: "vendor")
  String? vendorId;

  @JsonKey(name: "vendorName")
  String? vendorName;

  @JsonKey(name: "amount")
  List<ExpensesAmount>? expensesAmount = <ExpensesAmount>[];

  @JsonKey(name: "billDate")
  int? billDate;

  @JsonKey(name: "paidDate")
  int? paidDate;

  @JsonKey(name: "billIssuedDate")
  int? billIssuedDate;

  @JsonKey(name: "challanNo")
  String? challanNo;

  @JsonKey(name: "accountId")
  String? accountId;

  @JsonKey(name: "applicationStatus")
  String? applicationStatus;

  @JsonKey(name: "totalAmount")
  double? totalAmount;

  @JsonKey(name: "isBillPaid", defaultValue: false)
  bool? isBillPaid;

  @JsonKey(name: "filestoreid")
  String? fileStoreId;

  @JsonKey(name: "taxPeriodFrom")
  int? taxPeriodFrom;

  @JsonKey(name: "taxPeriodTo")
  int? taxPeriodTo;

  @JsonKey(ignore: true)
  Vendor? selectedVendor;

  @JsonKey(ignore: true)
  bool? isBillCancelled = false;

  @JsonKey(ignore: true)
  bool? allowEdit = true;

  @JsonKey(ignore: true)
  List<FileStore>? fileStoreList;

  @JsonKey(ignore: true)
  var vendorNameCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var billDateCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var fromDateCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var toDateCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var paidDateCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var billIssuedDateCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var challanNumberCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var mobileNumberController = TextEditingController();

  @JsonKey(ignore: true)
  var expenseTypeController = TextEditingController();

  ExpensesDetailsModel();

  setText() {
    vendorId = vendorNameCtrl.text;
    expensesAmount?.first.amount = expensesAmount?.first.amountCtrl.text;
    billDate = DateFormats.dateToTimeStamp(billDateCtrl.text);
    if (billIssuedDateCtrl.text.trim().isNotEmpty)
      billIssuedDate = DateFormats.dateToTimeStamp(billIssuedDateCtrl.text);
    if (paidDateCtrl.text.trim().isNotEmpty)
      paidDate = DateFormats.dateToTimeStamp(paidDateCtrl.text);
    taxPeriodFrom = DateFormats.dateToTimeStamp(fromDateCtrl.text.trim());
    taxPeriodTo = DateFormats.dateToTimeStamp(toDateCtrl.text.trim());
  }

  getText() {
    if (expensesAmount == null || expensesAmount!.isEmpty) {
      expensesAmount = <ExpensesAmount>[]..add(ExpensesAmount());
    }

    vendorNameCtrl.text = vendorName ?? '';
    expensesAmount?.first.amountCtrl.text =
        expensesAmount?.first.amount ?? totalAmount?.toInt().toString() ?? '';
    billDateCtrl.text = DateFormats.timeStampToDate(billDate);
    paidDateCtrl.text =
        paidDate == null || paidDate == 0 ? '' : DateFormats.timeStampToDate(paidDate);
    billIssuedDateCtrl.text =
        billIssuedDate == 0 ? '' : DateFormats.timeStampToDate(billIssuedDate);
    isBillPaid = paidDate != null && paidDate != 0 ? isBillPaid : false;
    challanNumberCtrl.text = challanNo?.toString() ?? '';
    fromDateCtrl.text = DateFormats.timeStampToDate(taxPeriodFrom);
    toDateCtrl.text = DateFormats.timeStampToDate(taxPeriodTo);

    if (selectedVendor == null && challanNo != null) {
      selectedVendor = Vendor(vendorName ?? '', vendorId ?? '');
    }

    if (isBillPaid! && paidDate != null && paidDate != 0) {
      allowEdit = false;
    } else {
      paidDateCtrl.text = '';
      allowEdit = true;
    }
  }

  factory ExpensesDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$ExpensesDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpensesDetailsModelToJson(this);
}

@JsonSerializable()
class ExpensesAmount {
  @JsonKey(name: "taxHeadCode")
  String? taxHeadCode;

  @JsonKey(name: "amount")
  String? amount;

  @JsonKey(ignore: true)
  var amountCtrl = TextEditingController();

  ExpensesAmount();

  factory ExpensesAmount.fromJson(Map<String, dynamic> json) =>
      _$ExpensesAmountFromJson(json);

  Map<String, dynamic> toJson() => _$ExpensesAmountToJson(this);
}

@JsonSerializable()
class Citizen {
  @JsonKey(name: "id")
  int? id;

  @JsonKey(name: "uuid")
  String? uuid;

  @JsonKey(name: "userName")
  String? userName;

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "mobileNumber")
  String? mobileNumber;

  Citizen();

  factory Citizen.fromJson(Map<String, dynamic> json) =>
      _$CitizenFromJson(json);

  Map<String, dynamic> toJson() => _$CitizenToJson(this);
}

@JsonSerializable()
class AuditDetails {
  @JsonKey(name: "createdBy")
  String? createdBy;

  @JsonKey(name: "lastModifiedBy")
  String? lastModifiedBy;

  @JsonKey(name: "createdTime")
  int? createdTime;

  @JsonKey(name: "lastModifiedTime")
  int? lastModifiedTime;

  AuditDetails();

  factory AuditDetails.fromJson(Map<String, dynamic> json) =>
      _$AuditDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$AuditDetailsToJson(this);
}
