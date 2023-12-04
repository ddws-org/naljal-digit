import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/events/events_List.dart';
import 'package:mgramseva/repository/core_repo.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';

import 'common_provider.dart';

///Notification Screen Provider
class NotificationScreenProvider with ChangeNotifier {
  var enableNotification = false;
  var streamController = StreamController.broadcast();
  int offset = 1;
  int limit = 10;
  List<Events> notifications = [];
  var totalCount = 0;

  ///Notification Screen
  void getNotifications(int offSet, int limit) async {
    this.limit = limit;
    this.offset = offSet;
    notifyListeners();
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    if (notifications.length > 0) {
      final jsonList = notifications.map((item) => jsonEncode(item)).toList();
      final uniqueJsonList = jsonList.toSet().toList();
      var result = new EventsList.fromJson(
          {"events": uniqueJsonList.map((item) => jsonDecode(item)).toList()});
      if (((offSet + limit) > totalCount ? totalCount : (offSet + limit)) <=
          (result.events!.length)) {
        streamController.add(result.events!.sublist(
            offSet - 1,
            ((offset + limit) - 1) > totalCount
                ? totalCount
                : (offset + limit) - 1));
        return;
      }
    }
    streamController.add(null);

    enableNotification = true;
    notifyListeners();
    try {
      var notifications1 = await CoreRepository().fetchNotifications({
        "tenantId": commonProvider.userDetails?.selectedtenant?.code!,
        "eventType": "SYSTEMGENERATED",
        "recepients": commonProvider.userDetails?.userRequest?.uuid,
        "status": "READ,ACTIVE",
        "offset": '${offset - 1}',
        "limit": '$limit'
      });
      var notifications2 = await CoreRepository().fetchNotifications({
        "tenantId": commonProvider.userDetails?.selectedtenant?.code!,
        "eventType": "SYSTEMGENERATED",
        "roles": commonProvider.uniqueRolesList()?.join(',').toString(),
        "status": "READ,ACTIVE",
        "offset": '${offset - 1}',
        "limit": '$limit'
      });
      notifications
        ..addAll(notifications2!.events!)
        ..addAll(notifications1!.events!);
      enableNotification = false;
      totalCount = (notifications1.totalCount!.toInt() >
                  notifications2.totalCount!.toInt()
              ? notifications1.totalCount
              : notifications2.totalCount) ??
          0;
      notifyListeners();

      final list = notifications.map((item) => jsonEncode(item)).toList();
      final uniqueList = list.toSet().toList();
      var res = new EventsList.fromJson(
          {"events": uniqueList.map((item) => jsonDecode(item)).toList()});
      streamController.add(res.events!.sublist(
          offSet - 1,
          ((offset + limit) - 1) > totalCount
              ? totalCount
              : (offset + limit) - 1));
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
    }
  }

  void onChangeOfPageLimit(PaginationResponse response) {
    if (enableNotification) return;
    try {
      getNotifications(response.offset, response.limit);
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
