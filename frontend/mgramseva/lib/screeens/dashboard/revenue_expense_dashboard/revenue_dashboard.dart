import 'package:flutter/material.dart';
import 'package:mgramseva/components/dashboard/bills_table.dart';
import 'package:mgramseva/providers/revenue_dashboard_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_widgets.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:provider/provider.dart';

import 'revenue_charts.dart';

class RevenueDashBoard extends StatefulWidget {
  final bool isFromScreenshot;
  const RevenueDashBoard({Key? key, this.isFromScreenshot = false})
      : super(key: key);

  @override
  _RevenueDashBoardState createState() => _RevenueDashBoardState();
}

class _RevenueDashBoardState extends State<RevenueDashBoard> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  afterViewBuild() {
    var revenueProvider = Provider.of<RevenueDashboard>(context, listen: false);
    if (!widget.isFromScreenshot)
      revenueProvider.loadGraphicalDashboard(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.isFromScreenshot ? 5 : 16),
      child: Column(
        children: [
          RevenueCharts(widget.isFromScreenshot),
          _buildLoaderView(),
          Visibility(
            visible: !widget.isFromScreenshot,
            child: Align(alignment: Alignment.centerLeft, child: _buildNote()),
          ),
          Footer(padding: widget.isFromScreenshot ? EdgeInsets.all(5.0) : null)
        ],
      ),
    );
  }

  Widget _buildLoaderView() {
    var revenueDashboard =
        Provider.of<RevenueDashboard>(context, listen: false);
    var height = 250.0;
    return Consumer<RevenueDashboard>(
        builder: (_, revenue, child) => revenue.revenueDataHolder.tableLoader
            ? Loaders.circularLoader(height: height)
            : revenue.revenueDataHolder.revenueTable == null
                ? CommonWidgets.buildEmptyMessage(
                    i18.dashboard.NO_RECORDS_MSG, context)
                : _buildTable(revenue.revenueDataHolder.revenueTable!));
  }

  Widget _buildNote() {
    return Container(
      decoration: new BoxDecoration(color: Theme.of(context).highlightColor),
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 5,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.info, color: Theme.of(context).hintColor),
              Text(
                  ApplicationLocalizations.of(context)
                      .translate(i18.common.NOTE),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).hintColor))
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '${ApplicationLocalizations.of(context).translate(i18.dashboard.REVENUE_NOTE)}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: Color.fromRGBO(52, 152, 219, 1)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTable(List<TableDataRow> tableData) {
    var revenueDashboard =
        Provider.of<RevenueDashboard>(context, listen: false);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: widget.isFromScreenshot ? 5 : 16),
      child: LayoutBuilder(builder: (context, constraints) {
        var width =
            constraints.maxWidth < 760 ? 150.0 : constraints.maxWidth / 8;
        return BillsTable(
          headerList: revenueDashboard.revenueHeaderList,
          tableData: tableData,
          leftColumnWidth: width,
          rightColumnWidth: width * 7,
          height: 63 + (52.0 * tableData.length + 1),
          scrollPhysics: NeverScrollableScrollPhysics(),
        );
      }),
    );
  }
}
