
import 'package:flutter/material.dart';
import 'package:mgramseva/utils/global_variables.dart';

  class CustomOverlay {

  static showOverlay(BuildContext context, Widget widget){

    removeOverLay();
    overlayState = Overlay.of(context);

    overlayEntry = new OverlayEntry(
        builder: (BuildContext context) => widget);


    if (overlayEntry != null) overlayState?.insert(overlayEntry!);
  }

  static bool removeOverLay() {
    try {
      if (overlayEntry == null) return false;
      overlayEntry?.remove();
      return true;
    } catch (e) {
      return false;
    }
  }
}