import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/events/events_List.dart';

import 'package:mgramseva/repository/core_repo.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';


///Home Screen Notification Provider
class NotificationProvider with ChangeNotifier {
  var enableNotification = false;
  var streamController = StreamController.broadcast();

  ///Home Screen
  void getNotiications(query1, query2) async {
    try {
      var notifications1 = await CoreRepository().fetchNotifications(query1);
      var notifications2 = await CoreRepository().fetchNotifications(query2);
      List<Events> res = []
        ..addAll(notifications2!.events!)
        ..addAll(notifications1!.events!);
      if (res.length > 0) {
        final jsonList = res.map((item) => jsonEncode(item)).toList();
        final uniqueJsonList = jsonList.toSet().toList();
        var result = EventsList.fromJson({
          "events": uniqueJsonList.map((item) => jsonDecode(item)).toList()
        });
        streamController.add(result.events);
        enableNotification = true;
      } else {
        streamController.add(res);
      }
    } catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
    }
  }


  void updateNotify(item , events) async{
    item.status = "READ";
    try {
      var res = await CoreRepository().updateNotifications({
        "events": [item]
      });
      if(res != null) {
        events.remove(item);
        streamController.add(events);
        notifyListeners();

      }
    }
    catch (e, s) {
      ErrorHandler().allExceptionsHandler(navigatorKey.currentContext!, e, s);
      streamController.addError('error');
    }
  }


  dispose() {
    streamController.close();
    super.dispose();
  }
}
