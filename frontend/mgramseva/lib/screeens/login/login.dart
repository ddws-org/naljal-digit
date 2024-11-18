import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/providers/authentication_provider.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/validators/validators.dart';
import 'package:mgramseva/widgets/button.dart';
import 'package:mgramseva/widgets/desktop_view.dart';
import 'package:mgramseva/widgets/heading_text.dart';
import 'package:mgramseva/widgets/logo.dart';
import 'package:mgramseva/widgets/mobile_view.dart';
import 'package:mgramseva/widgets/text_field_builder.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _LoginState();
  }
}

class _LoginState extends State<Login> {
  var mobileNumber = new TextEditingController();
  var userNamecontroller = new TextEditingController();
  var passwordcontroller = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  var autoValidation = false;
  var phoneNumberAutoValidation = false;
  FocusNode _numberFocus = new FocusNode();
  var passwordVisible = false;

  @override
  void initState() {
    _numberFocus.addListener(_onFocusChange);
    super.initState();
  }

  @override
  dispose(){
    _numberFocus.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange(){
    if(!_numberFocus.hasFocus){
      setState(() {
        phoneNumberAutoValidation = true;
      });
    }
  }

  void onChangeOfInput(){
    setState(() {
    });
  }

  saveandLogin(context) async {
    var authProvider =
    Provider.of<AuthenticationProvider>(context, listen: false);

    if (formKey.currentState!.validate()) {
      authProvider.validateLogin(context, userNamecontroller.text.trim(),
          passwordcontroller.text.trim());
    } else {
      autoValidation = true;
      authProvider.callNotifier();
    }
  }

  Widget getLoginCard() {
    return Card(
        child: Form(
            key: formKey,
            onChanged: onChangeOfInput,
            autovalidateMode: autoValidation
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: (Column(
              children: [
                Logo(),
                HeadingText(ApplicationLocalizations.of(context)
                    .translate(i18.login.LOGIN_LABEL)),
                BuildTextField(
                  i18.login.LOGIN_PHONE_NO,
                  userNamecontroller,
                  prefixText: '+91 - ',
                  isRequired: true,
                  inputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                  ],
                  focusNode: _numberFocus,
                  autoValidation: phoneNumberAutoValidation ? AutovalidateMode.always : AutovalidateMode.disabled,
                  maxLength: 10,
                  validator: Validators.mobileNumberValidator,
                  textInputType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  key: Keys.login.LOGIN_PHONE_NUMBER_KEY,
                ),
                BuildTextField(
                  i18.login.LOGIN_PASSWORD,
                  passwordcontroller,
                  isRequired: true,
                  obscureText: !passwordVisible,
                  suffixIcon: buildPasswordVisibility(),
                  maxLines: 1,
                  key: Keys.login.LOGIN_PASSWORD_KEY,
                  textInputAction: TextInputAction.done,
                  onSubmit: (value){
                    if(buttonStatus){
                      saveandLogin(context);
                    }
                  },
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, Routes.FORGOT_PASSWORD),
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8, top: 10, bottom: 10, right: 25),
                      child: new Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            ApplicationLocalizations.of(context)
                                .translate(i18.login.FORGOT_PASSWORD),
                            key: Keys.forgotPassword.FORGOT_PASSWORD_BUTTON,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0 ),
                  child: RichText(
                    maxLines: 3,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: '${ApplicationLocalizations.of(context).translate(i18.common.BY_CONTINUING_YOU_ACCEPT_OUR)} ',
                          style: TextStyle(
                              color: Colors.black
                          )
                        ),
                        TextSpan(
                          text: '${ApplicationLocalizations.of(context).translate(i18.common.PRIVACY_POLICY)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor, // set link color
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, Routes.PRIVACY_POLICY,arguments:true);
                            },
                        ),
                        TextSpan(
                            text: ' ${ApplicationLocalizations.of(context).translate(i18.common.AND)} ',
                            style: TextStyle(
                                color: Colors.black
                            )
                        ),
                        TextSpan(
                          text: '${ApplicationLocalizations.of(context).translate(i18.common.TERMS_OF_USE)}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor, // set link color
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushNamed(context, Routes.TERMS_OF_USE,arguments:true);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 15, left: 8, right: 8),
                  child: Button(
                      i18.common.CONTINUE, buttonStatus ? () => saveandLogin(context) : null),
                  key: Keys.login.LOGIN_BTN_KEY,),
                SizedBox(
                  height: 10,
                )
              ],
            ))));
  }

  Widget buildPasswordVisibility(){
    return IconButton(
      icon: Icon(
        passwordVisible
            ? Icons.visibility
            : Icons.visibility_off,
        color: Theme.of(context).primaryColorLight,
      ),
      onPressed: () {
        setState(() {
          passwordVisible = !passwordVisible;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
        child:Scaffold(body: LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 760) {
            return MobileView(getLoginCard());
          } else {
            return DesktopView(getLoginCard());
          }
        })));
  }

  bool get buttonStatus => userNamecontroller.text.trim().length == 10 && passwordcontroller.text.trim().length > 1;
}