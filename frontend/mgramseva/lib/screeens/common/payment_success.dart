import 'package:flutter/material.dart';
import 'package:mgramseva/model/transaction/update_transaction.dart';
import 'package:mgramseva/model/success_handler.dart';
import 'package:mgramseva/providers/transaction_update_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/widgets/no_login_success_page.dart';
import 'package:provider/provider.dart';

import '../../model/localization/language.dart';
import '../../providers/language.dart';
import '../../routers/routers.dart';
import '../../utils/localization/application_localizations.dart';
import '../../utils/loaders.dart';
import '../../utils/notifiers.dart';
import '../../widgets/no_login_failure_page.dart';

class PaymentSuccess extends StatefulWidget {
  final Map<String, dynamic> query;

  PaymentSuccess({Key? key, required this.query});
  @override
  State<StatefulWidget> createState() {
    return _PaymentSuccessState();
  }
}

class _PaymentSuccessState extends State<PaymentSuccess> {
  List<StateInfo>? stateList;
  Languages? selectedLanguage;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  afterViewBuild() async {
    var transactionUpdateProvider =
        Provider.of<TransactionUpdateProvider>(context, listen: false);
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider
        .getLocalizationData(context)
        .then((value) => callNotifyer());
    await transactionUpdateProvider
        .updateTransaction(widget.query, context)
        .then((value) => callNotifyer());
  }

  @override
  Widget build(BuildContext context) {
    var transactionProvider =
        Provider.of<TransactionUpdateProvider>(context, listen: false);
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    UpdateTransactionDetails? transactionDetails;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('mGramSeva'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
          stream: languageProvider.streamController.stream,
          builder: (context, AsyncSnapshot languageSnapshot) {
            if (languageSnapshot.hasData) {
              var stateData = languageSnapshot.data as List<StateInfo>;
              stateList = stateData;
              var index = stateData.first.languages
                  ?.indexWhere((element) => element.isSelected);
              if (index != null && index != -1) {
                selectedLanguage = stateData.first.languages?[index];
              } else {
                selectedLanguage = stateData.first.languages?.first;
              }
              return StreamBuilder(
                  stream: transactionProvider.transactionController.stream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      transactionDetails = snapshot.data;
                      return _buildPaymentSuccessPage(snapshot.data, context);
                    } else if (snapshot.hasError) {
                      return Notifiers.networkErrorPage(
                          context,
                          () => transactionProvider.updateTransaction(
                              widget.query, context));
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
            } else if (languageSnapshot.hasError) {
              return Notifiers.networkErrorPage(
                  context, () => languageProvider.getLocalizationData(context));
            } else {
              switch (languageSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return Loaders.circularLoader();
                case ConnectionState.active:
                  return Loaders.circularLoader();
                default:
                  return Container();
              }
            }
          }),
    );
  }

  Widget _buildPaymentSuccessPage(
      UpdateTransactionDetails transactionObject, BuildContext context) {
    var transactionProvider =
        Provider.of<TransactionUpdateProvider>(context, listen: false);
    return transactionObject.transaction?.first.txnStatus != "FAILURE"
        ? NoLoginSuccess(
            SuccessHandler(
              i18.common.PAYMENT_COMPLETE,
              '${ApplicationLocalizations.of(context).translate(i18.payment.RECEIPT_REFERENCE_WITH_MOBILE_NUMBER)} (+91 ${transactionObject.transaction?.first.user?.mobileNumber})',
              '',
              Routes.PAYMENT_SUCCESS,
              subHeader:
                  '${ApplicationLocalizations.of(context).translate(i18.payment.TRANSACTION_ID)} \n ${widget.query['eg_pg_txnid']}',
              downloadLink: i18.common.RECEIPT_DOWNLOAD,
              whatsAppShare: i18.common.SHARE_RECEIPTS,
              downloadLinkLabel: i18.common.RECEIPT_DOWNLOAD,
              subtitleFun: () => getSubtitleDynamicLocalization(
                  context,
                  transactionObject.transaction!.first.user!.mobileNumber
                      .toString()),
            ),
            callBackDownload: () =>
                transactionProvider.downloadOrShareReceiptWithoutLogin(
                    context, transactionObject, false),
            callBackWhatsApp: () =>
                transactionProvider.downloadOrShareReceiptWithoutLogin(
                    context, transactionObject, true),
            backButton: false,
            isWithoutLogin: true,
            isConsumer: true,
            amount: '${transactionObject.transaction!.first.txnAmount! ?? '0'}',
          )
        : NoLoginFailurePage(i18.payment.PAYMENT_FAILED);
  }

  callNotifyer() async {
    await Future.delayed(Duration(seconds: 2));
  }

  Widget _buildDropDown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: DropdownButton(
          value: selectedLanguage != null
              ? selectedLanguage
              : Languages(label: 'ENGLISH', value: 'en_IN', isSelected: true),
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
          items: dropDownItems,
          onChanged: onChangeOfLanguage),
    );
  }

  get dropDownItems {
    return stateList?.first.languages!.map((value) {
      return DropdownMenuItem(
        value: value,
        child: Text('${value.label}'),
      );
    }).toList();
  }

  void onChangeOfLanguage(value) {
    selectedLanguage = value;
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.onSelectionOfLanguage(
        value!, stateList?.first.languages ?? []);
  }

  String getSubtitleDynamicLocalization(
      BuildContext context, String mobileNumber) {
    String localizationText = '';
    localizationText =
        '${ApplicationLocalizations.of(context).translate(i18.payment.RECEIPT_REFERENCE_WITH_MOBILE_NUMBER)}';
    localizationText =
        localizationText.replaceFirst('{Number}', '(+91 - $mobileNumber)');
    return localizationText;
  }
}
