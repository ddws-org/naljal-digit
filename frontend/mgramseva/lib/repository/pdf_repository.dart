import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:mgramseva/model/bill/bill_payments.dart';
import 'package:mgramseva/model/bill/billing.dart';
import 'package:mgramseva/model/common/pdf_service.dart';
import 'package:mgramseva/model/demand/demand_list.dart';
import 'package:mgramseva/model/demand/update_demand_list.dart';
import 'package:mgramseva/model/file/file_store.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/services/base_service.dart';
import 'package:mgramseva/services/request_info.dart';
import 'package:mgramseva/services/urls.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

class PDFServiceRepository extends BaseService {
  getRequestInfo(CRITERIA) {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    return RequestInfo(
        APIConstants.API_MODULE_NAME,
        APIConstants.API_VERSION,
        APIConstants.API_TS,
        CRITERIA,
        APIConstants.API_DID,
        APIConstants.API_KEY,
        APIConstants.API_MESSAGE_ID,
        commonProvider.userDetails?.accessToken,
        commonProvider.userDetails?.userRequest?.toJson());
  }

  Future<PDFServiceResponse?> CreatePDF(
      body, Map<String, dynamic> params) async {
    late PDFServiceResponse billPaymentpdf;

    var res = await makeRequest(
        url: Url.FETCH_FILESTORE_ID_PDF_SERVICE,
        body: {"BillAndDemand": body},
        queryParameters: params,
        requestInfo: RequestInfo(
            APIConstants.API_MODULE_NAME,
            APIConstants.API_VERSION,
            APIConstants.API_TS,
            "_create",
            APIConstants.API_DID,
            APIConstants.API_KEY,
            "string|" + 'en_IN',
            ""),
        method: RequestType.POST);
    if (res != null) {
      billPaymentpdf = PDFServiceResponse.fromJson(res);
    }
    return billPaymentpdf;
  }
}
