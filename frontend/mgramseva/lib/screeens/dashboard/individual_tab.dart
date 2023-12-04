import 'package:flutter/material.dart';
import 'package:mgramseva/components/dashboard/bills_table.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/model/expenses_details/expenses_details.dart';
import 'package:mgramseva/providers/dashboard_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_widgets.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:provider/provider.dart';

import '../../utils/notifiers.dart';

class IndividualTab extends StatefulWidget {
  const IndividualTab({Key? key}) : super(key: key);

  @override
  _IndividualTabState createState() => _IndividualTabState();
}

class _IndividualTabState extends State<IndividualTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dashBoardProvider =
        Provider.of<DashBoardProvider>(context, listen: false);
    return StreamBuilder(
        stream: dashBoardProvider.streamController.stream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data is String) {
              return CommonWidgets.buildEmptyMessage(snapshot.data, context);
            }
            return _buildTabView(snapshot.data);
          } else if (snapshot.hasError) {
            return Notifiers.networkErrorPage(context, () => {});
          } else {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Loaders.circularLoader();
              case ConnectionState.active:
                return Loaders.circularLoader();
              default:
                return Container();
            }
          }
        });
  }

  Widget _buildTabView(List<dynamic> expenseList) {
    var dashBoardProvider =
        Provider.of<DashBoardProvider>(context, listen: false);

    return LayoutBuilder(builder: (context, constraints) {
      var width = constraints.maxWidth < 760
          ? (expenseList is List<ExpensesDetailsModel> ? 180.0 : 145.0)
          : (constraints.maxWidth /
              (expenseList is List<ExpensesDetailsModel> ? 5 : 3));
      var tableData = expenseList is List<ExpensesDetailsModel>
          ? dashBoardProvider
              .getExpenseData(expenseList)
          : dashBoardProvider
              .getCollectionsData(expenseList as List<WaterConnection>);
      var extraHeight = 0.0;
      tableData.forEach((e) {
        if (e.tableRow.first.label.length > 28)
          extraHeight += e.tableRow.first.label.substring(28).length.toDouble();
      });
      return tableData.isEmpty
          ? SizedBox(
              height: 100,
              child: CommonWidgets.buildEmptyMessage(
                  ApplicationLocalizations.of(context)
                      .translate(i18.dashboard.NO_RECORDS_MSG),
                  context))
          : BillsTable(
              headerList: expenseList is List<ExpensesDetailsModel>
                  ? dashBoardProvider.expenseHeaderList
                  : dashBoardProvider.collectionHeaderList,
              tableData: tableData,
              leftColumnWidth: width,
              height: 58 + (52.0 * tableData.length + 1) + extraHeight,
              rightColumnWidth: expenseList is List<ExpensesDetailsModel>
                  ? width * 4
                  : width * 2,
              scrollPhysics: NeverScrollableScrollPhysics(),
            );
    });
  }
}
