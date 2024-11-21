import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/bill/billing.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/model/demand/demand_list.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/household_details_provider.dart';
import 'package:mgramseva/repository/pdf_repository.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/widgets/button_group.dart';
import 'package:mgramseva/widgets/list_label_text.dart';
import 'package:mgramseva/widgets/short_button.dart';
import 'package:provider/provider.dart';

import '../../utils/models.dart';
import '../../widgets/custom_details.dart';

class NewConsumerBill extends StatefulWidget {
  final String? mode;
  final String? status;
  final WaterConnection? waterConnection;
  final List<Demands> demandList;

  const NewConsumerBill(
      this.mode, this.status, this.waterConnection, this.demandList);
  @override
  State<StatefulWidget> createState() {
    return NewConsumerBillState();
  }
}

class NewConsumerBillState extends State<NewConsumerBill> {
  @override
  void initState() {
    super.initState();
  }

  static getLabelText(label, value, context, {subLabel = ''}) {
    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8),
        child: (Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.only(right: 16),
                width: MediaQuery.of(context).size.width / 3,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ApplicationLocalizations.of(context).translate(label),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.start,
                      ),
                      subLabel?.trim?.toString() != ''
                          ? Text(
                              subLabel,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).primaryColorLight),
                            )
                          : Text('')
                    ])),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            )
          ],
        )));
  }

  static getDueDatePenalty(dueDate, BuildContext context) {
    late String localizationText;
    localizationText =
        '${ApplicationLocalizations.of(context).translate(i18.billDetails.CORE_PAID_AFTER)}';
    localizationText = localizationText.replaceFirst('{dueDate}', dueDate);
    return localizationText;
  }

  @override
  Widget build(BuildContext context) {
    return buildBillView(widget.waterConnection?.fetchBill ?? BillList());
  }

  buildBillView(BillList billList) {
    var houseHoldProvider =
        Provider.of<HouseHoldProvider>(context, listen: false);
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    var penalty = billList.bill!.isEmpty
        ? Penalty(0.0, '0', false)
        : CommonProvider.getPenalty(widget.waterConnection?.demands);

    return LayoutBuilder(builder: (context, constraints) {
      // Handler Status
      return billList.bill!.isEmpty
          ? Text("")
          : showBill(widget.demandList)
              ? houseHoldProvider.isfirstdemand == false &&
                      widget.mode != 'collect'
                  ? Text("")
                  : Column(
                      children: [
                        Container(
                            padding: EdgeInsets.only(top: 16, bottom: 8),
                            child: ListLabelText(i18
                                .billDetails.NEW_CONSUMERGENERATE_BILL_LABEL)),
                        Card(
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Visibility(
                                        visible:
                                            houseHoldProvider.isfirstdemand ==
                                                    true
                                                ? true
                                                : false,
                                        child: TextButton.icon(
                                          onPressed: () => downloadPdf(
                                              commonProvider,
                                              billList,
                                              houseHoldProvider),
                                          icon: Icon(Icons.download_sharp),
                                          label: Text(
                                            ApplicationLocalizations.of(context)
                                                .translate(
                                                    i18.common.BILL_DOWNLOAD),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                      houseHoldProvider.isfirstdemand == true
                                          ? getLabelText(
                                              i18.generateBillDetails
                                                  .LAST_BILL_GENERATION_DATE,
                                              DateFormats.timeStampToDate(
                                                      billList
                                                          .bill!.first.billDate,
                                                      format: "dd/MM/yyyy")
                                                  .toString(),
                                              context)
                                          : Text(""),
                                      if (CommonProvider
                                              .getPenaltyOrAdvanceStatus(
                                                  widget.waterConnection
                                                      ?.mdmsData,
                                                  false) &&
                                          !houseHoldProvider.isfirstdemand &&
                                          widget.demandList.first.demandDetails
                                                  ?.any((e) =>
                                                      e.taxHeadMasterCode ==
                                                      '10201') ==
                                              true)
                                        getLabelText(
                                            i18.billDetails.WS_10201,
                                            ('₹' +
                                                CommonProvider.getNormalPenalty(
                                                        widget.demandList)
                                                    .toString()),
                                            context),
                                      if (!houseHoldProvider.isfirstdemand &&
                                          (billList.bill?.first
                                                      .totalAmount ??
                                                  0) >=
                                              0)
                                        getLabelText(
                                            houseHoldProvider
                                                        .isfirstdemand ==
                                                    true
                                                ? i18.billDetails.CURRENT_BILL
                                                : i18.billDetails.ARRERS_DUES,
                                            ('₹' +
                                                (houseHoldProvider
                                                            .isfirstdemand
                                                        ? widget
                                                            .demandList
                                                            .first
                                                            .demandDetails!
                                                            .first
                                                            .taxAmount
                                                        : CommonProvider
                                                            .getArrearsAmount(
                                                                widget
                                                                    .demandList))
                                                    .toString()),
                                            context),
                                      // Current Bill
                                      if (houseHoldProvider.isfirstdemand)
                                        getLabelText(
                                            i18.billDetails.CURRENT_BILL,
                                            "₹ ${(houseHoldProvider.aggDemandItems?.currentmonthTotalDue ?? 0.0) + double.parse(CommonProvider.getAdvanceAdjustedAmount(widget.demandList))}",
                                            context),
                                      // Arrear Dues
                                      if (houseHoldProvider.isfirstdemand ==
                                          true)
                                        getLabelText(
                                            i18.billDetails.ARRERS_DUES,
                                            "₹ ${houseHoldProvider.aggDemandItems?.totalAreasWithPenalty ?? 0.0}",
                                            context),

                                      // Total Amount
                                      if (houseHoldProvider.isfirstdemand ==
                                          true)
                                        getLabelText(
                                            i18.billDetails.TOTAL_AMOUNT,
                                            "₹ ${(houseHoldProvider.aggDemandItems?.netDueWithPenalty ?? 0.0) + double.parse(CommonProvider.getAdvanceAdjustedAmount(widget.demandList))}",
                                            context),

                                      // Advance Avaialble
                                      if (houseHoldProvider.aggDemandItems
                                                  ?.remainingAdvance !=
                                              null &&
                                          houseHoldProvider.aggDemandItems
                                                  ?.remainingAdvance !=
                                              0 &&
                                          !houseHoldProvider.isfirstdemand)
                                        getLabelText(
                                            i18.common.ADVANCE_AVAILABLE,
                                            "${houseHoldProvider.aggDemandItems?.remainingAdvance?.sign == -1 ? "-" : ""} ₹ ${(houseHoldProvider.aggDemandItems?.remainingAdvance?.abs())}",
                                            context),

                                      // Advance Adjust Amount
                                      if (CommonProvider
                                              .getPenaltyOrAdvanceStatus(
                                                  widget.waterConnection
                                                      ?.mdmsData,
                                                  true) &&
                                          houseHoldProvider.isfirstdemand)
                                        getLabelText(
                                            i18.common.CORE_ADVANCE_ADJUSTED,

                                            double.parse(CommonProvider
                                                        .getAdvanceAdjustedAmount(
                                                            widget
                                                                .demandList)) == 0 ? "₹ ${houseHoldProvider.aggDemandItems?.remainingAdvance}" :
                                            double.parse(CommonProvider
                                                        .getAdvanceAdjustedAmount(
                                                            widget
                                                                .demandList)) <
                                                    0
                                                ? "₹ ${double.parse(CommonProvider.getAdvanceAdjustedAmount(widget.demandList))}"
                                                : '- ₹${double.parse(CommonProvider.getAdvanceAdjustedAmount(widget.demandList))}',
                                            context),
                                      // Net Due Amount
                                      if (CommonProvider
                                              .getPenaltyOrAdvanceStatus(
                                                  widget.waterConnection
                                                      ?.mdmsData,
                                                  true) &&
                                          houseHoldProvider.isfirstdemand)
                                        getLabelText(
                                            i18.common.CORE_NET_DUE_AMOUNT,
                                            "${netDueAmount(houseHoldProvider)}",
                                            context),

                                      if (CommonProvider
                                              .getPenaltyOrAdvanceStatus(
                                                  widget.waterConnection
                                                      ?.mdmsData,
                                                  false,
                                                  true) &&
                                          houseHoldProvider.isfirstdemand)
                                        CustomDetailsCard(Column(
                                          children: [
                                            getLabelText(
                                                i18.billDetails.CORE_PENALTY,
                                                ('₹' +
                                                    "${houseHoldProvider.aggDemandItems?.totalApplicablePenalty ?? 0.0}"),
                                                context,
                                                subLabel: getDueDatePenalty(
                                                    penalty.date, context)),
                                            getLabelText(
                                                i18.billDetails
                                                    .CORE_NET_DUE_AMOUNT_WITH_PENALTY,
                                                ('₹' +
                                                    "${(houseHoldProvider.aggDemandItems?.netDueWithPenalty ?? 0.0) + (houseHoldProvider.aggDemandItems?.totalApplicablePenalty ?? 0.0)}"),
                                                context,
                                                subLabel: getDueDatePenalty(
                                                    penalty.date, context))
                                          ],
                                        )),

                                      widget.mode == 'collect'
                                          ? Align(
                                              alignment: Alignment.centerLeft,
                                              child: houseHoldProvider
                                                          .isfirstdemand ==
                                                      true
                                                  ? ButtonGroup(
                                                      i18.billDetails
                                                          .COLLECT_PAYMENT,
                                                      () =>
                                                          commonProvider
                                                              .getFileFromPDFBillService(
                                                                  {
                                                                "Bill": [
                                                                  billList.bill!
                                                                      .first
                                                                ]
                                                              },
                                                                  {
                                                                "key": widget
                                                                            .waterConnection
                                                                            ?.connectionType ==
                                                                        'Metered'
                                                                    ? 'ws-bill'
                                                                    : 'ws-bill-nm',
                                                                "tenantId": commonProvider
                                                                    .userDetails!
                                                                    .selectedtenant!
                                                                    .code,
                                                              },
                                                                  billList
                                                                      .bill!
                                                                      .first
                                                                      .mobileNumber,
                                                                  billList.bill!
                                                                      .first,
                                                                  "Share"),
                                                      CommonProvider.getPenaltyOrAdvanceStatus(
                                                                  widget
                                                                      .waterConnection
                                                                      ?.mdmsData,
                                                                  true) &&
                                                              CommonProvider.checkAdvance(
                                                                  widget.demandList) &&
                                                              (CommonProvider.getNetDueAmountWithWithOutPenalty(billList.bill?.first.totalAmount ?? 0, penalty) == 0)
                                                          ? null
                                                          : () => onClickOfCollectPayment(billList.bill!, context))
                                                  : Visibility(
                                                      visible: (billList
                                                                  .bill
                                                                  ?.first
                                                                  .totalAmount ??
                                                              0) >
                                                          0,
                                                      child: ShortButton(
                                                          i18.billDetails
                                                              .COLLECT_PAYMENT,
                                                          CommonProvider.getPenaltyOrAdvanceStatus(
                                                                      widget
                                                                          .waterConnection
                                                                          ?.mdmsData,
                                                                      true) &&
                                                                  CommonProvider.checkAdvance(
                                                                      widget
                                                                          .demandList) &&
                                                                  CommonProvider.getAdvanceAmount(widget.demandList) ==
                                                                      0 &&
                                                                  (CommonProvider.getNetDueAmountWithWithOutPenalty(
                                                                          billList.bill?.first.totalAmount ??
                                                                              0,
                                                                          penalty) ==
                                                                      0)
                                                              ? null
                                                              : () =>
                                                                  onClickOfCollectPayment(
                                                                      billList
                                                                          .bill!,
                                                                      context)),
                                                    ))
                                          : houseHoldProvider.isfirstdemand == true
                                              ? Container(
                                                  width: constraints.maxWidth >
                                                          760
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          3
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          2.2,
                                                  child: OutlinedButton.icon(
                                                    onPressed: () => commonProvider
                                                        .getFileFromPDFBillService(
                                                      {
                                                        "Bill": [
                                                          billList.bill!.first
                                                        ]
                                                      },
                                                      {
                                                        "key": widget
                                                                    .waterConnection
                                                                    ?.connectionType ==
                                                                'Metered'
                                                            ? 'ws-bill'
                                                            : 'ws-bill-nm',
                                                        "tenantId":
                                                            commonProvider
                                                                .userDetails!
                                                                .selectedtenant!
                                                                .code,
                                                      },
                                                      billList.bill!.first
                                                          .mobileNumber,
                                                      billList.bill!.first,
                                                      "Share",
                                                    ),
                                                    style: ElevatedButton.styleFrom(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 8),
                                                        alignment:
                                                            Alignment.center,
                                                        side: BorderSide(
                                                            width: 1,
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor)),
                                                    icon: (Image.asset(
                                                        'assets/png/whats_app.png')),
                                                    label: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 5),
                                                      child: Text(
                                                          ApplicationLocalizations
                                                                  .of(context)
                                                              .translate(i18
                                                                  .common
                                                                  .SHARE_BILL),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 16,
                                                          )),
                                                    ),
                                                  ),
                                                )
                                              : Text(""),
                                    ])))
                      ],
                    )
              : Text("");
    });
  }

  double netDueAmount(HouseHoldProvider houseHoldProvider) {
    var data = ((houseHoldProvider.aggDemandItems?.netDueWithPenalty ?? 0.0) +
            double.parse(
                CommonProvider.getAdvanceAdjustedAmount(widget.demandList))) -
        ((double.parse(
            CommonProvider.getAdvanceAdjustedAmount(widget.demandList))));
    return data;
  }

  void downloadPdf(CommonProvider commonProvider, BillList billList,
      HouseHoldProvider houseHoldProvider) async {
    if (houseHoldProvider.isfirstdemand) {
      await PDFServiceRepository()
          .CreatePDF(
              houseHoldProvider.createPDFBody, houseHoldProvider.createPDFPrams)
          .then((value) async {
            

        commonProvider.getFileFromPDFBillService(
          {
            "BillAndDemand": {
              "Bill": [billList.bill?.first],
              "AggregatedDemands": houseHoldProvider.aggDemandItems
            }
          },
          {
            "key": widget.waterConnection?.connectionType == 'Metered'
                ? "ws-bill-v2"
                : "ws-bill-nm-v2",
            "tenantId": commonProvider.userDetails?.selectedtenant?.code,
          },
          billList.bill!.first.mobileNumber,
          billList.bill?.first,
          "Download",
          fireStoreId: value?.filestoreIds?.first,
        );
      });
    }
  }

  void onClickOfCollectPayment(List<Bill> bill, BuildContext context) {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);

    Map<String, dynamic> query = {
      'consumerCode': bill.first.consumerCode,
      'businessService': bill.first.businessService,
      'tenantId': commonProvider.userDetails?.selectedtenant?.code,
      'demandList': widget.demandList,
      'fetchBill': bill,
      'status': widget.status,
      'connectionType': widget.waterConnection?.connectionType
    };
    Navigator.pushNamed(context, Routes.HOUSEHOLD_DETAILS_COLLECT_PAYMENT,
        arguments: query);
  }

  bool showBill(List<Demands> demandList) {
    var index = -1;
    var houseHoldRegister =
        Provider.of<HouseHoldProvider>(context, listen: false);

    demandList = demandList
        .where((e) =>
            (!(e.isPaymentCompleted ?? false) && e.status != 'CANCELLED'))
        .toList();

    demandList.forEach((e) {
      e.demandDetails?.sort((a, b) =>
          a.auditDetails!.createdTime!.compareTo(b.auditDetails!.createdTime!));
    });

    if (demandList.isEmpty) {
      return false;
    } else if (!houseHoldRegister.isfirstdemand &&
        widget.waterConnection?.connectionType != 'Metered' &&
        (widget.waterConnection?.fetchBill?.bill?.length) == 0) {
      return false;
    } else if ((widget.waterConnection?.fetchBill?.bill?.length ?? 0) > 0 &&
        (widget.waterConnection?.fetchBill?.bill?.first.totalAmount ?? 0) >=
            0) {
      return true;
    } else {
      if (demandList.isEmpty) return false;

      for (int i = 0; i < demandList.length; i++) {
        index = demandList[i].demandDetails?.lastIndexWhere(
                (e) => e.taxHeadMasterCode == 'WS_ADVANCE_CARRYFORWARD') ??
            -1;

        if (index != -1) {
          var demandDetail = demandList[i].demandDetails?[index];
          if (demandDetail!.collectionAmount! == demandDetail.taxAmount!) {
            if (demandList.first.demandDetails?.last.collectionAmount != 0) {
              var list = <double>[];
              for (int j = 0; j <= i; j++) {
                for (int k = 0;
                    k < (demandList[j].demandDetails?.length ?? 0);
                    k++) {
                  if (k == index && j == i) break;
                  list.add(
                      demandList[j].demandDetails![k].collectionAmount ?? 0);
                }
              }
              var collectedAmount = list.reduce((a, b) => a + b);
              return collectedAmount == demandDetail.collectionAmount?.abs();
            }
          } else if (demandDetail.taxAmount! < demandDetail.collectionAmount!) {
            return true;
          } else if ((houseHoldRegister.aggDemandItems?.remainingAdvance ??
                  0) ==
              0) {
            return false;
          } else if (((houseHoldRegister.aggDemandItems?.remainingAdvance ??
                  0) !=
              0)) {
            return true;
          }
        }
      }
    }
    return false;
  }
}
