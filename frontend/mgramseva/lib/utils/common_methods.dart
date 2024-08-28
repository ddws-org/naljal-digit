import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/model/mdms/tax_period.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mime/mime.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';
import 'models.dart';

class CommonMethods {
  static home() {
    // navigatorKey.currentState?.popUntil((route) => route.isFirst);
    Navigator.pushNamedAndRemoveUntil(
  navigatorKey.currentContext!,
  Routes.HOME, // Replace with your initial route
  (Route<dynamic> route) => false,
);
  }

  static String getExtension(String url) {
    return url.substring(0, url.indexOf('?')).split('/').last;
  }

  static List<DatePeriod> getPastMonthUntilFinancialYear(int year,
      {DateType? dateType}) {
    var monthList = <DateTime>[];
    if (DateTime.now().year == year && DateTime.now().month >= 4) {
      for (int i = 4; i <= DateTime.now().month; i++) {
        monthList.add(DateTime(DateTime.now().year, i));
      }
    } else {
      var yearDetails = DateTime(year);
      for (int i = 4; i <= 12; i++) {
        monthList.add(DateTime(yearDetails.year, i));
      }
      for (int i = 1;
          i <= (dateType == DateType.YTD ? DateTime.now().month : 3);
          i++) {
        monthList.add(DateTime(yearDetails.year + 1, i));
      }
    }
    return monthList
        .map((e) => DatePeriod(DateTime(e.year, e.month, 1),
            DateTime(e.year, e.month + 1, 0, 23, 59, 59, 999), DateType.MONTH))
        .toList()
        .reversed
        .toList();
  }
/*
  * @author Rahul Dev Garg
  * rahul.dev@egovernments.org
  *
  * */
  static var daysInMonthLeap = [
    31,
    29,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];
  static var daysInMonth = [
    31,
    28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];
  static bool isLeapYear(int year) {
    if (year % 4 == 0) {
      if (year % 100 == 0) {
        if (year % 400 == 0) {
          return true;
        } else {
          return false;
        }
      } else {
        return true;
      }
    } else {
      return false;
    }
  }
  static int daysToSubtract(int monthCount, int year,int currentMonth) {
    int days = 0;
    for (int i = 0; i < monthCount; i++) {
      if (currentMonth - i < 0) {
        days += isLeapYear(year - 1)
            ? daysInMonthLeap[12 - (currentMonth - i).abs()]
            : daysInMonth[12 - (currentMonth - i).abs()];
      } else {
        days += isLeapYear(year)
            ? daysInMonthLeap[currentMonth - i]
            : daysInMonth[currentMonth - i];
      }
    }
    return days;
  }
  static List<DatePeriod> getPastMonthUntilFinancialYTD(DatePeriod ytd,
      {bool showCurrentMonth = false}) {
    var monthList = <DateTime>[];
    final currentTime = DateTime.now();
    if (currentTime.year < ytd.startDate.year) {
      return <DatePeriod>[];
    }
    if (currentTime.year == ytd.startDate.year) {
      //when current year is same as start year of financial year
      for (int i = ytd.startDate.month;
          i <= (showCurrentMonth ? currentTime.month : currentTime.month - 1);
          i++) {
        monthList.add(DateTime(currentTime.year, i));
      }
    } else if (currentTime.year == ytd.endDate.year) {
      //when current year is same as end year of financial year
      for (int i = ytd.startDate.month; i <= 12; i++) {
        monthList.add(DateTime(ytd.startDate.year, i));
      }
      for (int i = 1;
          i <=
              (currentTime.month <= ytd.endDate.month
                  ? showCurrentMonth
                      ? currentTime.month
                      : currentTime.month - 1
                  : ytd.endDate.month);
          /*
          * if current month is less than or equal to end month of financial year
          * we are using months less than current month and if it is more than
          * end month of financial year we are using till end month of financial
          * year
          */
          i++) {
        monthList.add(DateTime(ytd.endDate.year, i));
      }
    } else {
      for (int i = ytd.startDate.month; i <= 12; i++) {
        monthList.add(DateTime(ytd.startDate.year, i));
      }
      for (int i = 1; i <= ytd.endDate.month; i++) {
        monthList.add(DateTime(ytd.endDate.year, i));
      }
    }
    var list = monthList
        .map((e) => DatePeriod(DateTime(e.year, e.month, 1),
            DateTime(e.year, e.month + 1, 0, 23, 59, 59, 999), DateType.MONTH))
        .toList()
        .reversed
        .toList();
    return list;
  }
  
