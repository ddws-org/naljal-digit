import 'package:flutter/material.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/screeens/landing_page/AppHeader.dart';
import 'package:provider/provider.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget widget;
  BackgroundContainer(this.widget);
  @override
  Widget build(BuildContext context) {
    var languageProvider =
    Provider.of<LanguageProvider>(context, listen: false);
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/png/bg_mgramseva.png"),
              fit: BoxFit.fill,
            ),
          ),
        ),
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppHeader(),widget
            ],
          ),
        ),
      ],
    );
  }
}