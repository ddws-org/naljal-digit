import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mgramseva/model/bill/bill_payments.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/repository/billing_service_repo.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';

class BillPaymentsProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();
  late GlobalKey<FormState> formKey;

  // ignore: non_constant_identifier_names
  Future<void> FetchBillPayments(data) async {
    var res = await BillingServiceRepository().fetchdBillPayments({
      "tenantId": data.tenantId,
      "consumerCodes": data.connectionNo.toString(),
      "businessService": "WS"
    }).then((value) {
      value.payments = value.payments
          ?.where((element) => element.paymentStatus != 'CANCELLED')
          .toList();
      if (value.payments != null && value.payments!.isNotEmpty) {
        streamController.add(value);
      } else {
        BillPayments paymentList = new BillPayments();
        paymentList.payments = [];
        streamController.add(paymentList);
      }
    });
  }

  // ignore: non_constant_identifier_names
  Future<void> FetchBillPaymentsWithoutLogin(Map data) async {
    try {
      var input = {
        "tenantId": data['tenantId'],
        "consumerCode": data['consumerCode'],
        "businessService": "WS",
        "receiptNumbers": data['receiptNumber']
      };

      await BillingServiceRepository()
          .fetchdBillPaymentsNoAuth(input)
          .then((res) async {
        var prams = {
          "key": data['key'] != null ? data['key'] : "ws-receipt",
          "tenantId": data['tenantId']
        };
        var body = {"Payments": res.payments};
        await BillingServiceRepository()
            .fetchdfilestordIDNoAuth(body, prams)
            .then((value) async {
          var output = await BillingServiceRepository()
              .fetchFiles(value!.filestoreIds!, data['tenantId']);
          CommonProvider()
            ..onTapOfAttachment(output!.first, navigatorKey.currentContext);
          // window.location.href = "https://www.google.com/";
        });
      });
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
    }
  }

  dispose() {
    streamController.close();
    super.dispose();
  }
}
