
import 'package:flutter/material.dart';
import 'package:mgramseva/utils/color_codes.dart';

class CommonStyles {

  static BoxDecoration get buttonBottomDecoration => const BoxDecoration(
      border: Border(bottom: BorderSide(color: ColorCodes.BUTTON_BOTTOM, width: 2))
  );

  static TextStyle get hintStyle => TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: ColorCodes.TEXT_HINT);
}