  static List<DatePeriod> getPastMonthIncludingCurrentMonthUntilFinancialYTD(
      DatePeriod ytd) {
    var monthList = <DateTime>[];
    final currentTime = DateTime.now();
    if (currentTime.year < ytd.startDate.year) {
      return <DatePeriod>[];
    }
    if (currentTime.year == ytd.startDate.year) {
      //when current year is same as start year of financial year
      for (int i = ytd.startDate.month; i <= currentTime.month; i++) {
        monthList.add(DateTime(currentTime.year, i));
      }
    } else if (currentTime.year == ytd.endDate.year) {
      //when current year is same as end year of financial year
      for (int i = ytd.startDate.month; i <= 12; i++) {
        monthList.add(DateTime(ytd.startDate.year, i));
      }
      for (int i = 1;
          i <=
              (currentTime.month <= ytd.endDate.month
                  ? currentTime.month
                  : ytd.endDate.month);
          /*
          * if current month is less than or equal to end month of financial year
          * we are using months less than current month and if it is more than
          * end month of financial year we are using till end month of financial
          * year
          */
          i++) {
        monthList.add(DateTime(ytd.endDate.year, i));
      }
    } else {
      for (int i = ytd.startDate.month; i <= 12; i++) {
        monthList.add(DateTime(ytd.startDate.year, i));
      }
      for (int i = 1; i <= ytd.endDate.month; i++) {
        monthList.add(DateTime(ytd.endDate.year, i));
      }
    }
    var list = monthList
        .map((e) => DatePeriod(DateTime(e.year, e.month, 1),
            DateTime(e.year, e.month + 1, 0, 23, 59, 59, 999), DateType.MONTH))
        .toList()
        .reversed
        .toList();
    return list;
  }

  static List<YearWithMonths> getFinancialYearList([int count = 5]) {
    var yearWithMonths = <YearWithMonths>[];

    if (DateTime.now().month >= 4) {
      var year = DatePeriod(
          DateTime(DateTime.now().year, 4),
          DateTime(DateTime.now().year + 1, 4, 0, 23, 59, 59, 999),
          DateType.YTD);
      var monthList = getPastMonthUntilFinancialYTD(year);
      yearWithMonths.add(YearWithMonths(monthList, year));
    } else {
      var year = DatePeriod(
          DateTime(DateTime.now().year - 1, 4), DateTime.now(), DateType.YTD);
      var monthList = getPastMonthUntilFinancialYTD(year);
      yearWithMonths.add(YearWithMonths(monthList, year));
    }

    for (int i = 0; i < count - 1; i++) {
      var currentDate = DateTime.now();
      dynamic year = currentDate.month < 4
          ? DateTime(currentDate.year - (i + 1))
          : DateTime(currentDate.year - i);
      year = DatePeriod(DateTime(year.year - 1, 4),
          DateTime(year.year, 4, 0, 23, 59, 59, 999), DateType.YEAR);
      var monthList = getPastMonthUntilFinancialYTD(year);
      yearWithMonths.add(YearWithMonths(monthList, year));
    }
    return yearWithMonths;
  }

  static List<YearWithMonths>
      getFinancialYearListWithCurrentMonthForCurrentYear([int count = 5]) {
    var yearWithMonths = <YearWithMonths>[];

    if (DateTime.now().month >= 4) {
      var year = DatePeriod(
          DateTime(DateTime.now().year, 4),
          DateTime(DateTime.now().year + 1, 4, 0, 23, 59, 59, 999),
          DateType.YTD);
      var monthList = getPastMonthIncludingCurrentMonthUntilFinancialYTD(year);
      yearWithMonths.add(YearWithMonths(monthList, year));
    } else {
      var year = DatePeriod(
          DateTime(DateTime.now().year - 1, 4), DateTime.now(), DateType.YTD);
      var monthList = getPastMonthIncludingCurrentMonthUntilFinancialYTD(year);
      yearWithMonths.add(YearWithMonths(monthList, year));
    }

    for (int i = 0; i < count - 1; i++) {
      var currentDate = DateTime.now();
      dynamic year = currentDate.month < 4
          ? DateTime(currentDate.year - (i + 1))
          : DateTime(currentDate.year - i);
      year = DatePeriod(DateTime(year.year - 1, 4),
          DateTime(year.year, 4, 0, 23, 59, 59, 999), DateType.YEAR);
      var monthList = getPastMonthIncludingCurrentMonthUntilFinancialYTD(year);
      yearWithMonths.add(YearWithMonths(monthList, year));
    }
    return yearWithMonths;
  }

