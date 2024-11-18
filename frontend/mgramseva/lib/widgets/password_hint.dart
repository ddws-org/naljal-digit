import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';

class PasswordHint extends StatelessWidget {
  final inputPassword;
  PasswordHint(this.inputPassword);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(color: Theme.of(context).highlightColor),
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(15),
      padding: EdgeInsets.all(5),
      child: (Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Theme.of(context).hintColor),
              Text(ApplicationLocalizations.of(context).translate(i18.password.PASSWORD_HINT),
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).hintColor))
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Text(
                ApplicationLocalizations.of(context).translate(i18.password.PASS_HINT_MIN_SIX_DIGITS),
                style: TextStyle(
                    fontSize: 16,
                    color: new RegExp(r'^(?=.{6,})').hasMatch(inputPassword)
                        ? Colors.green[900]
                        : Theme.of(context).hintColor),
              ),
              new RegExp(r'^(?=.{6,})').hasMatch(inputPassword)
                  ? Icon(
                      Icons.check,
                      color: Colors.green[900],
                    )
                  : Text("")
            ],
          ),
          SizedBox(height: 5),
          Row(children: [
            Text(
              ApplicationLocalizations.of(context).translate(i18.password.PASS_HINT_ATLEAST_ONE_SPECIAL_CHARACTER),
              style: TextStyle(
                  fontSize: 16,
                  color: RegExp(r'^(?=.*[^A-Za-z0-9])').hasMatch(inputPassword)
                      ? Colors.green[900]
                      : Theme.of(context).hintColor),
            ),
            new RegExp(r'^(?=.*[^A-Za-z0-9])').hasMatch(inputPassword)
                ? Icon(
                    Icons.check,
                    color: Colors.green[900],
                  )
                : Text("")
          ]),
          SizedBox(height: 5),
          Row(children: [
            Text(
              ApplicationLocalizations.of(context).translate(i18.password.PASS_HINT_ATLEAST_ONE_LETTER),
              style: TextStyle(
                  fontSize: 16,
                  color: RegExp(r'^(?=.*[a-zA-Z])').hasMatch(inputPassword)
                      ? Colors.green[900]
                      : Theme.of(context).hintColor),
            ),
            new RegExp(r'^(?=.*[a-zA-Z])').hasMatch(inputPassword)
                ? Icon(
                    Icons.check,
                    color: Colors.green[900],
                  )
                : Text("")
          ]),
          SizedBox(height: 5),
          Row(children: [
            Text(
              ApplicationLocalizations.of(context).translate(i18.password.PASS_HINT_ATLEAST_ONE_NUMBER),
              style: TextStyle(
                  fontSize: 16,
                  color: RegExp(r'^(?=.*?[0-9])').hasMatch(inputPassword)
                      ? Colors.green[900]
                      : Theme.of(context).hintColor),
            ),
            new RegExp(r'^(?=.*?[0-9])').hasMatch(inputPassword)
                ? Icon(
                    Icons.check,
                    color: Colors.green[900],
                  )
                : Text("")
          ]),
          SizedBox(height: 5),
          Row(children: [
            Text(
              ApplicationLocalizations.of(context).translate(i18.password.PASS_HINT_ATLEAST_ONE_UPPERCASE),
              style: TextStyle(
                  fontSize: 16,
                  color: RegExp(r'^(?=.*[A-Z])').hasMatch(inputPassword)
                      ? Colors.green[900]
                      : Theme.of(context).hintColor),
            ),
            new RegExp(r'^(?=.*[A-Z])').hasMatch(inputPassword)
                ? Icon(
                    Icons.check,
                    color: Colors.green[900],
                  )
                : Text("")
          ])
        ],
      )),
    );
  }
}
