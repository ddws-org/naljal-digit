import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/providers/forgot_password_provider.dart';

import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/validators/validators.dart';
import 'package:mgramseva/widgets/button.dart';
import 'package:mgramseva/widgets/desktop_view.dart';
import 'package:mgramseva/widgets/logo.dart';
import 'package:mgramseva/widgets/mobile_view.dart';
import 'package:mgramseva/widgets/text_field_builder.dart';
import 'package:provider/provider.dart';

class ForgotPassword extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _ForgotPasswordState();
  }
}

class _ForgotPasswordState extends State<ForgotPassword> {
  var mobileNumber = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  var autoValidation = false;
  var phoneNumberAutoValidation = false;
  FocusNode _numberFocus = new FocusNode();

  @override
  void initState() {
    _numberFocus.addListener(_onFocusChange);
    super.initState();
  }

  dispose() {
    _numberFocus.addListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (!_numberFocus.hasFocus) {
      setState(() {
        phoneNumberAutoValidation = true;
      });
    }
  }

  saveInputAndCall(context) async {
    var otpProvider =
        Provider.of<ForgotPasswordProvider>(context, listen: false);
    if (formKey.currentState!.validate()) {
      otpProvider.otpForResetPassword(context, mobileNumber.text.trim());
      //Navigator.of(context).pushNamedAndRemoveUntil(Routes.RESET_PASSWORD, (route) => false);
    } else {
      setState(() {
        autoValidation = true;
      });
    }
  }

  getForgotPasswordCard() {
    return Card(
        child: (Column(
      children: [
        Logo(),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
              ApplicationLocalizations.of(context)
                  .translate(i18.login.FORGOT_PASSWORD),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 20, bottom: 20, top: 20),
              child: Text(
                  ApplicationLocalizations.of(context)
                      .translate(i18.common.RESET_PASSWORD_LABEL),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
            )),
        Form(
          key: formKey,
          autovalidateMode: autoValidation
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: BuildTextField(
            i18.common.PHONE_NUMBER,
            mobileNumber,
            prefixText: '+91 - ',
            isRequired: true,
            inputFormatter: [
              FilteringTextInputFormatter.allow(RegExp("[0-9]"))
            ],
            focusNode: _numberFocus,
            autoValidation: phoneNumberAutoValidation
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            maxLength: 10,
            validator: Validators.mobileNumberValidator,
            textInputType: TextInputType.phone,
            key: Keys.forgotPassword.FORGOT_PASSWORD_MOBILE_NO
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
            padding: EdgeInsets.all(15),
            child:
                Button(i18.common.CONTINUE, () => saveInputAndCall(context),
                key: Keys.forgotPassword.FORGOT_PASSWORD_CONTINUE_BTN,)),
      ],
    )));
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(child: Scaffold(body: LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 760) {
        return MobileView(getForgotPasswordCard());
      } else {
        return DesktopView(getForgotPasswordCard());
      }
    })));
  }
}
