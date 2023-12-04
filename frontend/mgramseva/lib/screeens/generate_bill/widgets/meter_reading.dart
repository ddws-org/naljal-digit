import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class MeterReading extends StatelessWidget {
  final label;
  final bool? isRequired;
  final controller1;
  final controller2;
  final controller3;
  final controller4;
  final controller5;
  final bool? isDisabled;
  MeterReading(this.label, this.controller1, this.controller2, this.controller3,
      this.controller4, this.controller5,
      {this.isRequired, this.isDisabled});

  _getContainer(constraints, context) {
    return [
      Container(
          width: constraints.maxWidth > 760
              ? MediaQuery.of(context).size.width / 3
              : MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 18, bottom: 3),
          child: new Align(
              alignment: Alignment.centerLeft,
              child: Wrap(direction: Axis.horizontal, children: <Widget>[
                Text('${ApplicationLocalizations.of(context).translate(label)}',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: isDisabled == true ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark)),
                Text(isRequired! ? '* ' : ' ',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: isDisabled == true ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark)),
              ]))),
      Container(
          width: constraints.maxWidth > 760
              ? MediaQuery.of(context).size.width / 2.5
              : MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 18, bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MeterReadingDigitTextFieldBox(this.controller1, true, false, isDisabled: this.isDisabled,),
              MeterReadingDigitTextFieldBox(this.controller2, false, false, isDisabled: this.isDisabled,),
              MeterReadingDigitTextFieldBox(this.controller3, false, false, isDisabled: this.isDisabled),
              MeterReadingDigitTextFieldBox(this.controller4, false, false, isDisabled: this.isDisabled),
              MeterReadingDigitTextFieldBox(this.controller5, false, true, isDisabled: this.isDisabled),
            ],
          ))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
              margin: constraints.maxWidth > 760 ? const EdgeInsets.only(
                  top: 5.0, bottom: 5, right: 20, left: 20) : const EdgeInsets.only(
                  top: 5.0, bottom: 5, right: 8, left: 8),
              child: constraints.maxWidth > 760
                  ? Row(children: _getContainer(constraints, context))
                  : Column(children: _getContainer(constraints, context)));
        }));
  }
}

class MeterReadingDigitTextFieldBox extends StatelessWidget {
  final bool first;
  final bool last;
  final controller;
  final bool? isDisabled;
  const MeterReadingDigitTextFieldBox(this.controller, this.first, this.last, {this.isDisabled})
      : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: AspectRatio(
        aspectRatio: 0.9,
        child: ForceFocusWatcher(
        child: TextFormField(
          controller: controller,
          autofocus: true,
          onChanged: (value) {
            if (value.length == 1 && last == false) {
              FocusScope.of(context).nextFocus();
            }
            if (value.length == 0 && first == false) {
              FocusScope.of(context).previousFocus();
            }
          },
          style: TextStyle(color: isDisabled == true ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColorDark),
          showCursor: isDisabled == true ? false : true,
          readOnly: isDisabled == true ? true : false,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+'))
          ],
          decoration: InputDecoration(
            // contentPadding: EdgeInsets.all(0),
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(1)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 1),
                borderRadius: BorderRadius.circular(1)),
            hintText: "",
            // hintStyle: MyStyles.hintTextStyle,
          ),
        )),
      ),
    );
  }
}
