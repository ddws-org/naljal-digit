import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/global_variables.dart';

import 'Test Inputs/test_inputs.dart';


void main() {

  testWidgets("Search Connection Test", (tester) async {
    var searchConnectionTestData = getTestData();
    app.main();
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    /// Open Collect Payment Screen
    final collectPayment = find.widgetWithText(GridTile,
        ApplicationLocalizations.of(navigatorKey.currentContext!).translate('CORE_COLLECT_PAYMENTS'));
    await tester.tap(collectPayment);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final nameSearch = find.byKey(Keys.searchConnection.SEARCH_NAME_KEY);
    final phoneSearch = find.byKey(Keys.searchConnection.SEARCH_PHONE_NUMBER_KEY);
    final searchConnectionBtn = find.byKey(Keys.searchConnection.SEARCH_BTN_KEY);
    final tapShowMore = find.byKey(Keys.searchConnection.SHOW_MORE_BTN);
    final oldIDSearch = find.byKey(Keys.searchConnection.SEARCH_OLD_ID_KEY);
    final newIDSearch = find.byKey(Keys.searchConnection.SEARCH_NEW_ID_KEY);
    final backButton = find.byIcon(Icons.arrow_left);

    await tester.enterText(phoneSearch, searchConnectionTestData['searchConnectionMobileNumber']);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(searchConnectionBtn);
    await tester.tap(searchConnectionBtn);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(backButton);
    await tester.pumpAndSettle(Duration(seconds: 5));
    await tester.tap(backButton);
    await tester.pumpAndSettle(Duration(seconds: 5));

    await tester.tap(collectPayment);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(nameSearch);
    await tester.enterText(nameSearch, searchConnectionTestData['searchConnectionName']);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(searchConnectionBtn);
    await tester.tap(searchConnectionBtn);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(backButton);
    await tester.pumpAndSettle(Duration(milliseconds: 5000));
    await tester.tap(backButton);
    await tester.pumpAndSettle(Duration(milliseconds: 5000));


    await tester.tap(collectPayment);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(tapShowMore);
    await tester.tap(tapShowMore);
    await tester.pumpAndSettle(Duration(seconds: 3));
    await tester.ensureVisible(oldIDSearch);
    await tester.enterText(oldIDSearch, searchConnectionTestData['searchConnectionOldConnectionID']);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(searchConnectionBtn);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(backButton);
    await tester.tap(backButton);
    await tester.pumpAndSettle(Duration(seconds: 5));
    await tester.ensureVisible(backButton);
    await tester.tap(backButton);
    await tester.pumpAndSettle(Duration(seconds: 5));

    await tester.tap(collectPayment);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(tapShowMore);
    await tester.tap(tapShowMore);
    await tester.pumpAndSettle(Duration(seconds: 3));
    await tester.ensureVisible(newIDSearch);
    await tester.enterText(newIDSearch, searchConnectionTestData['searchConnectionNewConnectionID']);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(searchConnectionBtn);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(backButton);
    await tester.pumpAndSettle(Duration(seconds: 5));
    await tester.ensureVisible(backButton);
    await tester.tap(backButton);
    await tester.pumpAndSettle(Duration(seconds: 5));

  });
}