import 'package:flutter/material.dart';
import 'package:mgramseva/components/dashboard/bills_table.dart';

import '../../model/common/BillsTableData.dart';
import '../../utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';

class GenericReportTable extends StatelessWidget {
  final BillsTableData billsTableData;
  final ScrollController scrollController;

  GenericReportTable(this.billsTableData, {required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var width =
          constraints.maxWidth < 760 ? 115.0 : (constraints.maxWidth / 6);
      return Container(
        width: this.billsTableData.isEmpty()
            ? constraints.maxWidth
            : width * billsTableData.tableHeaders.length + 2,
        child: this.billsTableData.isEmpty()
            ? Center(
                child: Text(ApplicationLocalizations.of(context)
                    .translate(i18.dashboard.NO_RECORDS_MSG)))
            : BillsTable.withScrollController(
                height: (53.0 * (billsTableData.tableData.length + 1)) + 2,
                scrollPhysics: NeverScrollableScrollPhysics(),
                headerList: billsTableData.tableHeaders,
                tableData: billsTableData.tableData,
                leftColumnWidth: width,
                rightColumnWidth:
                    width * (billsTableData.tableHeaders.length - 1),
                scrollController: scrollController,
              ),
      );
    });
  }
}
