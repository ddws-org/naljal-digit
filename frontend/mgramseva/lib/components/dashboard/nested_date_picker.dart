import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/widgets/custom_overlay/custom_overlay.dart';

class NestedDatePicker extends StatefulWidget {
  final ValueChanged<DatePeriod?> onSelectionOfDate;
  final List<dynamic>? yearsWithMonths;
  final DatePeriod? selectedMonth;
  final int maximumYears;
  final double? left;
  final double? top;
  final DateType dateType;
  const NestedDatePicker(
      {Key? key,
      required this.onSelectionOfDate,
      this.left,
      this.top,
      this.yearsWithMonths,
      this.selectedMonth,
      this.maximumYears = 5,
      this.dateType = DateType.YEAR})
      : super(key: key);

  @override
  State<NestedDatePicker> createState() => _NestedDatePickerState();
}

class _NestedDatePickerState extends State<NestedDatePicker> {
  late List<dynamic> yearsWithMonths;
  DatePeriod? selectedMonth;

  @override
  void initState() {
    if (widget.dateType == DateType.YEAR) {
      yearsWithMonths = widget.yearsWithMonths ??CommonMethods.getFinancialYearListWithCurrentMonthForCurrentYear(widget.maximumYears);
    } else {
      yearsWithMonths = CommonMethods.getPastMonthIncludingCurrentMonthUntilFinancialYTD(yearsWithMonths.first.year);
    }

    if (widget.dateType == DateType.YEAR) {
      if (widget.selectedMonth != null) {
        DatePeriod? date;
        for (YearWithMonths yearWithMonth in yearsWithMonths) {
          if ((widget.selectedMonth?.startDate.toString() == yearWithMonth.year.startDate.toString()) &&
              (widget.selectedMonth?.endDate.toString() == yearWithMonth.year.endDate.toString())) {
            date = yearWithMonth.year;
          }
          if(date == null)
            for (var month in yearWithMonth.monthList) {
              if (widget.selectedMonth?.endDate.toString() == month.endDate.toString()) {
                date = month;
              }
            }
        }
        selectedMonth = date ?? yearsWithMonths.first.year;
      } else {
        selectedMonth ??= yearsWithMonths.first.year;
      }
    } else {
      DatePeriod? date;
      for (var month in yearsWithMonths) {
        if (widget.selectedMonth?.endDate.toString() ==
            month.endDate.toString()) {
          date = month;
        }
      }
      selectedMonth = date ?? yearsWithMonths.first;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Positioned(
        left: widget.left,
        top: widget.top,
        child: Material(
            color: Colors.transparent,
            child: Container(
                constraints:
                    BoxConstraints(maxHeight: (height - (widget.top ?? 0))),
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(5.0),
                    bottomLeft: Radius.circular(5.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(.5),
                      blurRadius: 20.0, // soften the shadow
                      spreadRadius: 0.0, //extend the shadow
                      offset: Offset(
                        5.0, // Move to right 10  horizontally
                        5.0, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.dateType == DateType.YEAR
                          ? List.generate(yearsWithMonths.length, (index) {
                              var yearWithMonths = yearsWithMonths[index];
                              return Wrap(
                                direction: Axis.vertical,
                                children: [
                                  Tooltip(
                                    padding: EdgeInsets.all(5),
                                    message:
                                        '${ApplicationLocalizations.of(context).translate(i18.dashboard.YEAR_TOOL_TIP_MESSAGE)}',
                                    child: Container(
                                      width: 200,
                                      decoration: index ==
                                              yearWithMonths.monthList.length -
                                                  1
                                          ? BoxDecoration(
                                              color: index % 2 == 0
                                                  ? Color.fromRGBO(
                                                      238, 238, 238, 1)
                                                  : Color.fromRGBO(
                                                      255, 255, 255, 1),
                                              borderRadius: BorderRadius.only(
                                                bottomRight:
                                                    Radius.circular(5.0),
                                                bottomLeft:
                                                    Radius.circular(5.0),
                                              ))
                                          : BoxDecoration(
                                              color: index % 2 == 0
                                                  ? Color.fromRGBO(
                                                      238, 238, 238, 1)
                                                  : Color.fromRGBO(
                                                      255, 255, 255, 1),
                                            ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 8),
                                      child: Wrap(
                                        spacing: 5,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        alignment: WrapAlignment.spaceBetween,
                                        children: [
                                          InkWell(
                                            onTap: () => onSelectionOfExpansion(
                                                yearWithMonths),
                                            child: Text(
                                              '${DateFormats.getMonthAndYear(yearWithMonths.year, context)}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      yearStatus(yearWithMonths)
                                                          ? FontWeight.bold
                                                          : FontWeight.normal),
                                            ),
                                          ),
                                          Radio(
                                              value: yearWithMonths.year,
                                              groupValue: selectedMonth,
                                              onChanged: onSelectionOfDate)
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: monthStatus(yearWithMonths),
                                    child: Wrap(
                                        direction: Axis.vertical,
                                        children: List.generate(
                                            yearWithMonths.monthList.length,
                                            (monthIndex) {
                                          var date = yearWithMonths
                                              .monthList[monthIndex];
                                          return _dateView(date,
                                              (monthIndex + index) % 2 == 0);
                                        }).toList()),
                                  )
                                ],
                              );
                            })
                          : List.generate(yearsWithMonths.length, (index) {
                              var date = yearsWithMonths[index];
                              return _dateView(date, index % 2 == 0);
                            })),
                ))));
  }

  Widget _dateView(DatePeriod date, bool flag) {
    return InkWell(
      onTap: () => onSelectionOfDate(date),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
            color: flag
                ? Color.fromRGBO(255, 255, 255, 1)
                : Color.fromRGBO(238, 238, 238, 1)),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Container(
          width: 195,
          alignment: Alignment.centerRight,
          child: Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                '${DateFormats.getMonthAndYear(date, context)}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: selectedMonth == date
                        ? FontWeight.bold
                        : FontWeight.normal),
              ),
              Radio(
                  value: date,
                  groupValue: selectedMonth,
                  onChanged: onSelectionOfDate)
            ],
          ),
        ),
      ),
    );
  }

  void onSelectionOfDate(datePeriod) {    ///Type should be DatePeriod
    if (datePeriod?.dateType != DateType.MONTH)
      yearsWithMonths.forEach((e) => e.isExpanded = false);
    CustomOverlay.removeOverLay();
    widget.onSelectionOfDate(datePeriod);
  }

  void onSelectionOfExpansion(YearWithMonths yearWithMonths) {
    yearsWithMonths.forEach((e) {
      if (e != yearWithMonths) e.isExpanded = false;
    });
    setState(() {
      yearWithMonths.isExpanded = !yearWithMonths.isExpanded;
    });
  }

  bool yearStatus(YearWithMonths yearWithMonths) =>
      selectedMonth == yearWithMonths.year;

  bool monthStatus(YearWithMonths yearWithMonths) =>
      yearWithMonths.monthList.contains(selectedMonth) ||
      yearWithMonths.isExpanded;
}
