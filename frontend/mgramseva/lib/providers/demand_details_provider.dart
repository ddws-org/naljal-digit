import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/model/demand/demand_list.dart';
import 'package:mgramseva/repository/bill_generation_details_repo.dart';
import 'package:mgramseva/repository/billing_service_repo.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';

class DemandDetailProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();
  late GlobalKey<FormState> formKey;
  bool isFirstDemand = false;

  // ignore: non_constant_identifier_names
  Future<void> fetchDemandDetails(data) async {
    try {
      await BillingServiceRepository().fetchdDemand({
        "tenantId": data.tenantId,
        "consumerCode": data.connectionNo.toString(),
        "businessService": "WS",
        // "status": "ACTIVE"
      }).then((value) {
        if (value.demands!.length > 0) {
          value.demands = value.demands?.where((element) => element.status != 'CANCELLED').toList();

          value.demands!.sort((a, b) => b
              .demandDetails!.first.auditDetails!.createdTime!
              .compareTo(a.demandDetails!.first.auditDetails!.createdTime!));
          if (value.demands?.isEmpty == true) {
            isFirstDemand = false;
          } else if (value.demands?.length == 1 &&
              value.demands?.first.consumerType == 'waterConnection-arrears') {
            isFirstDemand = false;
          } else if(value.demands?.length == 1 && value.demands?.first.consumerType == 'waterConnection-advance' && value.demands?.first.demandDetails?.first.taxHeadMasterCode == 'WS_ADVANCE_CARRYFORWARD'){
            isFirstDemand = false;
          }
          else {
            checkMeterDemand(value, data);
            isFirstDemand = true;
          }
          streamController.add(value);
        } else {
          DemandList demandList = new DemandList();
          demandList.demands = [];
          streamController.add(demandList);
        }
      });
    } catch (e, s) {
      streamController.addError('error');
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
    }
  }

  Future<void> checkMeterDemand(
      DemandList demandList, WaterConnection waterConnection) async {
    if (demandList.demands!.isNotEmpty) {
      try {
        var res = await BillGenerateRepository().searchMeteredDemand({
          "tenantId": demandList.demands!.first.tenantId,
          "connectionNos": waterConnection.connectionNo
        });
        if (res.meterReadings!.isNotEmpty) {
          res.meterReadings!.sort((a, b) =>
              (b.currentReadingDate!).compareTo(a.currentReadingDate!));
          demandList.demands!.first.meterReadings = res.meterReadings;

          streamController.add(demandList);
        }
      } catch (e, s) {
        streamController.addError('error');
        ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      }
    } else {
      streamController.add(demandList);
    }
  }

  dispose() {
    streamController.close();
    super.dispose();
  }
}
