
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// TODO 5: Import the app that you want to test
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/global_variables.dart';

import 'Test Inputs/test_inputs.dart';


void main() {

    testWidgets("add expense app test", (tester) async {
      var addExpenseTestData = getTestData();
      app.main();
      await tester.pumpAndSettle(Duration(milliseconds: 2000));
      final appBar = find.byType(AppBar);
      await tester.tap(appBar);
      await tester.pumpAndSettle(Duration(seconds: 3));
      final addExpense = find.byType(GridTile).at(3);
      await tester.tap(addExpense);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));

      final phoneNumber = find.byKey(Keys.expense.VENDOR_MOBILE_NUMBER);
      final expenseAmount = find.byKey(Keys.expense.EXPENSE_AMOUNT);
      final expenseBillDate = find.byKey(Keys.expense.EXPENSE_BILL_DATE);
      final addExpenseBtn = find.byKey(Keys.expense.EXPENSE_SUBMIT);
      final expenseType = find.byKey(Keys.expense.EXPENSE_TYPE);
      final selectExpenseType = find.widgetWithText(ListTile, ApplicationLocalizations.of(navigatorKey.currentContext!).
      translate(addExpenseTestData['addExpenseType']));
      final vendorNameAutoComplete = find.byKey(Keys.expense.VENDOR_NAME);

      /// selecting expense type
      await tester.ensureVisible(expenseType);
      await tester.tap(expenseType);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.tap(selectExpenseType);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));

      await tester.enterText(vendorNameAutoComplete, addExpenseTestData['expenseVendorName']);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.enterText(expenseAmount, addExpenseTestData['expenseVendorAmount']);
      await tester.pumpAndSettle(Duration(milliseconds: 2000));

      final findDatePicker = find.byKey(Keys.expense.EXPENSE_BILL_DATE);
      final findEditDateIcon = find.byIcon(Icons.edit);
      final findDateTextField = find.widgetWithText(TextField, DateFormats.getFilteredDate(
          DateTime.now().toLocal().toString(),
          dateFormat: "d/M/yyyy") );
      final findOKButtonInDate = find.text('OK');
      await tester.ensureVisible(findDatePicker);
      await tester.tap(findDatePicker);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.tap(findEditDateIcon);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.enterText(findDateTextField, '12/11/2021');
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.tap(findOKButtonInDate);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));

      // final partyDatePicker = find.byKey(Keys.expense.EXPENSE_PARTY_DATE);
      // final findPartyEditDateIcon = find.byIcon(Icons.edit);
      // final findPartyDateTextField = find.widgetWithText(TextField, DateFormats.getFilteredDate(
      //     DateTime.now().toLocal().toString(),
      //     dateFormat: "dd/MM/yyyy") );
      // final findPartyOKButtonInDate = find.text('OK');
      // await tester.ensureVisible(partyDatePicker);
      // await tester.tap(partyDatePicker);
      // await tester.pumpAndSettle(Duration(milliseconds: 3000));
      // await tester.tap(findPartyEditDateIcon);
      // await tester.pumpAndSettle(Duration(milliseconds: 3000));
      // await tester.enterText(findPartyDateTextField, '12/11/2021');
      // await tester.pumpAndSettle(Duration(milliseconds: 3000));
      // await tester.tap(findPartyOKButtonInDate);
      // await tester.pumpAndSettle(Duration(milliseconds: 5000));

      await tester.ensureVisible(addExpenseBtn);
      await tester.tap(addExpenseBtn);
      await tester.pumpAndSettle(Duration(milliseconds: 5000));

      await tester.ensureVisible(find.byIcon(Icons.arrow_left));
      await tester.pumpAndSettle(Duration(seconds: 3));
      await tester.tap(find.byIcon(Icons.arrow_left));
      await tester.pumpAndSettle(Duration(seconds: 5));

    });
}