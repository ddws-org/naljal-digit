import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import 'package:mgramseva/model/mdms/tax_period.dart';
import 'package:mgramseva/utils/date_formats.dart';

part 'bill_generation_details.g.dart';

@JsonSerializable()
class BillGenerationDetails {
  @JsonKey(name: "tenantId")
  String? tenantId;
  @JsonKey(name: "currentReading")
  int? currentReading;
  @JsonKey(name: "currentReadingDate")
  int? currentReadingDate;
  @JsonKey(name: "connectionNo")
  String? connectionNo;
  @JsonKey(name: "billingPeriod")
  String? billingPeriod;
  @JsonKey(name: "lastReading")
  int? lastReading;
  @JsonKey(name: "meterStatus")
  String? meterStatus;
  @JsonKey(name: "lastReadingDate")
  int? lastReadingDate;
  @JsonKey(name: "generateDemand")
  bool? generateDemand;
  @JsonKey(name: "connectionCategory")
  String? connectionCategory;
  @JsonKey(name: "serviceCat")
  String? serviceCat;
  @JsonKey(name: "serviceType")
  String? serviceType;
  @JsonKey(name: "propertyType")
  String? propertyType;
  @JsonKey(name: "billYear")
  TaxPeriod? billYear;
  @JsonKey(name: "billCycle")
  String? billCycle;
  @JsonKey(name: "meterNumber")
  String? meterNumber;
  @JsonKey(name: "oldMeterReading")
  String? oldMeterReading;
  @JsonKey(name: "newMeterReading")
  String? newMeterReading;
  @JsonKey(name: "meterReadingDate")
  int? meterReadingDate;
  @JsonKey(ignore: true)
  var meterNumberCtrl = new TextEditingController();
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
  @JsonKey(ignore: true)
  var nm_1Ctrl = new TextEditingController();
  @JsonKey(ignore: true)
  var nm_2Ctrl = new TextEditingController();
  @JsonKey(ignore: true)
  var nm_3Ctrl = new TextEditingController();
  @JsonKey(ignore: true)
  var nm_4Ctrl = new TextEditingController();
  @JsonKey(ignore: true)
  var nm_5Ctrl = new TextEditingController();
  @JsonKey(ignore: true)
  var meterReadingDateCtrl = TextEditingController();
  @JsonKey(ignore: true)
  var serviceCategoryCtrl = TextEditingController();
  @JsonKey(ignore: true)
  var serviceTypeCtrl = TextEditingController();
  @JsonKey(ignore: true)
  var propertyTypeCtrl = TextEditingController();
  @JsonKey(ignore: true)
  var billingyearCtrl = TextEditingController();
  @JsonKey(ignore: true)
  var billingcycleCtrl = TextEditingController();

  BillGenerationDetails();

  getText() {
    lastReading = int.parse(om_1Ctrl.text +
        om_2Ctrl.text +
        om_3Ctrl.text +
        om_4Ctrl.text +
        om_5Ctrl.text);
    currentReading = int.parse(nm_1Ctrl.text +
        nm_2Ctrl.text +
        nm_3Ctrl.text +
        nm_4Ctrl.text +
        nm_5Ctrl.text);
    meterReadingDate = DateFormats.dateToTimeStamp(meterReadingDateCtrl.text);
  }

  factory BillGenerationDetails.fromJson(Map<String, dynamic> json) =>
      _$BillGenerationDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$BillGenerationDetailsToJson(this);
}
