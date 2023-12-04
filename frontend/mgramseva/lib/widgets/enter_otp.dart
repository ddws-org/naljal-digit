import 'package:flutter/material.dart';

class EnterOTP extends StatelessWidget {
  final controller1;
  final controller2;
  final controller3;
  final controller4;

  EnterOTP(
      this.controller1, this.controller2, this.controller3, this.controller4);
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 80),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OTPDigitTextFieldBox(this.controller1, true, false),
              OTPDigitTextFieldBox(this.controller2, false, false),
              OTPDigitTextFieldBox(this.controller3, false, false),
              OTPDigitTextFieldBox(this.controller4, false, true),
            ],
          )
        ]),
      ),
    );
  }
}

class OTPDigitTextFieldBox extends StatelessWidget {
  final bool first;
  final controller;
  final bool last;
  const OTPDigitTextFieldBox(
      this.controller, @required this.first, @required this.last)
      : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      child: AspectRatio(
        aspectRatio: .9,
        child: TextField(
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
          showCursor: false,
          readOnly: false,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            // contentPadding: EdgeInsets.all(0),
            counter: Offstage(),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2),
                borderRadius: BorderRadius.circular(1)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(width: 2),
                borderRadius: BorderRadius.circular(1)),
            hintText: "",
            // hintStyle: MyStyles.hintTextStyle,
          ),
        ),
      ),
    );
  }
}
