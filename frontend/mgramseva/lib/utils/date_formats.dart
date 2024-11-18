import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/constants.dart';

import 'localization/application_localizations.dart';
import 'global_variables.dart';
import 'models.dart';

class DateFormats {
  static getFilteredDate(String date, {String? dateFormat}) {
    if (date.trim().isEmpty) return '';
    try {
      var dateTime = DateTime.parse(date).toLocal();
      return DateFormat(dateFormat ?? "dd-MM-yyyy").format(dateTime);
    } on Exception {
      return '';
    }
  }

  static DateTime? getDateFromString(String date) {
    if (date.trim().isEmpty) return null;
    try {
      var dateTime = DateTime.parse(date).toLocal();
      return dateTime;
    } on Exception {
      return null;
    }
  }

  static DateTime? getFormattedDateToDateTime(String date) {
    try {
      DateFormat inputFormat;
      if (date.contains('-')) {
        inputFormat = DateFormat('dd-MM-yyyy');
      } else {
        inputFormat = DateFormat('dd/MM/yyyy');
      }
      var inputDate = inputFormat.parse(date);
      return inputDate;
    } on Exception {
      return null;
    }
  }

  static String leadgerTimeStampToDate(int? timeInMillis, {String? format}) {
  if (timeInMillis == null || timeInMillis == 0) return '-';
  try {
    var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
    return DateFormat('dd-MMM-yyyy').format(date);

  } catch (e) {
    return '';
  }
}

  static String getTime(String date) {
    if (date.trim().isEmpty) return '';
    try {
      var dateTime = getDateFromString(date);
      return DateFormat.Hms().format(dateTime!);
    } on Exception {
      return '';
    }
  }

  static String getLocalTime(String date) {
    try {
      var dateTime = getDateFromString(date);
      return DateFormat.jm().format(dateTime!);
    } on Exception {
      return '';
    }
  }

  static int dateToTimeStamp(String dateTime) {
    try {
      return getFormattedDateToDateTime(dateTime)!
          .toUtc()
          .millisecondsSinceEpoch;
    } catch (e) {
      return 0;
    }
  }

  static String timeStampToDate(int? timeInMillis, {String? format}) {
    if (timeInMillis == null) return '';
    try {
      var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
      return DateFormat(format ?? 'dd/MM/yyyy').format(date);
    } catch (e) {
      return '';
    }
  }

  static String getMonthWithDay(int? timeInMillis) {
    if (timeInMillis == null) return '';
    try {
      var date = DateTime.fromMillisecondsSinceEpoch(timeInMillis);
      return '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(DateFormat.MMM().format(date))} ${date.day}';
    } catch (e) {
      return '';
    }
  }

  static String getMonthAndYear(DatePeriod date, BuildContext context) {
    try {
      switch (date.dateType) {
        case DateType.YTD:
          return '${ApplicationLocalizations.of(context).translate(i18.common.YTD)} ${date.startDate.year} - ${date.endDate.year.toString().substring(2)}';
        case DateType.MONTH:
          return '${ApplicationLocalizations.of(context).translate(Constants.MONTHS[date.startDate.month - 1])} - ${date.startDate.year}';
        case DateType.YEAR:
          return '${date.startDate.year} - ${date.endDate.year.toString().substring(2)}';
        default:
          return '';
      }
    } catch (e) {
      return '';
    }
  }

  static String getMonth(DateTime date) {
    try {
      return '${DateFormat.MMM().format(date)}';
    } catch (e) {
      return '';
    }
  }

  static String getMonthAndYearFromDateTime(DateTime date) {
    try {
      return '${ApplicationLocalizations.of(navigatorKey.currentContext!).translate(Constants.MONTHS[date.month-1])}-${DateFormat.y().format(date)}';
    } catch (e) {
      return '';
    }
  }
}
