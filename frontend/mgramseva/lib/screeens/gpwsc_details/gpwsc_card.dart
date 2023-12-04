import 'package:flutter/material.dart';

class GPWSCCard extends StatelessWidget {
  final List<Widget> children;
  const GPWSCCard({Key? key, required this.children}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Card(
        margin: EdgeInsets.only(bottom: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children),
      );
    });
  }
}
