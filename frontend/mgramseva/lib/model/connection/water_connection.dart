import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/bill/billing.dart';
import 'package:mgramseva/model/connection/property.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/date_formats.dart';

import '../demand/update_demand_list.dart';
import '../mdms/payment_type.dart';

part 'water_connection.g.dart';

@JsonSerializable()
class WaterConnection {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "connectionNo")
  String? connectionNo;
  @JsonKey(name: "propertyId")
  String? propertyId;
  @JsonKey(name: "applicationNo")
  String? applicationNo;
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "action")
  String? action;
  @JsonKey(name: "status")
  String? status;
  @JsonKey(name: "meterInstallationDate")
  int? meterInstallationDate;
  @JsonKey(name: "documents")
  Documents? documents;
  @JsonKey(name: "proposedTaps")
  int? proposedTaps;

  @JsonKey(name: "noOfTaps")
  int? noOfTaps;
  @JsonKey(name: "arrears")
  double? arrears;
  @JsonKey(name: "connectionType")
  String? connectionType;
  @JsonKey(name: "oldConnectionNo")
  String? oldConnectionNo;
  @JsonKey(name: "meterId")
  String? meterId;
  @JsonKey(name: "propertyType")
  String? propertyType;
  @JsonKey(name: "previousReadingDate")
  int? previousReadingDate;
  @JsonKey(name: "previousReading")
  int? previousReading;
  @JsonKey(name: "proposedPipeSize")
  double? proposedPipeSize;

  @JsonKey(name: "connectionHolders")
  List<Owners>? connectionHolders = [Owners()];

  @JsonKey(name: "additionalDetails")
  AdditionalDetails? additionalDetails;

  @JsonKey(name: "processInstance")
  ProcessInstance? processInstance;

  @JsonKey(name: "paymentType")
  String? paymentType;

  @JsonKey(name: "penalty")
  double? penalty;

  @JsonKey(name: "advance")
  double? advance;

  @JsonKey(ignore: true)
  BillList? fetchBill;

  @JsonKey(ignore: true)
  PaymentType? mdmsData;

  @JsonKey(ignore: true)
  List<UpdateDemands>? demands;

  @JsonKey(ignore: true)
  var arrearsCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var advanceCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var penaltyCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var meterIdCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var previousReadingDateCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var OldConnectionCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var BillingCycleCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var billingCycleYearCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var meterInstallationDateCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var categoryCtrl = new TextEditingController();

  @JsonKey(ignore: true)
  var subCategoryCtrl = new TextEditingController();
  @JsonKey(ignore: true)
  var addharCtrl = new TextEditingController();

  @JsonKey(ignore: true)
  var ServiceTypeCtrl = TextEditingController();

  @JsonKey(ignore: true)
  var om_1Ctrl = new TextEditingController();
  @JsonKey(ignore: true)
  var om_2Ctrl = new TextEditingController();
  @JsonKey(ignore: true)
  var om_3Ctrl = new TextEditingController();
  @JsonKey(ignore: true)
  var om_4Ctrl = new TextEditingController();
  @JsonKey(ignore: true)
  var om_5Ctrl = new TextEditingController();

  setText() {
    oldConnectionNo = OldConnectionCtrl.text;
    meterId = meterIdCtrl.text != "" ? meterIdCtrl.text : null;

    if (paymentType == Constants.CONSUMER_PAYMENT_TYPE.first.key) {
      advanceCtrl.clear();
    } else {
      penaltyCtrl.clear();
      arrearsCtrl.clear();
    }

    arrears =
        arrearsCtrl.text.trim() != "" && double.parse(arrearsCtrl.text) > 0
            ? double.parse(arrearsCtrl.text).toDouble()
            : paymentType == Constants.CONSUMER_PAYMENT_TYPE.first.key
                ? 0.0
                : null;
    advance =
        advanceCtrl.text.trim() != "" && double.parse(advanceCtrl.text) > 0
            ? -double.parse(advanceCtrl.text).toDouble()
            : null;
    penalty =
        penaltyCtrl.text.trim() != "" && double.parse(penaltyCtrl.text) > 0
            ? double.parse(penaltyCtrl.text).toDouble()
            : paymentType == Constants.CONSUMER_PAYMENT_TYPE.first.key
                ? 0.0
                : null;
    previousReadingDate = previousReadingDateCtrl.text != ""
        ? DateFormats.dateToTimeStamp(
            previousReadingDateCtrl.text,
          )
        : null;

    meterInstallationDate = previousReadingDateCtrl.text != ""
        ? DateFormats.dateToTimeStamp(
            previousReadingDateCtrl.text,
          )
        : DateFormats.dateToTimeStamp(DateFormats.getFilteredDate(
            meterInstallationDateCtrl.text,
            dateFormat: "dd/MM/yyyy"));

    if (connectionType != 'Metered') {
      previousReadingDate = BillingCycleCtrl.text.trim() != ""
          ? DateFormats.dateToTimeStamp(
              BillingCycleCtrl.text.trim(),
            )
          : null;
    }
  }

  getText() {
    OldConnectionCtrl.text = oldConnectionNo ?? "";
    meterIdCtrl.text = meterId ?? "";
    arrearsCtrl.text = (arrears == null ? '' : getFilteredAmount(arrears!));
    advanceCtrl.text =
        (advance == null ? '' : getFilteredAmount(advance!.abs()));
    penaltyCtrl.text = (penalty == null ? '' : getFilteredAmount(penalty!));
    categoryCtrl.text = additionalDetails?.category ?? "";
    subCategoryCtrl.text = additionalDetails?.subCategory ?? "";
    addharCtrl.text = additionalDetails?.aadharNumber ?? "";

    previousReadingDateCtrl.text = previousReadingDate == null
        ? DateFormats.timeStampToDate(meterInstallationDate)
        : DateFormats.timeStampToDate(previousReadingDate);

    meterInstallationDateCtrl.text =
        DateFormats.timeStampToDate(meterInstallationDate).toString();
    if ((additionalDetails!.initialMeterReading != null) &&
        additionalDetails!.initialMeterReading!.toString().length > 0) {
      om_1Ctrl.text = additionalDetails!.initialMeterReading!.toString()[0];
      om_2Ctrl.text = additionalDetails!.initialMeterReading!.toString()[1];
      om_3Ctrl.text = additionalDetails!.initialMeterReading!.toString()[2];
      om_4Ctrl.text = additionalDetails!.initialMeterReading!.toString()[3];
      om_5Ctrl.text = additionalDetails!.initialMeterReading!.toString()[4];
    }
  }

  String getFilteredAmount(double amount) {
    if (kIsWeb) return amount.toString();
    var decimalAmount = (amount.toString().split('.'))[1];
    return int.parse(decimalAmount) > 0
        ? amount.toString()
        : amount.toString().split('.').first;
  }

  WaterConnection();

  factory WaterConnection.fromJson(Map<String, dynamic> json) =>
      _$WaterConnectionFromJson(json);
  Map<String, dynamic> toJson() => _$WaterConnectionToJson(this);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WaterConnection &&
        other.id == id &&
        other.connectionNo == connectionNo &&
        other.propertyId == propertyId &&
        other.applicationNo == applicationNo &&
        other.tenantId == tenantId &&
        other.action == action &&
        other.status == status &&
        other.meterInstallationDate == meterInstallationDate &&
        other.documents == documents &&
        other.proposedTaps == proposedTaps &&
        other.noOfTaps == noOfTaps &&
        other.arrears == arrears &&
        other.connectionType == connectionType &&
        other.oldConnectionNo == oldConnectionNo &&
        other.meterId == meterId &&
        other.propertyType == propertyType &&
        other.previousReadingDate == previousReadingDate &&
        other.previousReading == previousReading &&
        other.proposedPipeSize == proposedPipeSize &&
        other.connectionHolders == connectionHolders &&
        other.additionalDetails == additionalDetails &&
        other.processInstance == processInstance &&
        other.paymentType == paymentType &&
        other.penalty == penalty &&
        other.advance == advance;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        connectionNo.hashCode ^
        propertyId.hashCode ^
        applicationNo.hashCode ^
        tenantId.hashCode ^
        action.hashCode ^
        status.hashCode ^
        meterInstallationDate.hashCode ^
        documents.hashCode ^
        proposedTaps.hashCode ^
        noOfTaps.hashCode ^
        arrears.hashCode ^
        connectionType.hashCode ^
        oldConnectionNo.hashCode ^
        meterId.hashCode ^
        propertyType.hashCode ^
        previousReadingDate.hashCode ^
        previousReading.hashCode ^
        proposedPipeSize.hashCode ^
        connectionHolders.hashCode ^
        additionalDetails.hashCode ^
        processInstance.hashCode ^
        paymentType.hashCode ^
        penalty.hashCode ^
        advance.hashCode;
  }
}

