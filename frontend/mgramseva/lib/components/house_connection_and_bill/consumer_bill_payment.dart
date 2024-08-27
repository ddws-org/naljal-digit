import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:mgramseva/model/bill/bill_payments.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/providers/bill_payments_provider.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_styles.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/print_bluetooth.dart';
import 'package:mgramseva/widgets/list_label_text.dart';
import 'package:number_to_words/number_to_words.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import './js_connnector.dart' as js;
import '../../utils/notifiers.dart';

class ConsumerBillPayments extends StatefulWidget {
  final WaterConnection? waterConnection;
  ConsumerBillPayments(this.waterConnection);
  @override
  State<StatefulWidget> createState() {
    return ConsumerBillPaymentsState();
  }
}

class ConsumerBillPaymentsState extends State<ConsumerBillPayments> {
  Uint8List? _imageFile;

  ScreenshotController screenshotController = ScreenshotController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  getPrinterLabel(key, value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            width: kIsWeb ? 150 : 80,
            child: Text(ApplicationLocalizations.of(context).translate(key),
                maxLines: 3,
                textScaleFactor: kIsWeb ? 2.5 : 1,
                textAlign: TextAlign.start,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: kIsWeb ? 5 : 9,
                    fontWeight: FontWeight.w400))),
        SizedBox(
          width: 5,
        ),
        Container(
            width: kIsWeb ? 215 : 110,
            child: Text(
              ApplicationLocalizations.of(navigatorKey.currentContext!)
                  .translate(value),
              maxLines: 3,
              textAlign: TextAlign.start,
              textScaleFactor: kIsWeb ? 2.5 : 1,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: kIsWeb ? 5 : 9,
                  fontWeight: FontWeight.w400),
            )),
      ],
    );
  }

  Future<Uint8List?> _capturePng(Payments item) async {
    item.paymentDetails!.last.bill!.billDetails
        ?.sort((a, b) => b.fromPeriod!.compareTo(a.fromPeriod!));

    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var stateProvider = Provider.of<LanguageProvider>(
        navigatorKey.currentContext!,
        listen: false);

    screenshotController
        .captureFromLongWidget(
          Container(
              width: kIsWeb ? 375 : 195,
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          kIsWeb
                              ? SizedBox(
                                  width: 70,
                                  height: 70,
                                )
                              : Image(
                                  width: 40,
                                  height: 40,
                                  color: Colors.black,
                                  image: NetworkImage(stateProvider
                                      .stateInfo!.stateLogoURL
                                      .toString())),
                          Container(
                            width: kIsWeb ? 290 : 90,
                            margin: EdgeInsets.all(5),
                            child: Text(
                              ApplicationLocalizations.of(
                                      navigatorKey.currentContext!)
                                  .translate(i18.consumerReciepts
                                      .GRAM_PANCHAYAT_WATER_SUPPLY_AND_SANITATION),
                              textScaleFactor: kIsWeb ? 3 : 1,
                              maxLines: 3,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                  height: 1,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FontStyle.italic),
                              textAlign: TextAlign.left,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Container(
                          width: kIsWeb ? 375 : 90,
                          margin: EdgeInsets.all(5),
                          child: Text(
                              ApplicationLocalizations.of(
                                      navigatorKey.currentContext!)
                                  .translate(i18.consumerReciepts.WATER_RECEIPT),
                              textScaleFactor: kIsWeb ? 3 : 1,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                height: 1,
                                fontWeight: FontWeight.bold,
                              ))),
                      SizedBox(
                        height: 8,
                      ),
                      getPrinterLabel(
                          i18.consumerReciepts.RECEIPT_GPWSC_NAME,
                          ApplicationLocalizations.of(navigatorKey.currentContext!)
                              .translate(commonProvider
                                  .userDetails!.selectedtenant!.code!)),
                      getPrinterLabel(i18.consumerReciepts.RECEIPT_CONSUMER_NO,
                          widget.waterConnection!.connectionNo),
                      getPrinterLabel(
                        i18.consumerReciepts.RECEIPT_CONSUMER_NAME,
                        widget.waterConnection!.connectionHolders!.first.name,
                      ),
                      getPrinterLabel(
                          i18.consumerReciepts.RECEIPT_CONSUMER_MOBILE_NO,
                          item.mobileNumber),
                      getPrinterLabel(
                          i18.consumerReciepts.RECEIPT_CONSUMER_ADDRESS,
                          ApplicationLocalizations.of(navigatorKey.currentContext!)
                                  .translate(widget.waterConnection!.additionalDetails!
                                      .doorNo
                                      .toString()) +
                              " " +
                              ApplicationLocalizations.of(navigatorKey.currentContext!)
                                  .translate(widget.waterConnection!.additionalDetails!
                                      .street
                                      .toString()) +
                              " " +
                              ApplicationLocalizations.of(navigatorKey.currentContext!)
                                  .translate(widget
                                      .waterConnection!.additionalDetails!.locality
                                      .toString()) +
                              " " +
                              ApplicationLocalizations.of(navigatorKey.currentContext!)
                                  .translate(commonProvider
                                      .userDetails!.selectedtenant!.code!)),
                      SizedBox(
                        height: 10,
                      ),
                      getPrinterLabel(i18.consumer.SERVICE_TYPE,
                          widget.waterConnection?.connectionType),
                      getPrinterLabel(i18.consumerReciepts.CONSUMER_RECEIPT_NO,
                          item.paymentDetails!.first.receiptNumber),
                      getPrinterLabel(
                          i18.consumerReciepts.RECEIPT_ISSUE_DATE,
                          DateFormats.timeStampToDate(item.transactionDate,
                                  format: "dd/MM/yyyy")
                              .toString()),
                      getPrinterLabel(
                          i18.consumerReciepts.RECEIPT_BILL_PERIOD,
                          DateFormats.timeStampToDate(
                                  item.paymentDetails?.last.bill!.billDetails!.first
                                      .fromPeriod,
                                  format: "dd/MM/yyyy") +
                              '-' +
                              DateFormats.timeStampToDate(
                                      item.paymentDetails?.last.bill?.billDetails!
                                          .first.toPeriod,
                                      format: "dd/MM/yyyy")
                                  .toString()),
                      SizedBox(
                        height: 8,
                      ),
                      getPrinterLabel(
                          i18.consumerReciepts.CONSUMER_ACTUAL_DUE_AMOUNT,
                          ('₹' + (item.totalDue).toString())),
                      getPrinterLabel(i18.consumerReciepts.RECEIPT_AMOUNT_PAID,
                          ('₹' + (item.totalAmountPaid).toString())),
                      getPrinterLabel(
                          i18.consumerReciepts.RECEIPT_AMOUNT_IN_WORDS,
                          ('Rupees ' +
                              (NumberToWord()
                                  .convert('en-in', item.totalAmountPaid!.toInt())
                                  .toString()) +
                              ' only')),
                      getPrinterLabel(
                          (item.totalDue ?? 0) - (item.totalAmountPaid ?? 0)>=0?i18.consumerReciepts.CONSUMER_PENDING_AMOUNT:i18.common.CORE_ADVANCE,
                          ('₹' +
                              ((item.totalDue ?? 0) - (item.totalAmountPaid ?? 0)).abs()
                                  .toString())),
                      SizedBox(
                        height: 8,
                      ),
                      Text('- - *** - -',
                          textScaleFactor: kIsWeb ? 3 : 1,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: kIsWeb ? 5 : 6,
                              fontWeight: FontWeight.bold)),
                      Text(
                          "${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.RECEIPT_FOOTER)}",
                          textScaleFactor: kIsWeb ? 3 : 1,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: kIsWeb ? 5 : 6,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              )),
      pixelRatio: 16/9
        )
        .then((value) => {
              kIsWeb
                  ? js.onButtonClick(
                      value, stateProvider.stateInfo!.stateLogoURL.toString())
                  : PrintBluetooth.printTicket(
                      value, navigatorKey.currentContext!)
            });
    return null;
  }

  afterViewBuild() {
    Provider.of<BillPaymentsProvider>(context, listen: false)
      ..FetchBillPayments(widget.waterConnection);
  }

  _getLabeltext(label, value, context) {
    return (Row(
      children: [
        Container(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            width: MediaQuery.of(context).size.width / 3,
            child: Padding(
              padding: EdgeInsets.only(right: 10),
              child: Text(
                ApplicationLocalizations.of(context).translate(label),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            )),
        Text(ApplicationLocalizations.of(context).translate(value),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400))
      ],
    ));
  }

  buildBillPaymentsView(BillPayments billpayments) {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
          padding: EdgeInsets.only(top: 16, bottom: 16),
          child: Column(children: [
            billpayments.payments!.length > 0
                ? ListLabelText(
                    i18.consumerReciepts.CONSUMER_BILL_RECIEPTS_LABEL)
                : Text(""),
            for (var item in billpayments.payments!)
              Card(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Visibility(
                              visible: true,
                              child: TextButton.icon(
                                onPressed: () => commonProvider
                                    .getFileFromPDFPaymentService({
                                  "Payments": [item]
                                }, {
                                  "key":
                                      widget.waterConnection?.connectionType ==
                                              'Metered'
                                          ? "ws-receipt"
                                          : "ws-receipt-nm",
                                  "tenantId": commonProvider
                                      .userDetails!.selectedtenant!.code,
                                }, item.mobileNumber, item, "Download"),
                                icon: Icon(Icons.download_sharp),
                                label: Text(
                                    ApplicationLocalizations.of(context)
                                        .translate(i18.common.RECEIPT_DOWNLOAD),
                                    style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            _getLabeltext(
                                i18.consumerReciepts.CONSUMER_RECEIPT_NO,
                                (item.paymentDetails!.first.receiptNumber)
                                    .toString(),
                                context),
                            _getLabeltext(
                                i18.consumerReciepts
                                    .CONSUMER_RECIEPT_PAID_AMOUNT,
                                ('₹' + (item.totalAmountPaid).toString()),
                                context),
                            _getLabeltext(
                                i18.consumerReciepts.CONSUMER_RECIEPT_PAID_DATE,
                                DateFormats.timeStampToDate(
                                        item.transactionDate,
                                        format: "dd/MM/yyyy")
                                    .toString(),
                                context),
                          ])),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(children: [
                      Container(
                        padding: EdgeInsets.only(left: 8),
                        width: constraints.maxWidth > 760
                            ? MediaQuery.of(context).size.width / 3
                            : MediaQuery.of(context).size.width / 2.2,
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              commonProvider.getFileFromPDFPaymentService({
                            "Payments": [item]
                          }, {
                            "key": widget.waterConnection?.connectionType ==
                                    'Metered'
                                ? "ws-receipt"
                                : "ws-receipt-nm",
                            "tenantId": commonProvider
                                .userDetails!.selectedtenant!.code,
                          }, item.mobileNumber, item, "Share"),
                          style: ElevatedButton.styleFrom(padding:EdgeInsets.symmetric(vertical: 8),alignment: Alignment.center,side:BorderSide(
                              width: 1,
                              color: Theme.of(context).disabledColor)),
                          icon: (Image.asset('assets/png/whats_app.png')),
                          label: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Text(
                              ApplicationLocalizations.of(context).translate(i18
                                  .consumerReciepts
                                  .CONSUMER_RECIEPT_SHARE_RECEIPT),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: CommonStyles.buttonBottomDecoration,
                        width: constraints.maxWidth > 760
                            ? MediaQuery.of(context).size.width / 3
                            : MediaQuery.of(context).size.width / 2.2,
                        child: ElevatedButton.icon(
                            onPressed: () => _capturePng(item),
                            icon: Icon(Icons.print,color: Colors.white,),
                            style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(244, 119, 56, 1)),
                            label: Text(
                                ApplicationLocalizations.of(context).translate(
                                    i18.consumerReciepts
                                        .CONSUMER_RECEIPT_PRINT),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .apply(color: Colors.white))),
                      ),
                    ]),
                  )
                ],
              ))
          ]));
    });
  }

  @override
  Widget build(BuildContext context) {
    var billpaymentsProvider =
        Provider.of<BillPaymentsProvider>(context, listen: false);
    return StreamBuilder(
        stream: billpaymentsProvider.streamController.stream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return buildBillPaymentsView(snapshot.data);
          } else if (snapshot.hasError) {
            return Notifiers.networkErrorPage(context, () {});
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
        });
  }
}
