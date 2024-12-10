import 'package:flutter/material.dart';
import 'package:mgramseva/components/dashboard/bills_table.dart';

import '../../model/common/BillsTableData.dart';
import '../../utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';

class GenericReportTable extends StatefulWidget {
  final BillsTableData billsTableData;
  final ScrollController scrollController;

  GenericReportTable(
    this.billsTableData, {
    required this.scrollController,
  });

  @override
  _GenericReportTableState createState() => _GenericReportTableState();
}

class _GenericReportTableState extends State<GenericReportTable> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Simulate the loading delay
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop showing the loader after 5 seconds
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var width =
          constraints.maxWidth < 760 ? 115.0 : (constraints.maxWidth / 6);

      return Container(
        width: widget.billsTableData.isEmpty()
            ? constraints.maxWidth
            : width * widget.billsTableData.tableHeaders.length + 2,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(), // Show loader
              )
            : widget.billsTableData.isEmpty()
                ? Center(
                    child: Text(
                      ApplicationLocalizations.of(context)
                          .translate(i18.dashboard.NO_RECORDS_MSG),
                    ),
                  )
                : BillsTable.withScrollController(
                    height: (53.0 *
                            (widget.billsTableData.tableData.length + 1)) +
                        2,
                    scrollPhysics: NeverScrollableScrollPhysics(),
                    headerList: widget.billsTableData.tableHeaders,
                    tableData: widget.billsTableData.tableData,
                    leftColumnWidth: width,
                    rightColumnWidth: width *
                        (widget.billsTableData.tableHeaders.length - 1),
                    scrollController: widget.scrollController,
                  ),
      );
    });
  }
}
