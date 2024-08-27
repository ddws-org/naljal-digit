import 'package:flutter/material.dart';
import 'package:mgramseva/screeens/reports/expense_bill_report.dart';
import 'package:mgramseva/screeens/reports/inactive_consumer_report.dart';
import 'package:mgramseva/screeens/reports/monthly_ledger_report.dart';
import 'package:mgramseva/screeens/reports/vendor_report.dart';
import 'package:mgramseva/screeens/reports/view_table.dart';
import 'package:provider/provider.dart';

import '../../providers/reports_provider.dart';
import '../../utils/global_variables.dart';
import '../../utils/localization/application_localizations.dart';
import '../../utils/testing_keys/testing_keys.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/drawer_wrapper.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import '../../widgets/footer.dart';
import '../../widgets/home_back.dart';
import '../../widgets/label_text.dart';
import '../../widgets/select_field_builder.dart';
import '../../widgets/side_bar.dart';
import 'bill_report.dart';
import 'collection_report.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Reports();
  }
}

class _Reports extends State<Reports> with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  var takeScreenShot = false;
  bool viewTable = false;
  String tableTitle = 'Table Data';

  @override
  void dispose() {
    var reportsProvider = Provider.of<ReportsProvider>(
        navigatorKey.currentContext!,
        listen: false);
    reportsProvider.clearBillingSelection();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
  }

  afterViewBuild() {
    var reportsProvider = Provider.of<ReportsProvider>(
        navigatorKey.currentContext!,
        listen: false);
    reportsProvider.getFinancialYearList();
    reportsProvider.clearBillingSelection();
    reportsProvider.clearBuildTableData();
    reportsProvider.clearTableData();
  }

  showTable(bool status, String title) {
    setState(() {
      viewTable = status;
      tableTitle = title;
    });
  }

  backButtonCallback() {
    var reportProvider = Provider.of<ReportsProvider>(
        navigatorKey.currentContext!,
        listen: false);
    if (viewTable == true) {
      viewTable = false;
      reportProvider.clearBuildTableData();
    } else if (viewTable == false) {
      reportProvider.clearBuildTableData();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: DrawerWrapper(
        Drawer(child: SideBar()),
      ),
      backgroundColor: Color.fromRGBO(238, 238, 238, 1),
      body: LayoutBuilder(
        builder: (context, constraints) => Container(
          alignment: Alignment.center,
          margin: constraints.maxWidth < 760
              ? null
              : EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                color: Color.fromRGBO(238, 238, 238, 1),
                margin: constraints.maxWidth < 760
                    ? null
                    : EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 95),
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: viewTable
                      ? Container(
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HomeBack(
                              callback: () {
                                setState(() {
                                  viewTable = false;
                                });
                              },
                            ),
                            ViewTable(
                              tableTitle: tableTitle,
                              scrollController: scrollController,
                            ),
                          ],
                        ))
                      : Column(
                          children: [
                            HomeBack(),
                            Card(
                                margin: EdgeInsets.only(bottom: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                ),
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      LabelText(i18.dashboard.CORE_REPORTS),
                                    ])),
                            SizedBox(
                              height: 30,
                            ),
                            Card(
                              margin: EdgeInsets.only(bottom: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 15, bottom: 10.0),
                                child: Column(
                                  children: [
                                    Consumer<ReportsProvider>(
                                        builder: (_, reportProvider, child) =>
                                            Container(
                                              child: Column(
                                                children: [
                                                  SelectFieldBuilder(
                                                    i18.demandGenerate
                                                        .BILLING_YEAR_LABEL,
                                                    reportProvider
                                                        .selectedBillYear,
                                                    '',
                                                    '',
                                                    reportProvider
                                                        .onChangeOfBillYear,
                                                    reportProvider
                                                        .getFinancialYearListDropdown(
                                                            reportProvider
                                                                .billingYearList),
                                                    true,
                                                    readOnly: false,
                                                    controller: reportProvider
                                                        .billingyearCtrl,
                                                    key: Keys.billReport
                                                        .BILL_REPORT_BILLING_YEAR,
                                                    itemAsString: (i) =>
                                                        "${ApplicationLocalizations.of(context).translate(i.financialYear)}",
                                                  ),
                                                  SelectFieldBuilder(
                                                    i18.demandGenerate
                                                        .BILLING_CYCLE_LABEL,
                                                    reportProvider
                                                        .selectedBillCycle,
                                                    '',
                                                    '',
                                                    reportProvider
                                                        .onChangeOfBillCycle,
                                                    reportProvider
                                                        .getBillingCycleDropdown(
                                                            reportProvider
                                                                .selectedBillYear),
                                                    true,
                                                    readOnly: false,
                                                    controller: reportProvider
                                                        .billingcycleCtrl,
                                                    key: Keys.billReport
                                                        .BILL_REPORT_BILLING_CYCLE,
                                                    itemAsString: (i) =>
                                                        "${ApplicationLocalizations.of(context).translate(i['name'])}",
                                                  ),
                                                ],
                                              ),
                                            )),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Card(
                              margin: EdgeInsets.only(top: 15, bottom: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Column(
                                  children: [
                                    BillReport(onViewClick: showTable),
                                    CollectionReport(onViewClick: showTable),
                                    InactiveConsumerReport(
                                      onViewClick: showTable,
                                    ),
                                    ExpenseBillReport(
                                      onViewClick: showTable,
                                    ),
                                    VendorReport(
                                      onViewClick: showTable,
                                    ),
                                    MonthlyLedgerReport(
                                      onViewClick: showTable,
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Align(
                                alignment: Alignment.bottomCenter,
                                child: Footer())
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
