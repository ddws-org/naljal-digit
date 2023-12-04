import 'package:flutter/material.dart';

class PageNotAvailable extends StatelessWidget {
  const PageNotAvailable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Text('Page not available'),
      ),
    );
  }
}
