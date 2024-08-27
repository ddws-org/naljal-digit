import 'package:flutter/material.dart';
import 'package:mgramseva/model/success_handler.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/success_page.dart';

import 'footer.dart';

class NoLoginSuccess extends StatelessWidget {
  final SuccessHandler successHandler;
  final VoidCallback? callBack;
  final VoidCallback? callBackWhatsApp;
  final VoidCallback? callBackDownload;
  final VoidCallback? callBackPrint;
  final bool? backButton;
  final bool isWithoutLogin;
  final bool isConsumer;
  final String? amount;

  NoLoginSuccess(this.successHandler,
      {this.callBack,
      this.amount,
      this.callBackWhatsApp,
      this.callBackDownload,
      this.callBackPrint,
      this.backButton,
      this.isWithoutLogin = false,
      this.isConsumer = false});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          backButton == true
              ? HomeBack(callback: CommonMethods.home)
              : Text(''),
          Card(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SuccessPage(successHandler.header,
                      subTextHeader: successHandler.subHeaderFun != null
                          ? successHandler.subHeaderFun!()
                          : successHandler.subHeader,
                      amount: amount,
                      subText: successHandler.subTextFun != null
                          ? successHandler.subTextFun!()
                          : successHandler.subHeaderText),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 10, bottom: 20, top: 20, right: 10),
                        child: Text(
                          ApplicationLocalizations.of(context).translate(
                              successHandler.subtitleFun != null
                                  ? successHandler.subtitleFun!()
                                  : successHandler.subtitle),
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400),
                          textAlign: TextAlign.start,
                        ),
                      )),
                  Visibility(
                    visible: successHandler.downloadLink == null &&
                        successHandler.whatsAppShare == null &&
                        successHandler.downloadLinkLabel == null,
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Visibility(
                        visible: successHandler.downloadLink != null,
                        child: TextButton.icon(
                          onPressed: callBackDownload,
                          icon: Icon(Icons.download_sharp),
                          label: Text(
                              ApplicationLocalizations.of(context).translate(
                                  successHandler.downloadLinkLabel != null
                                      ? successHandler.downloadLinkLabel!
                                      : ''),
                              textScaleFactor: MediaQuery.of(context).size.width>360?0.9:0.68,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor)),
                        ),
                      )),
                      Expanded(
                          child: Visibility(
                        visible: successHandler.printLabel != null,
                        child: TextButton.icon(
                          onPressed: callBackPrint,
                          icon: Icon(
                            Icons.print,
                            color: Theme.of(context).primaryColor,
                          ),
                          label: Text(
                              ApplicationLocalizations.of(context).translate(
                                  successHandler.printLabel != null
                                      ? successHandler.printLabel!
                                      : ''),
                              textScaleFactor: MediaQuery.of(context).size.width>360?0.9:0.68,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context).primaryColor)),
                        ),
                      )),
                      Expanded(
                          child: Visibility(
                        visible: successHandler.whatsAppShare != null,
                        child: TextButton.icon(
                          onPressed: callBackWhatsApp,
                          icon: (Image.asset('assets/png/whats_app.png')),
                          label: Text(
                            ApplicationLocalizations.of(context)
                                .translate(i18.common.SHARE_BILL),
                            textScaleFactor: MediaQuery.of(context).size.width>360?0.9:0.68,
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Footer(),
                ],
              ))
        ]));
  }
}
