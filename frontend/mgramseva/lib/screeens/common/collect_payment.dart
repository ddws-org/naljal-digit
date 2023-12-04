import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/model/bill/billing.dart';
import 'package:mgramseva/model/common/fetch_bill.dart' as billDetails;
import 'package:mgramseva/model/common/fetch_bill.dart';
import 'package:mgramseva/model/demand/demand_list.dart';
import 'package:mgramseva/model/mdms/payment_type.dart';
import 'package:mgramseva/providers/collect_payment_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_widgets.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/utils/validators/validators.dart';
import 'package:mgramseva/widgets/bottom_button_bar.dart';
import 'package:mgramseva/widgets/confirmation_pop_up.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/form_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/radio_button_field_builder.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:provider/provider.dart';

import '../../components/house_connection_and_bill/new_consumer_bill.dart';
import '../../model/demand/update_demand_list.dart';
import '../../providers/common_provider.dart';
import '../../utils/models.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_details.dart';
import '../../widgets/text_field_builder.dart';

class ConnectionPaymentView extends StatefulWidget {
  final Map<String, dynamic> query;
  final List<Bill>? bill;
  final List<Demands>? demandList;
  final PaymentType? paymentType;
  final List<UpdateDemands>? updateDemandList;
  const ConnectionPaymentView(
      {Key? key,
      required this.query,
      this.bill,
      this.demandList,
      this.paymentType,
      this.updateDemandList})
      : super(key: key);

  @override
  _ConnectionPaymentViewState createState() => _ConnectionPaymentViewState();
}

class _ConnectionPaymentViewState extends State<ConnectionPaymentView> {
  final formKey = GlobalKey<FormState>();
  var autoValidation = false;

  @override
  void initState() {
    var consumerPaymentProvider =
        Provider.of<CollectPaymentProvider>(context, listen: false);
    consumerPaymentProvider.getBillDetails(context, widget.query, widget.bill,
        widget.demandList, widget.paymentType, widget.updateDemandList);
    super.initState();
  }

