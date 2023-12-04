import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/transaction/update_transaction.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/error_logging.dart';

import '../repository/billing_service_repo.dart';
import '../repository/transaction_repo.dart';
import '../utils/localization/application_localizations.dart';
import '../utils/global_variables.dart';
import 'common_provider.dart';

class TransactionUpdateProvider with ChangeNotifier {
  var transactionController = StreamController.broadcast();
  var isPaymentSuccess = false;

  @override
  void dispose() {
    transactionController.close();
    super.dispose();
  }

  Future<void> updateTransaction(Map query, BuildContext context) async {
    UpdateTransactionDetails? transactionDetails;
    try {
      transactionDetails = await TransactionRepository()
          .updateTransaction({"transactionId": query['eg_pg_txnid']});
      if (transactionDetails != null &&
          transactionDetails.transaction != null) {
        isPaymentSuccess = true;
        transactionController.add(transactionDetails);
        notifyListeners();
      }
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(context, e, s);
      transactionController.addError('error');
    }
  }

  Future<void> downloadOrShareReceiptWithoutLogin(BuildContext context,
      UpdateTransactionDetails transactionObj, bool isWhatsAppShare) async {
    String whatsappText =
        '${ApplicationLocalizations.of(context).translate(i18.payment.SHARE_TRANSACTION_RECEIPT)}';
    whatsappText = whatsappText.replaceAll(
        '{user}', transactionObj.transaction!.first.user!.name.toString());
    whatsappText = whatsappText.replaceAll(
        '{Amount}', transactionObj.transaction!.first.txnAmount.toString());
    whatsappText = whatsappText.replaceAll('{new consumer id}',
        transactionObj.transaction!.first.consumerCode.toString());
    whatsappText = whatsappText.replaceAll(
        '{transactionId}', transactionObj.transaction!.first.txnId.toString());

    try {
      var input = {
        "tenantId": transactionObj.transaction!.first.tenantId,
        "consumerCode": transactionObj.transaction!.first.consumerCode,
        "businessService": "WS",
      };

      await BillingServiceRepository()
          .fetchdBillPaymentsNoAuth(input)
          .then((res) async {
        var params = {
          "key": transactionObj.transaction?.first.additionalDetails?.connectionType!="non-metered"? "ws-receipt":"ws-receipt-nm",
          "tenantId": transactionObj.transaction!.first.tenantId
        };
        var body = {
          "Payments": [res.payments!.first]
        };
        await BillingServiceRepository()
            .fetchdfilestordIDNoAuth(body, params)
            .then((value) async {
          var output = await BillingServiceRepository().fetchFiles(
              value!.filestoreIds!.sublist(0, 1),
              transactionObj.transaction!.first.tenantId.toString());
          isWhatsAppShare
              ? CommonProvider().shareonwatsapp(
                  output!.first,
                  transactionObj.transaction!.first.user!.mobileNumber,
                  whatsappText)
              : CommonProvider().onTapOfAttachment(
                  output!.first, navigatorKey.currentContext);
        });
      });
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      transactionController.addError('error');
    }
  }

  void callNotifier() {
    notifyListeners();
  }
}
