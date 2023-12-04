import 'package:mgramseva/model/transaction/update_transaction.dart';
import 'package:mgramseva/services/urls.dart';

import '../model/bill/bill_payments.dart';
import '../services/base_service.dart';
import '../services/request_info.dart';
import '../utils/global_variables.dart';
import '../utils/models.dart';

class TransactionRepository extends BaseService {
  Future<UpdateTransactionDetails?> updateTransaction(
      Map<String, dynamic> queryparams) async {
    UpdateTransactionDetails? response;
    var res = await makeRequest(
        url: Url.UPDATE_TRANSACTION,
        method: RequestType.POST,
        body: {"RequestInfo": {}},
        queryParameters: queryparams);

    if (res != null) {
      response = UpdateTransactionDetails.fromJson(res);
    }
    return response;
  }

  Future<BillPayments?> createPayment(Map body) async {
    BillPayments? response;

    var res = await makeRequest(
        url: Url.COLLECT_PAYMENT,
        method: RequestType.POST,
        body: body,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            APIConstants.API_MESSAGE_ID,
            null));

    if (res != null) {
      response = BillPayments.fromJson(res);
    }
    return response;
  }
}
