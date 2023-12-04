import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mgramseva/screeens/home/home_walk_through/home_walk_through_list.dart';
import 'package:mgramseva/utils/role_actions.dart';

class HomeProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();
  late List<HomeWalkWidgets> homeWalkthroughList;
  int activeIndex = 0;

  void setWalkThrough(value) {
    homeWalkthroughList = value
        .where((element) => RoleActionsFiltering()
            .getFilteredModules()
            .where((ele) => ele.label == element.label)
            .isNotEmpty)
        .toList();
  }

  incrementIndex(index, homeKey) async {
    activeIndex = index + 1;
    await Scrollable.ensureVisible(homeKey.currentContext!,
        duration: new Duration(milliseconds: 100));
  }

  dispose() {
    streamController.close();
    super.dispose();
  }

  void updateWalkThrough(value) {
    homeWalkthroughList = value;
  }
}
