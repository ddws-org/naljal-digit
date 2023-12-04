import 'package:flutter/material.dart';

class Back extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Positioned(
      top: 30.0,
      left: 10,
      child: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          iconSize: 25,
          color: Colors.white,
          splashColor: Colors.purple,
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).maybePop()),
    );
  }
}
