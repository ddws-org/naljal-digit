import 'package:flutter/material.dart';

class Back extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(
          Icons.arrow_back,
        ),
        iconSize: 25,
        color: Color(0xff033ccf),
        splashColor: Colors.purple,
        onPressed: () =>
            Navigator.of(context, rootNavigator: true).maybePop());
  }
}
