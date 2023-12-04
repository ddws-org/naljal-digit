import 'package:flutter/material.dart';

class HeadingText extends StatelessWidget {
  final input;
  HeadingText(this.input);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(input,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }
}
