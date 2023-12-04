import 'package:flutter/material.dart';
import 'package:mgramseva/utils/constants.dart';

var json = Constants.HOME_ITEMS
    .map(
      (e) => {
        "name": e.walkThroughMsg,
        "label": e.label,
        "icon": e.iconData,
      },
    )
    .toList();

class HomeWalkThrough {
  final List<HomeWalkWidgets> homeWalkThrough = json
      .map((e) => HomeWalkWidgets(
          name: e['name'] as String,
          label: (e['label']) as String,
          icon: (e['icon']) as IconData))
      .toList();
}

class HomeWalkWidgets {
  final String name;
  final String label;
  final IconData icon;
  bool isActive = false;
  GlobalKey? key;
  HomeWalkWidgets(
      {required this.name, required this.label, required this.icon});
}
