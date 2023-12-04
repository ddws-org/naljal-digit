import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// TODO 5: Import the app that you want to test
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/widgets/language_card.dart';
import 'Test Inputs/test_inputs.dart';
import 'search_Connection_test.dart' as search_Connection;
import 'create_consumer_test.dart' as create_consumer;
import 'update_Consumer_Test.dart' as update_consumer;
import 'generate_bill_non_metered_test.dart' as generate_bulk_demand;
import 'generate_bill_metered_test.dart' as generate_metered_bill;
import 'forgot_password_test.dart' as forgot_password;
import 'edit_profile_test.dart' as edit_profile;
import 'change_password_test.dart' as change_password;
import 'log_out_test.dart' as logout;
// import 'search_Connection_test.dart' as search_Connection;
// import 'create_consumer_test.dart' as create_consumer;
import 'update_expense.dart' as update_expense;
import 'add_expense.dart' as add_expense;
import 'dashboard_test.dart' as dashboard;
import 'house_hold_test.dart' as houseHold;



void main() {
  group('App Test', () {
    ///  Add the IntegrationTestWidgetsFlutterBinding and .ensureInitialized
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    ///Forgot Password Testing
    forgot_password.main();

    ///Login Testing
    /// Create your test case
    testWidgets("Login test", (tester) async {

      var loginTestData = getTestData();
      /// execute the app.main() function
      app.main();
      /// Wait until the app has settled
      await tester.pumpAndSettle(Duration(milliseconds: 1000));

      ///Language Selection Testing
      final selectLanguage = find.byType(LanguageCard).at(loginTestData['selectLanguage']);
      final selectLanButton = find.byKey(Keys.language.LANGUAGE_PAGE_CONTINUE_BTN);
      await tester.tap(selectLanguage);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.tap(selectLanguage);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.tap(selectLanButton);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));

      /// Login Testing
      final phoneNumber = find.byKey(Keys.login.LOGIN_PHONE_NUMBER_KEY);
      final password = find.byKey(Keys.login.LOGIN_PASSWORD_KEY);
      final login = find.byKey(Keys.login.LOGIN_BTN_KEY);
      await tester.enterText(phoneNumber, loginTestData['loginPhoneNumber']);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.ensureVisible(password);
      await tester.enterText(password, loginTestData['loginPassword']);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
      await tester.ensureVisible(login);
      await tester.tap(login);
      await tester.pumpAndSettle(Duration(milliseconds: 3000));
    });

    ///Edit Profile Testing
     edit_profile.main();
    //
    // ///Change Password Testing
     change_password.main();
    //
    // ///Search Connection Testing
     search_Connection.main();
    //
    // ///Create Consumer Testing
     create_consumer.main();
    //
    // ///Update Consumer Details Testing
     update_consumer.main();
    //
    // ///Generate Bulk Demand
     generate_bulk_demand.main();
    //
    // ///Generate Metered Bill
     generate_metered_bill.main();
    //
    dashboard.main();
    //
    // ///Log Out
     logout.main();

    ///Search Connection Testing
    //search_Connection.main();

    ///Create Consumer Testing
    // create_consumer.main();

    /// add expense
     add_expense.main();

    /// update expense
    update_expense.main();

    /// House hold regisiter
     houseHold.main();
  });
}