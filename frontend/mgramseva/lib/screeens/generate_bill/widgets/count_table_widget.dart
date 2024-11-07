import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/reports/WaterConnectionCount.dart';
import 'package:mgramseva/providers/search_connection_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:provider/provider.dart';
import '../../../utils/date_formats.dart';
import '../../../utils/localization/application_localizations.dart';

class CountTableWidget extends StatefulWidget {
  final List<WaterConnectionCount>? waterConnectionCount;
  final bool? isWCDemandNotGenerated;

  const CountTableWidget({Key? key, this.waterConnectionCount, this.isWCDemandNotGenerated})
      : super(key: key);

  @override
  _CountTableWidgetState createState() => _CountTableWidgetState();
}

class _CountTableWidgetState extends State<CountTableWidget> {
  bool _isCollapsed = true;

  @override
  Widget build(BuildContext context) {
    final List<WaterConnectionCount>? connectionCount =
        widget.waterConnectionCount;

    return Container(
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  child: _buildDataTable(connectionCount!),
                );
            },
          ),
          if (connectionCount!.length > 5)
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isCollapsed = !_isCollapsed;
                  });
                },
                child: Text(_isCollapsed
                    ? "${ApplicationLocalizations.of(context).translate(i18.common.VIEW_ALL)}"
                    : "${ApplicationLocalizations.of(context).translate(i18.common.COLLAPSE)}"),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataTable(List<WaterConnectionCount> connectionCount) {
    return DataTable(
      border: TableBorder.all(
        width: 0.5,
        borderRadius: BorderRadius.all(Radius.circular(5)),
        color: Colors.grey, // Set border color to grey
      ),// Set heading row background color to grey
      headingTextStyle: TextStyle(color:   Colors.black, fontWeight: FontWeight.bold), // Set heading text color to black and bold
      columns: [
        DataColumn(
          label: FittedBox(
            child: Text(
              "${ApplicationLocalizations.of(context).translate(i18.common.LAST_BILL_CYCLE_MONTH)}",
            ),
          ),
        ),
        DataColumn(
          label: FittedBox(
            child: Text(
              "${ApplicationLocalizations.of(context).translate(i18.common.CONSUMER_COUNT)}",
            ),
          ),
        )
      ],
      rows: _isCollapsed
          ? connectionCount.take(5).map((e) => _buildDataRow(e)).toList()
          : connectionCount.map((e) => _buildDataRow(e)).toList(),
    );
  }

  Widget buildLinkText(int count, bool isWCDemandNotGenerated, {VoidCallback? onTap, Uri? launchUri}) {
  final Color linkColor = isWCDemandNotGenerated ? Colors.blue : Colors.black;
  final MouseCursor? hoverCursor = SystemMouseCursors.click; // Optional hand cursor

  return GestureDetector(
    onTap: () {
      // onTap?.call();

      // if (launchUri != null) {
      // }
    },
    child: Text(
      count.toString(),
      style: TextStyle(
        color: linkColor,
        decoration: TextDecoration.underline, // Optional underline
      ),
    ),
  );
}

  DataRow _buildDataRow(WaterConnectionCount count) {
    final bool isEvenRow = widget.waterConnectionCount!.indexOf(count) % 2 == 0;
    final Color? rowColor = isEvenRow ? Colors.grey[100] : Colors.white; // Set alternate row background color to grey
    final status = widget.isWCDemandNotGenerated == true;
    return DataRow(
      color: MaterialStateColor.resolveWith((states) => rowColor!), // Apply alternate row background color

      cells: [
        DataCell(
          Text(
            DateFormats.getMonthAndYearFromDateTime(
              DateTime.fromMillisecondsSinceEpoch(count.taxperiodto!),
            ),
          ),
        ),
        DataCell(
          MouseRegion(
  cursor: status ?  SystemMouseCursors.click : SystemMouseCursors.basic,
    child: GestureDetector(
      child: 
       Text(count.count.toString(),
          style: TextStyle(
            decoration: status ? TextDecoration.underline :TextDecoration.none ,
            color: status ? Colors.blue : Colors.black
          ),         
          ),
      onTap: () {
        if(status){
           var searchConnectionProvider =
        Provider.of<SearchConnectionProvider>(context, listen: false);
          searchConnectionProvider.fetchNonDemandGeneratedConnectionDetails(context,"${count.taxperiodto!}");
        }
      },
    ),
  ),         
        ),
      ],
    );
  }
}