@JsonSerializable()
class ProcessInstance {
  @JsonKey(name: "action")
  String? action;

  ProcessInstance();
  factory ProcessInstance.fromJson(Map<String, dynamic> json) =>
      _$ProcessInstanceFromJson(json);
  Map<String, dynamic> toJson() => _$ProcessInstanceToJson(this);
}

@JsonSerializable()
class AdditionalDetails {
  @JsonKey(name: "initialMeterReading")
  int? initialMeterReading;

  @JsonKey(name: "meterReading")
  int? meterReading;
  @JsonKey(name: "locality")
  String? locality;

  @JsonKey(name: "category")
  String? category;
  @JsonKey(name: "subCategory")
  String? subCategory;
  @JsonKey(name: "aadharNumber")
  String? aadharNumber;

  @JsonKey(name: "propertyType")
  String? propertyType;

  @JsonKey(name: "street")
  String? street;

  @JsonKey(name: "lastDemandGeneratedDate")
  String? lastDemandGeneratedDate;

  @JsonKey(name: "doorNo")
  String? doorNo;

  @JsonKey(name: "collectionAmount")
  String? collectionAmount;

  @JsonKey(name: "collectionPendingAmount")
  String? collectionPendingAmount;

  @JsonKey(name: "totalamount")
  String? totalAmount;

  @JsonKey(name: "remarks")
  String? remarks;

  @JsonKey(name: "appCreatedDate")
  num? appCreatedDate;

  @JsonKey(ignore: true)
  var initialMeterReadingCtrl = TextEditingController();
  String? action;
  setText() {
    initialMeterReading = int.parse((initialMeterReadingCtrl.text));
  }

  AdditionalDetails();
  factory AdditionalDetails.fromJson(Map<String, dynamic> json) =>
      _$AdditionalDetailsFromJson(json);
  Map<String, dynamic> toJson() => _$AdditionalDetailsToJson(this);
}
