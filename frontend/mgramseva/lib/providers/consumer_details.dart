import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/connection/house_connection.dart';

class ConsumerProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();

  dispose() {
    streamController.close();
    super.dispose();
  }

  Future<void> getConsumerDetails() async {
    try {
      streamController.add(HouseConnection());
    } catch (e) {
      streamController.addError('error');
    }
  }
}
