import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'Test Inputs/test_inputs.dart';

void main() {
  testWidgets("Change Password Test", (tester) async {

    var changePasswordTestData = getTestData();
    app.main();
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    final appBar = find.byType(AppBar);
    await tester.tap(appBar);
    await tester.pumpAndSettle(Duration(seconds: 3));

    final tapAppDrawer = find.byIcon(Icons.menu);
    await tester.tap(tapAppDrawer);
    await tester.pumpAndSettle(Duration(seconds: 3));

    final tapChangePasswordProfileTile = find.byKey(Keys.changePassword.SIDE_BAR_CHANGE_PASSWORD_TILE_KEY);
    await tester.tap(tapChangePasswordProfileTile);
    await tester.pumpAndSettle(Duration(seconds: 3));

    final currentPasswordField = find.byKey(Keys.changePassword.CURRENT_PASSWORD_KEY);
    final newPasswordField = find.byKey(Keys.changePassword.NEW_PASSWORD_KEY);
    final confirmPasswordField = find.byKey(Keys.changePassword.CONFIRM_PASSWORD_KEY);
    final changePasswordBtn = find.byKey(Keys.changePassword.CHANGE_PASSWORD_BTN_KEY);

    await tester.enterText(currentPasswordField, changePasswordTestData['currentPassword']);
    await tester.pumpAndSettle(Duration(seconds: 3));

    await tester.ensureVisible(newPasswordField);
    await tester.enterText(newPasswordField, changePasswordTestData['newPassword']);
    await tester.pumpAndSettle(Duration(seconds: 3));

    await tester.ensureVisible(confirmPasswordField);
    await tester.enterText(confirmPasswordField, changePasswordTestData['confirmNewPassword']);
    await tester.pumpAndSettle(Duration(seconds: 3));

    await tester.ensureVisible(changePasswordBtn);
    await tester.tap(changePasswordBtn);
    await tester.pumpAndSettle(Duration(seconds: 5));
  });
}
