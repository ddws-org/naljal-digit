import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:mgramseva/model/bill/billing.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/repository/billing_service_repo.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';

class FetchBillProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();
  late GlobalKey<FormState> formKey;

  // ignore: non_constant_identifier_names
  Future<BillList> fetchBill(data, BuildContext context) async {
    BillList billList = new BillList();
    try {
      var res = await BillingServiceRepository().fetchBill({
        "tenantId": data.tenantId,
        "consumerCode": data.connectionNo.toString(),
        "businessService": "WS"
      });
      if (res.bill!.isNotEmpty) {
        res.bill?.first.billDetails
            ?.sort((a, b) => b.fromPeriod!.compareTo(a.fromPeriod!));
        billList = res;
        streamController.add(res);
      } else {
         billList = new BillList();
        billList.bill = [];
        streamController.add(billList);
      }
        } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
    }
    return billList;
  }

  // ignore: non_constant_identifier_names
  Future<void> FetchBillwithoutLogin(Map data) async {
    try {
      var input = {
        "tenantId": data['tenantId'],
        "consumerCode": data['consumerCode'],
        "service": "WS",
        "billNumber": data['billNumber']
      };

      await BillingServiceRepository()
          .fetchBillwithoutLogin(input)
          .then((res) async {
        var prams = {
          "key": data['key'] != null ? data['key'] : "ws-bill",
          "tenantId": data['tenantId']
        };
        var body = {"Bill": res.bill};
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