  static getLabelText(label, value, context, {subLabel = ''}) {
    return Container(
        padding: EdgeInsets.only(top: 8, bottom: 8, right: 24),
        child: (Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                margin: EdgeInsets.only(
                    right: MediaQuery.of(context).size.width > 760 ? 8 : 36),
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
              textAlign: TextAlign.right,
            )
          ],
        )));
  }

  @override
  Widget build(BuildContext context) {
    var consumerPaymentProvider =
        Provider.of<CollectPaymentProvider>(context, listen: false);
    FetchBill? fetchBill;
    return FocusWatcher(
        child: Scaffold(
      drawer: DrawerWrapper(
        Drawer(child: SideBar()),
      ),
      appBar: CustomAppBar(),
      body: StreamBuilder(
          stream: consumerPaymentProvider.paymentStreamController.stream,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data is String) {
                return CommonWidgets.buildEmptyMessage(snapshot.data, context);
              }
              fetchBill = snapshot.data;
              return _buildView(snapshot.data);
            } else if (snapshot.hasError) {
              return Notifiers.networkErrorPage(
                  context,
                  () => consumerPaymentProvider.getBillDetails(
                      context,
                      widget.query,
                      widget.bill,
                      widget.demandList,
                      widget.paymentType,
                      widget.updateDemandList));
            } else {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Loaders.circularLoader();
                case ConnectionState.active:
                  return Loaders.circularLoader();
                default:
                  return Container();
              }
            }
          }),
      bottomNavigationBar: Consumer<CollectPaymentProvider>(
        builder: (_, consumerPaymentProvider, child) => Visibility(
            visible: fetchBill != null,
            child: BottomButtonBar(
                '${ApplicationLocalizations.of(context).translate(i18.common.COLLECT_PAYMENT)}',
                () => showGeneralDialog(
                      barrierLabel: "Label",
                      barrierDismissible: false,
                      barrierColor: Colors.black.withOpacity(0.5),
                      context: context,
                      pageBuilder: (context, anim1, anim2) {
                        return Align(
                            alignment: Alignment.center,
                            child: ConfirmationPopUp(
                              textString: i18.payment.CORE_AMOUNT_CONFIRMATION,
                              subTextString:
                                  '₹ ${fetchBill?.customAmountCtrl.text}',
                              cancelLabel: i18.common.CORE_GO_BACK,
                              confirmLabel: i18.common.CORE_CONFIRM,
                              onConfirm: () => paymentInfo(fetchBill!, context),
                            ));
                      },
                    ))),
      ),
    ));
  }

  Widget _buildView(FetchBill fetchBill) {
    return SingleChildScrollView(
      child: FormWrapper(Form(
        key: formKey,
        autovalidateMode: autoValidation
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeBack(),
              LayoutBuilder(
                builder: (_, constraints) => Column(
                  children: [
                    _buildCoonectionDetails(fetchBill, constraints),
                    _buildPaymentDetails(fetchBill, constraints)
                  ],
                ),
              )
            ]),
      )),
    );
  }

  Widget _buildCoonectionDetails(
      FetchBill fetchBill, BoxConstraints constraints) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Card(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabelValue(
                        i18.common.CONNECTION_ID, '${fetchBill.consumerCode}'),
                    _buildLabelValue(
                        i18.common.CONSUMER_NAME, '${fetchBill.payerName}'),
                  ]))),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Consumer<CollectPaymentProvider>(
              builder: (_, consumerPaymentProvider, child) => Visibility(
                  visible: fetchBill.viewDetails,
                  child: _buildViewDetails(fetchBill)),
            ),
            _buildLabelValue(
                i18.common.TOTAL_DUE_AMOUNT,
                '₹ ${(fetchBill.totalAmount ?? 0) >= 0 ? fetchBill.totalAmount : 0}',
                FontWeight.w700),
            Consumer<CollectPaymentProvider>(
              builder: (_, consumerPaymentProvider, child) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: InkWell(
                  onTap: () => Provider.of<CollectPaymentProvider>(context,
                          listen: false)
                      .onClickOfViewOrHideDetails(fetchBill, context),
                  child: Text(
                    fetchBill.viewDetails
                        ? '${ApplicationLocalizations.of(context).translate(i18.payment.HIDE_DETAILS)}'
                        : '${ApplicationLocalizations.of(context).translate(i18.payment.VIEW_DETAILS)}',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            )
          ]),
        ),
      )
    ]);
  }

  Widget _buildPaymentDetails(FetchBill fetchBill, BoxConstraints constraints) {
    return Consumer<CollectPaymentProvider>(
      builder: (_, consumerPaymentProvider, child) => Card(
          child: Wrap(
        children: [
          ForceFocusWatcher(
              child: BuildTextField(
            i18.common.PAYMENT_AMOUNT,
            fetchBill.customAmountCtrl,
            textInputType: TextInputType.number,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
            ],
            validator: (val) => Validators.partialAmountValidatior(val, 10000),
            prefixText: '₹ ',
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${ApplicationLocalizations.of(context).translate(i18.payment.CORE_CHANGE_THE_AMOUNT)}',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
          RadioButtonFieldBuilder(
              context,
              i18.common.PAYMENT_METHOD,
              fetchBill.paymentMethod,
              '',
              '',
              true,
              consumerPaymentProvider.paymentModeList,
              (val) => consumerPaymentProvider.onChangeOfPaymentAmountOrMethod(
                  fetchBill, val))
        ],
      )),
    );
  }

  Widget _buildViewDetails(FetchBill fetchBill) {
    var penalty = widget.query['status'] != Constants.CONNECTION_STATUS.first
        ? CommonProvider.getPenalty(fetchBill.updateDemandList ?? [])
        : Penalty(0.0, '0', false);
    var isFirstDemand =
        CommonProvider.isFirstDemand(fetchBill.demandList ?? []);
    List res = [];
    if (fetchBill.billDetails!.isNotEmpty)
      fetchBill.billDetails?.forEach((element) {
        if (element.amount != 0) res.add(element.amount);
      });
    return LayoutBuilder(
      builder: (_, constraints) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              subTitle(i18.payment.BILL_DETAILS),
              _buildLabelValue(i18.common.BILL_ID, '${fetchBill.billNumber}'),
              _buildLabelValue(i18.payment.BILL_PERIOD,
                  '${DateFormats.timeStampToDate(fetchBill.billDetails?.first.fromPeriod)} - ${DateFormats.timeStampToDate(fetchBill.billDetails?.first.toPeriod)}'),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                !isFirstDemand
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            if (CommonProvider.getPenaltyOrAdvanceStatus(
                                    fetchBill.mdmsData, false) &&
                                !isFirstDemand &&
                                fetchBill.demandList?.first.demandDetails?.first
                                        .taxHeadMasterCode !=
                                    '10201' &&
                                fetchBill.demands?.demandDetails?.any((e) =>
                                        e.taxHeadMasterCode == '10201') ==
                                    true)
                              _buildLabelValue(i18.billDetails.WS_10201,
                                  '₹ ${CommonProvider.getNormalPenalty(fetchBill.demandList ?? [])}'),
                            _buildLabelValue(
                                fetchBill.demands?.demandDetails?.first
                                            .taxHeadMasterCode ==
                                        'WS_TIME_PENALTY'
                                    ? i18.billDetails.WS_10102
                                    : 'WS_${fetchBill.demands?.demandDetails?.first.taxHeadMasterCode}',
                                fetchBill.demandList?.first.demandDetails?.first
                                            .taxHeadMasterCode ==
                                        '10201'
                                    ? '₹ ${CommonProvider.getNormalPenalty(fetchBill.demandList ?? [])}'
                                    : '₹ ${CommonProvider.getArrearsAmount(fetchBill.demandList ?? [])}'),
                            if (!isFirstDemand &&
                                fetchBill.demands?.demandDetails?.first
                                        .taxHeadMasterCode ==
                                    'WS_TIME_PENALTY')
                              _buildLabelValue(i18.billDetails.WS_10201,
                                  '₹ ${CommonProvider.getPenaltyApplicable(fetchBill.demandList ?? []).penaltyApplicable}'),
                            if (fetchBill.demandList?.first.demandDetails?.first
                                        .taxHeadMasterCode ==
                                    '10201' &&
                                fetchBill.demandList?.first.demandDetails?.last
                                        .taxHeadMasterCode ==
                                    '10102')
                              _buildLabelValue(
                                  'WS_${fetchBill.demands?.demandDetails?.last.taxHeadMasterCode}',
                                  '₹ ${((fetchBill.demands?.demandDetails?.last.taxAmount ?? 0) - (fetchBill.demands?.demandDetails?.last.collectionAmount ?? 0)).toString()}')
                          ])
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            _buildLabelValue(
                                fetchBill.demands?.demandDetails?.first
                                            .taxHeadMasterCode ==
                                        'WS_TIME_PENALTY'
                                    ? i18.billDetails.CURRENT_BILL
                                    : 'WS_${fetchBill.demands?.demandDetails?.first.taxHeadMasterCode}',
                                fetchBill.demands?.demandDetails?.first
                                            .taxHeadMasterCode ==
                                        'WS_TIME_PENALTY'
                                    ? '₹' +
                                        CommonProvider.getCurrentBill(
                                                fetchBill.demandList ?? [])
                                            .toString()
                                    : CommonProvider.checkAdvance(
                                            fetchBill.demandList ?? [])
                                        ? '₹ ${((fetchBill.demands?.demandDetails?.first.taxAmount ?? 0))}'
                                        : '₹ ${((fetchBill.demands?.demandDetails?.first.taxAmount ?? 0) - (fetchBill.demands?.demandDetails?.first.collectionAmount ?? 0))}'),
                            (fetchBill.billDetails?.first.billAccountDetails
                                            ?.last.arrearsAmount ??
                                        0) >
                                    0
                                ? _buildLabelValue(
                                    i18.billDetails.ARRERS_DUES,
                                    fetchBill.demands?.demandDetails?.first
                                                .taxHeadMasterCode ==
                                            'WS_TIME_PENALTY'
                                        ? '₹' +
                                            CommonProvider
                                                    .getArrearsAmountOncePenaltyExpires(
                                                        fetchBill.demandList ??
                                                            [])
                                                .toString()
                                        : '₹ ${fetchBill.billDetails?.first.billAccountDetails?.last.arrearsAmount.toString()}')
                                : SizedBox(
                                    height: 0,
                                  )
                          ]),
                // }),
                if (fetchBill.billDetails != null && res.length > 1)
                  _buildWaterCharges(fetchBill, constraints),
                _buildLabelValue(
                    i18.common.CORE_TOTAL_BILL_AMOUNT,
                    isFirstDemand &&
                            fetchBill.demands?.demandDetails?.first
                                    .taxHeadMasterCode ==
                                'WS_TIME_PENALTY'
                        ? '₹' +
                            (CommonProvider.getCurrentBill(
                                        fetchBill.demandList ?? []) +
                                    CommonProvider
                                        .getArrearsAmountOncePenaltyExpires(
                                            fetchBill.demandList ?? []))
                                .toString()
                        : '₹ ${fetchBill.billDetails?.first.billAccountDetails?.last.totalBillAmount}'),
                if (CommonProvider.getPenaltyOrAdvanceStatus(
                    fetchBill.mdmsData, true))
                  _buildLabelValue(
                      i18.common.CORE_ADVANCE_ADJUSTED,
                      (fetchBill.billDetails?.first.billAccountDetails?.last
                                  .advanceAdjustedAmount !=
                              0.0
                          ? '- ₹ ' +
                              '${(fetchBill.billDetails?.first.billAccountDetails?.last.advanceAdjustedAmount)}'
                          : '₹ ' +
                              '${(fetchBill.billDetails?.first.billAccountDetails?.last.advanceAdjustedAmount)}')),
                if (CommonProvider.getPenaltyOrAdvanceStatus(
                        fetchBill.mdmsData, false, true) &&
                    isFirstDemand &&
                    penalty.isDueDateCrossed)
                  _buildLabelValue(
                      i18.billDetails.CORE_PENALTY,
                      '₹' +
                          (CommonProvider.getPenaltyApplicable(
                                      fetchBill.demandList)
                                  .penaltyApplicable)
                              .toString()),
                if (CommonProvider.getPenaltyOrAdvanceStatus(
                    fetchBill.mdmsData, true))
                  _buildLabelValue(i18.common.CORE_NET_AMOUNT_DUE,
                      '₹ ${CommonProvider.getNetDueAmountWithWithOutPenalty(fetchBill.totalAmount ?? 0, penalty)}'),
                if (CommonProvider.getPenaltyOrAdvanceStatus(
                        fetchBill.mdmsData, false, true) &&
                    isFirstDemand)
                  CustomDetailsCard(Column(
                    children: [
                      getLabelText(
                          i18.billDetails.CORE_PENALTY,
                          ('₹' +
                              (penalty.isDueDateCrossed
                                      ? CommonProvider.getPenaltyApplicable(
                                              fetchBill.demandList)
                                          .penaltyApplicable
                                      : penalty.penalty)
                                  .toString()),
                          context,
                          subLabel: NewConsumerBillState.getDueDatePenalty(
                              penalty.date, context)),
                      getLabelText(
                          i18.billDetails.CORE_NET_DUE_AMOUNT_WITH_PENALTY,
                          ('₹' +
                              (CommonProvider.getNetDueAmountWithWithOutPenalty(
                                          fetchBill.totalAmount ?? 0,
                                          penalty,
                                          true)
                                      .toString())
                                  .toString()),
                          context,
                          subLabel: NewConsumerBillState.getDueDatePenalty(
                              penalty.date, context))
                    ],
                  ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWaterCharges(FetchBill bill, BoxConstraints constraints) {
    return Container(
        padding: EdgeInsets.symmetric(
            vertical: 8, horizontal: constraints.maxWidth > 760 ? 20 : 0),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
        child: constraints.maxWidth > 760
            ? Column(
                children: List.generate(bill.billDetails?.length ?? 0, (index) {
                if (bill.billDetails?[index].billAccountDetails?.first
                        .taxHeadCode ==
                    'WS_ADVANCE_CARRYFORWARD') return Container();
                if (index != 0) {
                  return Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width / 3,
                          padding: EdgeInsets.only(top: 18, bottom: 3),
                          child: new Align(
                              alignment: Alignment.centerLeft,
                              child: _buildDemandDetails(
                                  bill, bill.billDetails![index]))),
                      Container(
                          width: MediaQuery.of(context).size.width / 2.5,
                          padding: EdgeInsets.only(top: 18, bottom: 3),
                          child: Text('₹ ${bill.billDetails![index].amount}')),
                    ],
                  );
                } else {
                  return SizedBox(
                    height: 0,
                  );
                }
              }))
            : Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: List.generate(bill.billDetails?.length ?? 0, (index) {
                  if (index == 0 ||
                      bill.billDetails?[index].billAccountDetails?.first
                              .taxHeadCode ==
                          'WS_ADVANCE_CARRYFORWARD') {
                    return TableRow(children: [
                      TableCell(child: Text("")),
                      TableCell(child: Text(""))
                    ]);
                  } else {
                    return TableRow(children: [
                      TableCell(
                          child: _buildDemandDetails(
                              bill, bill.billDetails![index])),
                      TableCell(
                          child: Text(
                        '₹ ${bill.billDetails![index].amount}',
                        textAlign: TextAlign.start,
                      ))
                    ]);
                  }
                }).toList()));
  }

  Widget _buildDemandDetails(
      FetchBill bill, billDetails.BillDetails? billdemandDetails) {
    var style = TextStyle(fontSize: 14, color: Color.fromRGBO(80, 90, 95, 1));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(
        direction: Axis.vertical,
        spacing: 3,
        children: [
          Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                  '${ApplicationLocalizations.of(context).translate('BL_${billdemandDetails?.billAccountDetails?.first.taxHeadCode}')}',
                  style: style)),
          Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text(
                  '${DateFormats.timeStampToDate(billdemandDetails?.fromPeriod)}-${DateFormats.timeStampToDate(billdemandDetails?.toPeriod)}',
                  style: style)),
        ],
      ),
    );
  }

  Widget _buildLabelValue(String label, String value,
      [FontWeight? fontWeight]) {
    return LayoutBuilder(
        builder: (_, constraints) => constraints.maxWidth > 760
            ? Row(
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width / 3,
                      padding: EdgeInsets.only(top: 18, bottom: 3),
                      child: new Align(
                          alignment: Alignment.centerLeft,
                          child: subTitle('$label', 16))),
                  Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      padding: EdgeInsets.only(top: 18, bottom: 3, left: 24),
                      child: Text('$value',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w400))),
                ],
              )
            : Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                    TableRow(children: [
                      TableCell(
                          child: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: subTitle('$label', 16))),
                      TableCell(
                          child: Text('$value',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400)))
                    ])
                  ]));
  }

  paymentInfo(FetchBill fetchBill, BuildContext context) {
    var consumerPaymentProvider =
        Provider.of<CollectPaymentProvider>(context, listen: false);
    if (formKey.currentState!.validate()) {
      autoValidation = false;
      consumerPaymentProvider.updatePaymentInformation(fetchBill, widget.query,context);
    } else {
      setState(() {
        autoValidation = true;
      });
    }
  }

  Text subTitle(String label, [double? size]) =>
      Text('${ApplicationLocalizations.of(context).translate(label)}',
          style: TextStyle(fontSize: size ?? 24, fontWeight: FontWeight.w700));
}
