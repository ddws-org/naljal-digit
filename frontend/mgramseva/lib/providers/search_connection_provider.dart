import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mgramseva/model/connection/search_connection.dart';
import 'package:mgramseva/model/connection/water_connections.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/repository/search_connection_repo.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:provider/provider.dart';

class SearchConnectionProvider with ChangeNotifier {
  WaterConnections? waterConnections;
  final formKey = GlobalKey<FormState>();
  var autoValidation = false;
  var streamController = StreamController.broadcast();
  SearchConnection searchconnection = SearchConnection();

  dispose() {
    streamController.close();
    super.dispose();
  }

  getdetails(value, controller) {
    if (value.length == 0) {
      for (var i = 0; i < searchconnection.controllers.length; i++) {
        searchconnection.controllers[i] = false;
      }
    } else {
      for (var i = 0; i < searchconnection.controllers.length; i++) {
        searchconnection.controllers[i] = true;
      }

      searchconnection.controllers[controller] = false;
    }
    print(searchconnection.controllers);
    notifyListeners();
  }

  void callNotifyer() {
    notifyListeners();
  }

  getresults() {
    return streamController.add(waterConnections);
  }

  void validatesearchConnectionDetails(context, arguments, isNameSearch) async {
    FocusScope.of(context).unfocus();
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    if (formKey.currentState!.validate()) {
      searchconnection.setValues();
      try {
        Loaders.showLoadingDialog(context);
        var inputJson = searchconnection.toJson();
        inputJson.removeWhere((key, value) => value == "");
        var connectionresults = isNameSearch == true
            ? SearchConnectionRepository().getConnectionName({
                "tenantId": commonProvider.userDetails!.selectedtenant!.code,
                ...inputJson
              })
            : SearchConnectionRepository().getconnection({
                "tenantId": commonProvider.userDetails!.selectedtenant!.code,
                ...inputJson
              });

        /// popping the loader
        connectionresults.then(
            (value) => {
                  Navigator.pop(context),
                  if (value.waterConnectionData!.length > 0 ||
                      value.waterConnection!.length > 0)
                    {
                      waterConnections = value,
                      Navigator.pushNamed(
                          context, Routes.SEARCH_CONSUMER_RESULT, arguments: {
                        ...inputJson,
                        ...arguments,
                        "isNameSearch": isNameSearch
                      })
                    }
                  else
                    {
                      Notifiers.getToastMessage(
                          context,
                          i18.searchWaterConnection.NO_CONNECTION_FOUND,
                          "ERROR")
                    }
                }, onError: (e, s) {
          Navigator.pop(context);
          ErrorHandler().allExceptionsHandler(context, e, s);
        });
      } catch (e, s) {
        Navigator.pop(context);
        ErrorHandler().allExceptionsHandler(context, e, s);
      }
    } else {
      autoValidation = true;
    }
  }

  void fetchNonDemandGeneratedConnectionDetails(
      context, String previousMeterReading) async {
    FocusScope.of(context).unfocus();
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    try {
      Loaders.showLoadingDialog(context);
      Map<String, dynamic> query = {
        'previousMeterReading': previousMeterReading.toString(),
        'tenantId': commonProvider.userDetails?.selectedtenant?.code
      };
      var arguments ={"Mode": "update"};
      var connectionresults =
          SearchConnectionRepository().getNonDemandGeneratedWC(query);
      // popping the loader
      connectionresults.then(
          (value) => {
                Navigator.pop(context),
                if (value.waterConnectionData!.length > 0 ||
                    value.waterConnection!.length > 0)
                  {
                    waterConnections = value,
                    Navigator.pushNamed(context, Routes.SEARCH_CONSUMER_RESULT,
                        arguments: {
                          ...query,
                          ...arguments,
                          "isNameSearch": false
                        })
                  }
                else
                  {
                    Notifiers.getToastMessage(context,
                        i18.searchWaterConnection.NO_CONNECTION_FOUND, "ERROR")
                  }
              }, onError: (e, s) {
        Navigator.pop(context);
        ErrorHandler().allExceptionsHandler(context, e, s);
      });
    } catch (e, s) {
      Navigator.pop(context);
      ErrorHandler().allExceptionsHandler(context, e, s);
    }
  }
}
