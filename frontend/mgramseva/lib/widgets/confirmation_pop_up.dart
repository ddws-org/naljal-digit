import 'package:flutter/material.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';


import '../utils/color_codes.dart';

class ConfirmationPopUp extends StatefulWidget {
  final Function()? onConfirm;
  final String? cancelLabel;
  final String? confirmLabel;
  final String? textString;
  final String? subTextString;

  ConfirmationPopUp(
      {this.textString,
      this.subTextString,
      this.cancelLabel,
      this.confirmLabel,
      this.onConfirm});
  @override
  State<StatefulWidget> createState() {
    return _ConfirmationPopUpState();
  }
}

class _ConfirmationPopUpState extends State<ConfirmationPopUp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle
                ),
                alignment: Alignment.center,
                constraints: BoxConstraints(
                  minHeight: 160,
                  maxHeight: 190
                ),
                width: MediaQuery.of(context).size.width > 720 ? MediaQuery.of(context).size.width / 3.5 : MediaQuery.of(context).size.width ,
                padding: EdgeInsets.only(right: 8.0, left: 8.0),
                child: Card(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                        Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                              child: Container(
                                width: MediaQuery.of(context).size.width > 720 ? MediaQuery.of(context).size.width / 4 : MediaQuery.of(context).size.width / 1.25,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width > 720 ? 16.0 :  8.0,
                                      top: 16.0),
                                  child: Text(
                                    ApplicationLocalizations.of(context).translate(
                                        widget.textString ?? ''),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColorDark),
                                    textAlign: TextAlign.left,
                                    softWrap: true,
                                  )))),
                          Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Theme.of(context).primaryColorLight,
                                      size: 20.0,
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                  )))]
                     ),
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            alignment: Alignment.topLeft,
                              child: Container(
                                  width: MediaQuery.of(context).size.width > 720 ? MediaQuery.of(context).size.width / 4 : MediaQuery.of(context).size.width / 1.25,
                                  child:Padding(
                                    padding: EdgeInsets.only(left: MediaQuery.of(context).size.width > 720 ? 16.0 : 8.0),
                                    child: Text(
                                  ApplicationLocalizations.of(context).translate(
                                      widget.subTextString ?? ''),
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColorDark),
                                  textAlign: TextAlign.left,
                                )))),
                           SizedBox(
                             height: 20,
                           ),
                           Padding(
                              padding: EdgeInsets.only(left: MediaQuery.of(context).size.width > 720 ? 8.0 : 4.0,
                                  right: MediaQuery.of(context).size.width > 720 ? 8.0 : 4.0, top: 4.0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                        onTap: () async {
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(4.0),
                                          height: 35,
                                          width: MediaQuery.of(context).size.width > 720 ? MediaQuery.of(context).size.width / 10  : MediaQuery.of(context).size.width / 2.5,
                                          decoration: BoxDecoration(
                                            color:
                                            Theme.of(context).disabledColor,
                                            border: Border(bottom: BorderSide(color: ColorCodes.BUTTON_BOTTOM, width: 2))
                                          ),
                                          child: Center(
                                              child: Text(
                                                ApplicationLocalizations.of(context)
                                                    .translate(widget.cancelLabel ?? i18.common.CORE_CANCEL),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              )),
                                        )),
                                    GestureDetector(
                                        onTap: () => widget.onConfirm!= null ? widget.onConfirm!() : null,
                                        child: Container(
                                          margin: EdgeInsets.all(4.0),
                                          height: 35,
                                          width: MediaQuery.of(context).size.width > 720 ? MediaQuery.of(context).size.width / 10  : MediaQuery.of(context).size.width / 2.5,
                                          decoration: BoxDecoration(
                                            color:
                                            Theme.of(context).primaryColor,
                                            border: Border(bottom: BorderSide(color: ColorCodes.BUTTON_BOTTOM, width: 2))
                                          ),
                                          child: Center(
                                              child: Text(
                                                ApplicationLocalizations.of(context)
                                                    .translate(widget.confirmLabel ?? i18.common.CORE_CONFIRM),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                              )),
                                        ))
                                  ]))
                        ])));
  }
}
