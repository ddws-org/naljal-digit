import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:mgramseva/widgets/scroll_parent.dart';

class BillsTable extends StatefulWidget {
  final List<TableHeader> headerList;
  final List<TableDataRow> tableData;
  final double leftColumnWidth;
  final double rightColumnWidth;
  final double? height;
  final ScrollPhysics? scrollPhysics;
  ScrollController scrollController = ScrollController();
  BillsTable(
      {Key? key,
      required this.headerList,
      required this.tableData,
      required this.leftColumnWidth,
      required this.rightColumnWidth,
      this.height,
      this.scrollPhysics})
      : super(key: key);
  BillsTable.withScrollController(
      {Key? key,
      required this.headerList,
      required this.tableData,
      required this.leftColumnWidth,
      required this.rightColumnWidth,
      this.height,
      this.scrollPhysics,
      required this.scrollController})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BillsTable();
  }
}

class _BillsTable extends State<BillsTable> {
  final double columnRowFixedHeight = 52.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        child: HorizontalDataTable(
            leftHandSideColumnWidth: widget.leftColumnWidth,
            rightHandSideColumnWidth: widget.rightColumnWidth,
            isFixedHeader: true,
            headerWidgets: _getTitleWidget(constraints),
            leftSideItemBuilder: _generateFirstColumnRow,
            rightSideItemBuilder: _generateRightHandSideColumnRow,
            itemCount: widget.tableData.length,
            elevation: 0,
            // rowSeparatorWidget: const Divider(
            //   color: Colors.black54,
            //   height: 1.0,
            //   thickness: 0.0,
            // ),
            leftHandSideColBackgroundColor: Color(0xFFFFFFFF),
            rightHandSideColBackgroundColor: Color(0xFFFFFFFF),
            scrollPhysics: widget.scrollPhysics,
            verticalScrollbarStyle: const ScrollbarStyle(
              isAlwaysShown: true,
              thickness: 4.0,
              radius: Radius.circular(5.0),
            ),
            horizontalScrollbarStyle: const ScrollbarStyle(
              isAlwaysShown: true,
              thickness: 4.0,
              radius: Radius.circular(5.0),
            ),
            enablePullToRefresh: false),
        height: widget.height ?? MediaQuery.of(context).size.height,
      );
    });
  }

  List<Widget> _getTitleWidget(constraints) {
    var index = 0;
    return widget.headerList.map((e) {
      index++;
      if (e.isSortingRequired ?? false) {
        return TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
            child: _getTitleItemWidget((e.label), constraints,
                isAscending: e.isAscendingOrder,
                isBorderRequired: (index - 1) == 0),
            onPressed: e.callBack == null ? null : () => e.callBack!(e));
      } else {
        return _getTitleItemWidget(e.label, constraints!);
      }
    }).toList();
  }

  Widget _getTitleItemWidget(String label, constraints,
      {bool? isAscending, bool isBorderRequired = false}) {
    var textWidget = Text(ApplicationLocalizations.of(context).translate(label),
        style: TextStyle(
            fontWeight: FontWeight.w700, color: Colors.black, fontSize: 12));
    var LedgerLabelText = Text(ApplicationLocalizations.of(context).translate("ledger_label"),style: TextStyle(
            fontWeight: FontWeight.w700, color: Colors.black, fontSize: 12));
    return Container(
      decoration: isBorderRequired
          ? BoxDecoration(
              border: Border(
                  left: tableCellBorder,
                  bottom: tableCellBorder,
                  right: tableCellBorder))
          : null,
      child: isAscending != null
          ? Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 5,
              children: [
                textWidget,
                Icon(isAscending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward_sharp),
                if (MediaQuery.of(context).size.width > 720)
                  LedgerLabelText
              ],
            )
          : textWidget,
      width: widget.leftColumnWidth,
      height: 56,
      padding: EdgeInsets.only(left: 17, right: 5, top: 6, bottom: 6),
      alignment: Alignment.centerLeft,
    );
  }

  double columnRowIncreasedHeight(int index) {
    return (50 +
        widget.tableData[index].tableRow.first.label
            .substring(28)
            .length
            .toDouble());
    //if greater than 28 characters
  }

  String getCurrentRoutePath(BuildContext context) {
    final currentRoute = ModalRoute.of(context)!;
    return currentRoute.settings.name ?? '';
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return LayoutBuilder(builder: (context, constraints) {
      bool showLeadger =
          getCurrentRoutePath(context) == "/home/householdRegister";
      var data = widget.tableData[index].tableRow.first;

      return ScrollParent(
          widget.scrollController,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  if (data.callBack != null) {
                    data.callBack!(data);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                    left: tableCellBorder,
                    bottom: tableCellBorder,
                    right: tableCellBorder,
                  )),
                  child: Text(
                    ApplicationLocalizations.of(context).translate(
                        widget.tableData[index].tableRow.first.label),
                    style: widget.tableData[index].tableRow.first.style ??
                        TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  width: showLeadger
                      ? widget.leftColumnWidth * 0.55
                      : widget.leftColumnWidth,
                  height:
                      widget.tableData[index].tableRow.first.label.length > 28
                          ? columnRowIncreasedHeight(index)
                          : columnRowFixedHeight,
                  padding:
                      EdgeInsets.only(left: 17, right: 5, top: 6, bottom: 6),
                  alignment: Alignment.centerLeft,
                ),
              ),
              if (showLeadger)
                Tooltip(
                  message:
                      '${ApplicationLocalizations.of(context).translate(i18.dashboard.LEDGER_REPORTS)}',
                  child: IconButton(
                      onPressed: () {
                        if (data.iconButtonCallBack != null) {
                          data.iconButtonCallBack!(data);
                        }
                      },
                      icon: Icon(Icons.insert_chart_outlined)),
                )
            ],
          ));
    });
  }

  Widget _generateColumnRow(
      BuildContext context, int index, String input, constraints,
      {TextStyle? style, int? i}) {
    var data = widget.tableData[index].tableRow[i ?? 0];
    if (i != null) {
      return InkWell(
        onTap: () {
          data.callBack!(data);
        },
        child: Container(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  ApplicationLocalizations.of(context).translate(input),
                  style: style,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
          width: widget.leftColumnWidth,
          height: widget.tableData[index].tableRow.first.label.length > 28
              ? columnRowIncreasedHeight(index)
              : columnRowFixedHeight,
          padding: EdgeInsets.only(left: 17, right: 5, top: 6, bottom: 6),
          alignment: Alignment.centerLeft,
        ),
      );
    } else {
      return Container(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                ApplicationLocalizations.of(context).translate(input),
                style: style,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          ],
        ),
        width: widget.leftColumnWidth,
        height: widget.tableData[index].tableRow.first.label.length > 28
            ? columnRowIncreasedHeight(index)
            : columnRowFixedHeight,
        padding: EdgeInsets.only(left: 17, right: 5, top: 6, bottom: 6),
        alignment: Alignment.centerLeft,
      );
    }
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    var data = widget.tableData[index];

    return LayoutBuilder(builder: (context, constraints) {
      var list = <Widget>[];
      for (int i = 1; i < data.tableRow.length; i++) {
        list.add(
          _generateColumnRow(
              context, index, data.tableRow[i].label, constraints,
              style: data.tableRow[i].style),
        );
      }
      return Container(
          color: index % 2 == 0 ? const Color(0xffEEEEEE) : Colors.white,
          child: Row(children: list));
    });
  }

  BorderSide get tableCellBorder =>
      BorderSide(color: Color.fromRGBO(238, 238, 238, 1), width: 0.5);
}
