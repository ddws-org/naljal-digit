import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/models.dart';

import 'Test Inputs/test_inputs.dart';

void main() {

  testWidgets("dashboard app test", (tester) async {
    var dashboardTestData = getTestData();
    app.main();
    await tester.pumpAndSettle(Duration(milliseconds: 2000));
    final appBar = find.byType(AppBar);
    await tester.tap(appBar);
    await tester.pumpAndSettle(Duration(seconds: 3));
    final dashboard = find.byType(GridTile).at(8);
    await tester.tap(dashboard);
    await tester.pumpAndSettle(Duration(milliseconds: 5000));

    final month = find.widgetWithText(Container, ApplicationLocalizations.of(navigatorKey.currentContext!).translate(Constants.MONTHS[dashboardTestData['graphicalDashboardMonthIndex']])).first;
    print(ApplicationLocalizations.of(navigatorKey.currentContext!).translate(Constants.MONTHS[5]));
    await tester.ensureVisible(month);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(month);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    // final tabSelection = find.byKey(Keys.dashboard.DASHBOARD_SEARCH);
    final dashboardSearch = find.byKey(Keys.dashboard.DASHBOARD_SEARCH);
    final datePicker = find.byKey(Keys.dashboard.DASHBOARD_DATE_PICKER);
    final expenditureTab = find.widgetWithText(GestureDetector, ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.dashboard.EXPENDITURE)).first;
    final tab = find.byKey(Keys.dashboard.SECOND_TAB);
    final tab2 = find.byKey(Keys.dashboard.THIRD_TAB);
    final share = find.byKey(Keys.common.SHARE,);

    // await tester.pumpAndSettle(Duration(milliseconds: 3000));
    // await tester.scrollUntilVisible(dashboard_search, 100);
    // await tester.ensureVisible(dashboard_search);
    // await tester.pumpAndSettle(Duration(milliseconds: 1000));
    // await tester.enterText(dashboard_search, TestInputs.expense.BILL_ID);
    // await tester.pumpAndSettle(Duration(milliseconds: 3000));

    /// date picker
    await tester.ensureVisible(datePicker);
    await tester.tap(datePicker);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    var date = DateTime.now();
    print(DateFormats.getMonthAndYear(DatePeriod(DateTime(date.year, date.month - 1, 1), DateTime(date.year, date.month, 0, 23,59, 59), DateType.MONTH), navigatorKey.currentContext!));
    final dateSelection = find.widgetWithText(InkWell, DateFormats.getMonthAndYear(DatePeriod(DateTime(date.year, date.month - 1, 1), DateTime(date.year, date.month, 0, 23,59, 59), DateType.MONTH), navigatorKey.currentContext!));
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    await tester.tap(dateSelection);
    await tester.pumpAndSettle(Duration(milliseconds: 5000));

    /// collection tab selection
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    await tester.tap(tab);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    await tester.tap(tab2);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    /// expenditure tab
    await tester.ensureVisible(expenditureTab);
    await tester.pumpAndSettle(Duration(milliseconds: 2000));
    await tester.tap(expenditureTab);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    await tester.tap(tab);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final pagination = find.byKey(Keys.common.PAGINATION_DROPDOWN);
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    await tester.tap(pagination);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    final pagingItem = find.byKey(Keys.common.PAGINATION_COUNT).first;
    await tester.ensureVisible(pagingItem);
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    await tester.tap(pagingItem);
    await tester.pumpAndSettle(Duration(milliseconds: 5000));

    /// Searching items
    await tester.ensureVisible(dashboardSearch);
    await tester.enterText(dashboardSearch, dashboardTestData['dashboardSearch']);
    await tester.pumpAndSettle(Duration(milliseconds: 5000));

    // await tester.ensureVisible(share);
    // await tester.tap(share);
    // await tester.pumpAndSettle(Duration(milliseconds: 12000));
    // await tester.pumpAndSettle(Duration(milliseconds: 12000));
  });
}