  static List<DatePeriod> getMonthsOfFinancialYear() {
    var monthList = <DateTime>[];
    if (DateTime.now().month >= 4) {
      for (int i = 4; i <= DateTime.now().month; i++) {
        monthList.add(DateTime(DateTime.now().year, i));
      }
    } else {
      for (int i = 4; i <= 12; i++) {
        monthList.add(DateTime(DateTime.now().year - 1, i));
      }
      for (int i = 1; i <= DateTime.now().month; i++) {
        monthList.add(DateTime(DateTime.now().year, i));
      }
    }
    return monthList
        .map((e) => DatePeriod(DateTime(e.year, e.month, 1),
            DateTime(e.year, e.month + 1, 0, 23, 59, 59, 999), DateType.MONTH))
        .toList()
        .reversed
        .toList();
  }

  static String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }

  static Future<bool> isValidFileSize(int fileLength) async {
    var flag = true;
    if (fileLength > 5000000) {
      flag = false;
    }
    return flag;
  }

  static String getRandomName() {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    return '${commonProvider.userDetails?.userRequest?.id}${Random().nextInt(3)}';
  }

  MediaType getMediaType(String? path) {
    if (path == null) return MediaType('', '');
    String? mimeStr = lookupMimeType(path);
    var fileType = mimeStr?.split('/');
    if (fileType != null && fileType.length > 0) {
      return MediaType(fileType.first, fileType.last);
    } else {
      return MediaType('', '');
    }
  }

  static List<KeyValue> getAlphabetsWithKeyValue() {
    List<String> alphabets = [];
    List<KeyValue> excelColumns = [];
    for (int i = 65; i <= 90; i++) {
      alphabets.add(String.fromCharCode(i));
    }
    for (int i = 0; i < 26; i++) {
      excelColumns.add(KeyValue(alphabets[i], i));
    }
    return excelColumns;
  }

  static Future<void> fetchPackageInfo() async {
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e, s) {
      ErrorHandler.logError(e.toString(), s);
    }
  }

  void checkVersion(BuildContext context, AppVersion appVersion) async {
    try {
      String? latestAppVersion = Platform.isAndroid
          ? appVersion.latestAppVersion
          : appVersion.latestAppVersionIos;
      if (latestAppVersion != null && !kIsWeb) {
        if (int.parse(packageInfo!.version.split('.').join("").toString()) <
            int.parse(latestAppVersion.split('.').join("").toString())) {
          late Uri uri;

          if (Platform.isAndroid) {
            uri = Uri.https("play.google.com", "/store/apps/details",
                {"id": Constants.PACKAGE_NAME});
          } else {
            uri = Uri.https("apps.apple.com", "/in/app/mgramseva/id1614373649");
          }

          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return PopScope(
              
                    child: AlertDialog(
                      title: Text('UPDATE AVAILABLE'),
                      content: Text(
                          'Please update the app from ${packageInfo?.version} to $latestAppVersion'),
                      actions: [
                        TextButton(
                            onPressed: () =>
                                launchPlayStore(uri.toString(), context),
                            child: Text('Update'))
                      ],
                    ),                    
                    canPop: true,
                    onPopInvoked: (didPop)async {
                      if (Platform.isAndroid) {
                        SystemNavigator.pop();
                      } else if (Platform.isIOS) {
                        exit(0);
                      }                      
                    },
                    );
              });
        }
      }
    } catch (e) {}
  }

  void launchPlayStore(String appLink, BuildContext context) async {
    try {
      if (await canLaunch(appLink)) {
        await launch(appLink);
      } else {
        throw 'Could not launch appStoreLink';
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  /// Remove invalid financial years
  static Future<void> getFilteredFinancialYearList(
      List<TaxPeriod> taxPeriodList) async {
    taxPeriodList.removeWhere((e) {
      var fromDate = DateTime.fromMillisecondsSinceEpoch(e.fromDate!);
      var toDate = DateTime.fromMillisecondsSinceEpoch(e.toDate!);
      return (fromDate.year + 1) != toDate.year;
    });
  }
}
