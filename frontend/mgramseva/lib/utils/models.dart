import 'dart:typed_data';

import 'package:flutter/material.dart';

enum RequestType { GET, PUT, POST, DELETE }

enum ExceptionType {
  UNAUTHORIZED,
  BADREQUEST,
  INVALIDINPUT,
  FETCHDATA,
  OTHER,
  CONNECTIONISSUE
}

enum MDMSType { BusinessService, ConsumerType, TaxHeadCode }

enum DashBoardType { collections, Expenditure }

enum DateType { YTD, MONTH, YEAR, LABEL }

class KeyValue {
  String label;
  dynamic key;
  KeyValue(this.label, this.key);
}

class HomeItem {
  final String label;
  final String walkThroughMsg;
  final IconData iconData;
  final String link;
  final Map<String, dynamic> arguments;

  const HomeItem(
    this.label,
    this.walkThroughMsg,
    this.iconData,
    this.link,
    this.arguments,
  );
}

class SearchResult {
  final String Function() label;
  final List<dynamic> result;

  SearchResult(this.label, this.result);
}

class PaginationResponse {
  int offset = 0;
  int limit;
  bool isPageChange;
  PaginationResponse(this.limit, this.offset, [this.isPageChange = false]);
}

class TableHeader {
  final String label;
  final ValueChanged<TableHeader>? callBack;
  bool? isSortingRequired = false;
  bool? isAscendingOrder;
  String? apiKey;
  TableHeader(this.label,
      {this.callBack,
      this.isSortingRequired,
      this.isAscendingOrder,
      this.apiKey});
}

class TableDataRow {
  final List<TableData> tableRow;
  TableDataRow(this.tableRow);
}

class TableData {
  final String label;
  final TextStyle? style;
  final String? apiKey;
  ValueChanged<TableData>? callBack;
  ValueChanged<TableData>? iconButtonCallBack;
  TableData(this.label, {this.style, this.callBack,this. iconButtonCallBack, this.apiKey});
}

class SortBy {
  final String key;
  final bool isAscending;
  SortBy(this.key, this.isAscending);
}

class DatePeriod {
  final DateTime startDate;
  final DateTime endDate;
  final DateType dateType;
  final String? label;
  DatePeriod(this.startDate, this.endDate, this.dateType, [this.label]);

  @override
  bool operator ==(otherDate) {
    return (otherDate is DatePeriod)
        && otherDate.startDate == startDate
        && otherDate.endDate == endDate
        && otherDate.dateType == dateType
        && otherDate.label == label;
  }
}

class Legend {
  final String label;
  final String hexColor;

  Legend(this.label, this.hexColor);
}


class CustomFile {
  final Uint8List bytes;
  final String name;
  final String extension;

  CustomFile(this.bytes, this.name, this.extension);
}

class YearWithMonths {
  final List<DatePeriod> monthList;
  final DatePeriod year;
  bool isExpanded = false;
  YearWithMonths(this.monthList, this.year);
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class Penalty {
  double penalty;
  String date;
  bool isDueDateCrossed = false;
  Penalty(this.penalty, this.date, this.isDueDateCrossed);
}

class PenaltyApplicable {
  double penaltyApplicable;
  PenaltyApplicable(this.penaltyApplicable);
}
