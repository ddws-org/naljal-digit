import 'package:flutter/material.dart';

class CustomDetailsCard extends StatelessWidget {
  final Widget widget;

  CustomDetailsCard(this.widget);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        padding: constraints.maxWidth > 760
            ? EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0)
            : EdgeInsets.all(8.0),
        margin: EdgeInsets.only(left: 0.0, right: 0.0, bottom: 16.0),
        decoration: BoxDecoration(
            color: Color.fromRGBO(238, 238, 238, 0.4),
            border: Border.all(color: Colors.grey, width: 0.6),
            borderRadius: BorderRadius.all(
              Radius.circular(4.0),
            )),
        child: Wrap(
          children: [widget],
        ),
      );
    });
  }
}
