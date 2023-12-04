import 'package:flutter_test/flutter_test.dart';
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/widgets/language_card.dart';

import 'Test Inputs/test_inputs.dart';

void main() {

  testWidgets("Forgot Password Test", (tester) async {
    var forgotPasswordTestData = getTestData();
    app.main();
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final selectLanguage = find.byType(LanguageCard).at(forgotPasswordTestData['selectLanguage']);
    final selectLanButton = find.byKey(Keys.language.LANGUAGE_PAGE_CONTINUE_BTN);
    await tester.tap(selectLanguage);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(selectLanguage);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
    await tester.tap(selectLanButton);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final forgotPassword = find.byKey(Keys.forgotPassword.FORGOT_PASSWORD_BUTTON);
    await tester.tap(forgotPassword);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final enterMobileNumber = find.byKey(Keys.forgotPassword.FORGOT_PASSWORD_MOBILE_NO);
    await tester.ensureVisible(enterMobileNumber);
    await tester.enterText(enterMobileNumber, forgotPasswordTestData['forgotPasswordMobileNumber']);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final continueBtn = find.byKey(Keys.forgotPassword.FORGOT_PASSWORD_CONTINUE_BTN);
    await tester.ensureVisible(continueBtn);
    await tester.tap(continueBtn);
    await tester.pumpAndSettle(Duration(milliseconds: 3000));
  });
}