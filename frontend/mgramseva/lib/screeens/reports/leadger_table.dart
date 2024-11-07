import 'package:flutter/material.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:provider/provider.dart';
import '../../providers/reports_provider.dart';
import '../../utils/localization/application_localizations.dart';
import '../../widgets/label_text.dart';
import '../../widgets/pagination.dart';
import '../../widgets/sub_label.dart';
import 'generic_report_table.dart';

class LeadgerTable extends StatelessWidget {
  final ScrollController scrollController;
  final String tableTitle;
  final WaterConnection? waterConnection;
  LeadgerTable(
      {required this.tableTitle,
      required this.scrollController,
      this.waterConnection});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
              margin: EdgeInsets.only(bottom: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Consumer<ReportsProvider>(
                        builder: (_, reportProvider, child) {
                      return SubLabelText(
                          "${ApplicationLocalizations.of(context).translate(i18.common.LEDGER_CUSTOMER_NAME)} : ${waterConnection?.connectionHolders?.first.name}");
                    }),
                    Consumer<ReportsProvider>(
                        builder: (_, reportProvider, child) {
                      if (constraints.maxWidth < 760) {
                        return Column(
                          children: [
                            SubLabelText(
                                "${ApplicationLocalizations.of(context).translate(i18.common.LEDGER_CONN_ID)} : ${waterConnection?.connectionNo}"),
                            SubLabelText(
                                "${ApplicationLocalizations.of(context).translate(i18.common.LEDGER_OLD_CONN_ID)} : ${waterConnection?.oldConnectionNo}"),
                          ],
                        );
                      } else {
                        return Row(
                          children: [
                            SubLabelText(
                                "${ApplicationLocalizations.of(context).translate(i18.common.LEDGER_CONN_ID)} : ${waterConnection?.connectionNo}"),
                            SubLabelText(
                                "${ApplicationLocalizations.of(context).translate(i18.common.LEDGER_OLD_CONN_ID)} : ${waterConnection?.oldConnectionNo}"),
                          ],
                        );
                      }
                    }),
                  ])),
          SizedBox(
            height: 30,
          ),
          Container(
            child:
                Consumer<ReportsProvider>(builder: (_, reportProvider, child) {
              var width = constraints.maxWidth < 760
                  ? 115.0
                  : (constraints.maxWidth / 6);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GenericReportTable(
                    reportProvider.genericTableData,
                    scrollController: scrollController,
                  ),
                  Container(
                    width: width *
                            reportProvider
                                .genericTableData.tableHeaders.length +
                        2,
                    // child: Visibility(
                    //   visible:
                    //       reportProvider.genericTableData.tableData.isNotEmpty,
                    //   child: Pagination(
                    //     limit: reportProvider.limit,
                    //     offSet: reportProvider.offset,
                    //     callBack: (pageResponse) =>
                    //         reportProvider.onChangeOfPageLimit(
                    //             pageResponse, tableTitle, context),
                    //     isTotalCountVisible: true,
                    //     isDisabled: true,
                    //     totalCount:
                    //         reportProvider.genericTableData.tableData.length,
                    //   ),
                    // ),
                  )
                ],
              );
            }),
          ),
        ],
      );
    });
  }
}
