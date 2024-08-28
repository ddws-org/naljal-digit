import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_methods.dart';

import 'bases_app_bar.dart';
import 'bottom_button_bar.dart';
import 'home_back.dart';

class ErrorPage extends StatelessWidget {
  final label;
  final bool isWithoutLogin;

  ErrorPage(this.label, {this.isWithoutLogin = false});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
         if (didPop) {    
          CommonMethods.home(); 
          return;
        }
      },
      child: Scaffold(
        appBar: isWithoutLogin
            ? AppBar(
                title: Text('mGramSeva'),
                automaticallyImplyLeading: false,
              )
            : BaseAppBar(
                Text(ApplicationLocalizations.of(context)
                    .translate(i18.common.MGRAM_SEVA)),
                AppBar(),
                <Widget>[Icon(Icons.more_vert)],
              ),
        body: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              isWithoutLogin
                  ? Text('')
                  : HomeBack(callback: CommonMethods.home),
              Card(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(30),
                      decoration: new BoxDecoration(color: Colors.red[900]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new Align(
                            alignment: Alignment.center,
                            child: Text(
                                ApplicationLocalizations.of(context)
                                    .translate(label),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Icon(
                            Icons.warning_rounded,
                            color: Colors.white,
                            size: 32,
                          )
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ))
            ])),
        bottomNavigationBar: BottomButtonBar(
          ApplicationLocalizations.of(context).translate(i18.common.BACK_HOME),
          CommonMethods.home,
        ),
      ),
    );
  }
}
