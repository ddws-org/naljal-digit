import 'package:flutter/material.dart';
import 'package:mgramseva/utils/color_codes.dart';

ThemeData get theme => ThemeData(
    highlightColor: createMaterialColor(Color(0XFFC7E0F1)),
    hintColor: createMaterialColor(Color(0XFF3498DB)),
    primaryColorDark: Color.fromRGBO(11, 12, 12, 1),
    primaryColorLight: Color.fromRGBO(80, 90, 95, 1),
    primaryColor: Color.fromRGBO(244, 119, 56, 1),
    disabledColor: Colors.grey,
    cardTheme: CardTheme(surfaceTintColor: Colors.white,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
    datePickerTheme: DatePickerThemeData(
      surfaceTintColor: Colors.white
    ),
    drawerTheme: DrawerThemeData(
      surfaceTintColor: Colors.white
    ),
    // accentColor:  Color(0xff0B4B66),

    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xff0B4B66),
      centerTitle: false,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, fontStyle: FontStyle.normal, color: Color.fromRGBO(11, 12, 12, 1)),
      displayMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
      labelLarge: TextStyle(fontWeight: FontWeight.w500, fontSize: 19, color: Colors.white), // Elevated Button(Orange)
      labelMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.white), // Elevated Button(Orange)
      labelSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 10, color: Colors.white), // Elevated Button(Orange)
      titleMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: 16),
      titleSmall: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Color.fromRGBO(244, 119, 56, 1)) // Only for outlined button text
    ),

    /// Background color
    scaffoldBackgroundColor: Color.fromRGBO(238, 238, 238, 1),

    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      textStyle: TextStyle(color: Colors.black, fontSize: 16),
      // padding: EdgeInsets.symmetric(vertical: 10),
    )),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            padding: EdgeInsets.symmetric(vertical: 15),
            textStyle: TextStyle(fontSize: 19, fontWeight: FontWeight.w500))),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      textStyle: TextStyle(
          color: Color(0XFFf47738), fontSize: 19, fontWeight: FontWeight.w500),
      padding: EdgeInsets.symmetric(vertical: 15),
    )),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.zero)),
      prefixStyle: TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Color.fromRGBO(80, 90, 95, 1)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.zero),
        borderSide: BorderSide(color: Color.fromRGBO(80, 90, 95, 1)),
      ),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.zero),
          borderSide: BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.zero),
          borderSide: BorderSide(color: Colors.red)),
      errorStyle: TextStyle(fontSize: 15),
      disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.zero),
          borderSide: BorderSide(color: Colors.grey)),
    ),
    iconTheme: IconThemeData(
      color: ColorCodes.HOME_ICON,
      // size: 25
    ), colorScheme: ColorScheme.fromSwatch(primarySwatch: createMaterialColor(Color(0XFFf47738))).copyWith(background: createMaterialColor(Color.fromRGBO(238, 238, 238, 1))));

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}
