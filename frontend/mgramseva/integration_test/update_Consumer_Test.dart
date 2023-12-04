import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/widgets/short_button.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'Test Inputs/test_inputs.dart';


void main() {
  testWidgets("Update Consumer Test", (tester) async {
    var updateConsumerTestData = getTestData();
    app.main();
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    final appBar = find.byType(AppBar);
    await tester.tap(appBar);
    await tester.pumpAndSettle(Duration(seconds: 3));

    final updateConsumer = find.widgetWithText(GridTile,
        ApplicationLocalizations.of(navigatorKey.currentContext!).translate('CORE_UPDATE_CONSUMER_DETAILS'));
    await tester.tap(updateConsumer);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final phoneSearch = find.byKey(Keys.searchConnection.SEARCH_PHONE_NUMBER_KEY);
    final searchConnectionBtn = find.byKey(Keys.searchConnection.SEARCH_BTN_KEY);
    final editConsumerDetailsBtn = find.widgetWithText(ShortButton,
        ApplicationLocalizations.of(navigatorKey.currentContext!).translate(i18.
        searchWaterConnection.HOUSE_DETAILS_EDIT)).first;

    final findPropertyType = find.byKey(Keys.createConsumer.CONSUMER_PROPERTY_KEY);
    final selectPropertyType = find.widgetWithText(ListTile,
        ApplicationLocalizations.of(navigatorKey.currentContext!).translate(updateConsumerTestData['updateConsumerProperty']));
    final checkBox = find.byType(Checkbox);

    await tester.enterText(phoneSearch, updateConsumerTestData['updateConsumerSearchMobileNumber']);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(searchConnectionBtn);
    await tester.tap(searchConnectionBtn);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    await tester.ensureVisible(editConsumerDetailsBtn);
    await tester.tap(editConsumerDetailsBtn);
    await tester.pumpAndSettle(Duration(milliseconds: 5000));

    ///Change property type
    await tester.ensureVisible(findPropertyType);
    await tester.tap(findPropertyType);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.ensureVisible(selectPropertyType);
    await tester.tap(selectPropertyType);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    ///Mark Connection as Inactive
    if(updateConsumerTestData['updateConsumerMarkConnectionInactive'] == 'Yes'){
      await tester.ensureVisible (checkBox);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.tap(checkBox);
      await tester.pumpAndSettle(Duration(seconds: 3));
  }else{}

    final updateConsumerSubmitBtn = find.byKey(Keys.createConsumer.CREATE_CONSUMER_BTN_KEY);

    await tester.ensureVisible(updateConsumerSubmitBtn);
    await tester.tap(updateConsumerSubmitBtn);
    await tester.pumpAndSettle(Duration(seconds: 3));

  });
}