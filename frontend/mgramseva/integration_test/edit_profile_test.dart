import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'Test Inputs/test_inputs.dart';

void main() {
  testWidgets("Edit Profile Test", (tester) async {
    var editProfileTestData = getTestData();
     app.main();
     await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final appBar = find.byType(AppBar);
    await tester.tap(appBar);
    await tester.pumpAndSettle(Duration(seconds: 3));
    final tapAppDrawer = find.byIcon(Icons.menu);
    await tester.tap(tapAppDrawer);
    await tester.pumpAndSettle(Duration(seconds: 3));

    final tapEditProfileTile = find.byKey(Keys.editProfile.SIDE_BAR_EDIT_PROFILE_TILE_KEY);
    await tester.tap(tapEditProfileTile);
    await tester.pumpAndSettle(Duration(seconds: 3));

    final editProfileName = find.byKey(Keys.editProfile.EDIT_PROFILE_NAME_KEY);
    final editProfileEmail = find.byKey(Keys.editProfile.EDIT_PROFILE_E_MAIL_KEY);
    final editGender = find.widgetWithText(ListTile, ApplicationLocalizations.of(navigatorKey.currentContext!)
        .translate(editProfileTestData['editProfileGender']));
    final saveBtn = find.byKey(Keys.editProfile.EDIT_PROFILE_SAVE_BTN_KEY);

    await tester.enterText(editProfileName, '');
    await tester.pumpAndSettle(Duration(seconds: 3));
    await tester.enterText(editProfileName, editProfileTestData['editProfileName']);
    await tester.pumpAndSettle(Duration(seconds: 3));

    await tester.ensureVisible(editGender);
    await tester.tap(editGender);
    await tester.pumpAndSettle(Duration(seconds: 3));

    await tester.enterText(editProfileEmail, '');
    await tester.pumpAndSettle(Duration(seconds: 3));
    await tester.enterText(editProfileEmail, editProfileTestData['editProfileEmail']);
    await tester.pumpAndSettle(Duration(seconds: 3));

    await tester.ensureVisible(saveBtn);
    await tester.tap(saveBtn);
    await tester.pumpAndSettle(Duration(seconds: 5));
  });
}
