
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// TODO 5: Import the app that you want to test
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/widgets/bottom_button_bar.dart';
import 'package:mgramseva/widgets/short_button.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';

import 'Test Inputs/test_inputs.dart';


void main() {

  testWidgets("update expense app test", (tester) async {
    var updateExpenseTestData = getTestData();
    app.main();
    await tester.pumpAndSettle(Duration(milliseconds: 2000));

    final appBar = find.byType(AppBar);
    await tester.tap(appBar);
    await tester.pumpAndSettle(Duration(seconds: 3));
    final updateExpense = find.byType(GridTile).at(4);
    await tester.tap(updateExpense);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));


    final vendorName = find.byKey(Keys.expense.SEARCH_VENDOR_NAME);
    final updateExpenditure = find.widgetWithText(ShortButton, ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.expense.UPDATE_EXPENDITURE)).first;
    final checkBox = find.byType(Checkbox);
    final submitButton = find.widgetWithText(BottomButtonBar, ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.SUBMIT));
    final expenseType = find.byKey(Keys.expense.SEARCH_EXPENSE_TYPE);
    final selectExpenseType = find.widgetWithText(ListTile, ApplicationLocalizations.of(navigatorKey.currentContext!).translate
      (updateExpenseTestData['searchExpenseType']));
    final billId = find.byKey(Keys.expense.SEARCH_EXPENSE_BILL_ID);

    /// set vendor name
    await tester.enterText(vendorName, updateExpenseTestData['expenseVendorName']);
    await tester.pumpAndSettle(Duration(milliseconds: 1000));
    await tester.enterText(vendorName, '');
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    /// selecting expense type
    await tester.ensureVisible(expenseType);
    await tester.tap(expenseType);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(selectExpenseType);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final showType = find.byKey(Keys.expense.SEARCH_EXPENSE_SHOW);
    await tester.ensureVisible(showType);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(showType);

    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.enterText(billId, updateExpenseTestData['searchExpenseBillID']);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.enterText(billId, '');
    await tester.pumpAndSettle(Duration(milliseconds: 1000));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle(Duration(seconds: 5));

    /// picking the first expense from the result
    await tester.ensureVisible(updateExpenditure);
    await tester.pumpAndSettle(Duration(milliseconds: 2000));
    await tester.tap(updateExpenditure);
    await tester.pumpAndSettle(Duration(seconds: 5));

    await tester.ensureVisible(checkBox);
    await tester.pumpAndSettle(Duration(milliseconds: 2000));
    await tester.tap(checkBox);
    await tester.pumpAndSettle(Duration(seconds: 3));

    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle(Duration(milliseconds: 2000));
    await tester.tap(submitButton);
    await tester.pumpAndSettle(Duration(seconds: 8));

    final backHome = find.widgetWithText(BottomButtonBar, ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.common.BACK_HOME));
    await tester.tap(backHome);
    await tester.pumpAndSettle(Duration(seconds: 5));
  });
}