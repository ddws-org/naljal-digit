import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/widgets/bottom_button_bar.dart';
import 'Test Inputs/test_inputs.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';



void main() {
  testWidgets("Generate Demand Non-Metered Test", (tester) async {
    var generateBulkDemandTestData = getTestData();
    app.main();
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    final appBar = find.byType(AppBar);
    await tester.tap(appBar);
    await tester.pumpAndSettle(Duration(seconds: 3));

    final generateBulkDemand = find.widgetWithText(GridTile,
        ApplicationLocalizations.of(navigatorKey.currentContext!).translate('CORE_GENERATE_DEMAND'));
    await tester.tap(generateBulkDemand);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final findBillingYearField = find.byKey(Keys.bulkDemand.BULK_DEMAND_BILLING_YEAR);
    final selectBillingYear = find.widgetWithText(ListTile,
        ApplicationLocalizations.of(navigatorKey.currentContext!).translate(generateBulkDemandTestData['bulkDemandBillingYear']));

    final findBillingCycleField = find.byKey(Keys.bulkDemand.BULK_DEMAND_BILLING_CYCLE);
    final selectBillingCycle = find.widgetWithText(ListTile,
        ApplicationLocalizations.of(navigatorKey.currentContext!)
            .translate(generateBulkDemandTestData['bulkDemandBillingCycle']) +
            " - " +
            generateBulkDemandTestData['bulkDemandBillingYear'].substring(0,4));
    final generateDemandBtn = find.byKey(Keys.bulkDemand.GENERATE_BILL_BTN);
    final backHome = find.widgetWithText(BottomButtonBar, ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.BACK_HOME));

    await tester.ensureVisible(findBillingYearField);
    await tester.tap(findBillingYearField);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(selectBillingYear);
    await tester.tap(selectBillingYear);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    await tester.ensureVisible(findBillingCycleField);
    await tester.enterText(findBillingCycleField, generateBulkDemandTestData['bulkDemandBillingCycle']);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(selectBillingCycle);
    await tester.tap(selectBillingCycle);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    await tester.ensureVisible(generateDemandBtn);
    await tester.tap(generateDemandBtn);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    await tester.tap(backHome);
    await tester.pumpAndSettle(Duration(seconds: 5));

  });
}