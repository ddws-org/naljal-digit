import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/model/change_password_details/change_password_details.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/change_password_details_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/validators/validators.dart';
import 'package:mgramseva/widgets/bases_app_bar.dart';
import 'package:mgramseva/widgets/bottom_button_bar.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/form_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/password_hint.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:mgramseva/widgets/text_field_builder.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:provider/provider.dart';

class ChangePassword extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _ChangePasswordState();
  }
}

class _ChangePasswordState extends State<ChangePassword> {
  var password = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    var passwordProvider =
        Provider.of<ChangePasswordProvider>(context, listen: false);
    passwordProvider.changePasswordDetails = ChangePasswordDetails();
    super.initState();
  }

  saveInput(context) async {
    setState(() {
      password = context;
    });
  }

  saveInputandchangepass(
      context, passwordDetails, ChangePasswordDetails password) async {
    var changePasswordProvider =
        Provider.of<ChangePasswordProvider>(context, listen: false);
    if (formKey.currentState!.validate()) {
      var commonProvider = Provider.of<CommonProvider>(context, listen: false);
      var data = {
        "userName": commonProvider.userDetails!.userRequest!.userName,
        "existingPassword": password.existingPassword,
        "newPassword": password.newPassword,
        "tenantId": commonProvider.userDetails!.selectedtenant!.code,
        "type": commonProvider.userDetails!.userRequest!.type
      };

      changePasswordProvider.changePassword(data, context);
    } else {
      changePasswordProvider.autoValidation = true;
      changePasswordProvider.callNotifier();
    }
  }

  Widget builduserView(ChangePasswordDetails passwordDetails) {
    return Container(
        child: FormWrapper(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeBack(),
          Consumer<ChangePasswordProvider>(
            builder: (_, changePasswordProvider, child) => Form(
              key: formKey,
              autovalidateMode: changePasswordProvider.autoValidation
                  ? AutovalidateMode.always
                  : AutovalidateMode.disabled,
              child: Card(
                  child: Column(
                children: [
                  BuildTextField(
                    i18.password.CURRENT_PASSWORD,
                    passwordDetails.currentpasswordCtrl,
                    obscureText: true,
                    isRequired: true,
                    maxLength: 10,
                    maxLines: 1,
                    onChange: (value) => saveInput(value),
                    key: Keys.changePassword.CURRENT_PASSWORD_KEY,
                  ),
                  BuildTextField(
                    i18.password.NEW_PASSWORD,
                    passwordDetails.newpasswordCtrl,
                    obscureText: true,
                    isRequired: true,
                    maxLength: 10,
                    maxLines: 1,
                    validator: (val) => Validators.passwordComparision(
                        val, ApplicationLocalizations.of(context).translate(i18.password.NEW_PASSWORD_ENTER)),
                    onChange: (value) => saveInput(value),
                    key: Keys.changePassword.NEW_PASSWORD_KEY,
                  ),
                  BuildTextField(
                    i18.password.CONFIRM_PASSWORD,
                    passwordDetails.confirmpasswordCtrl,
                    obscureText: true,
                    isRequired: true,
                    maxLength: 10,
                    maxLines: 1,
                    validator: (val) => Validators.passwordComparision(
                        val,
                        ApplicationLocalizations.of(context).translate(i18.password.CONFIRM_PASSWORD_ENTER),
                        passwordDetails.newpasswordCtrl.text),
                    onChange: (value) => saveInput(value),
                    key: Keys.changePassword.CONFIRM_PASSWORD_KEY,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  PasswordHint(password)
                ],
              )),
            ),
          )
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var changePasswordProvider =
        Provider.of<ChangePasswordProvider>(context, listen: false);
    return FocusWatcher(
        child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: BaseAppBar(
          Text(i18.common.MGRAM_SEVA),
          AppBar(),
          <Widget>[Icon(Icons.more_vert)],
        ),
        drawer: DrawerWrapper(
          Drawer(child: SideBar()),
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            builduserView(changePasswordProvider.changePasswordDetails),
            Footer()
          ],
        )),
        bottomNavigationBar: BottomButtonBar(
            i18.password.CHANGE_PASSWORD,
            () => saveInputandchangepass(
                context,
                changePasswordProvider.changePasswordDetails.getText(),
                changePasswordProvider.changePasswordDetails),
        key: Keys.changePassword.CHANGE_PASSWORD_BTN_KEY,)));
  }
}
