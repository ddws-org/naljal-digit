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
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
           // colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.dstATop),
            image: AssetImage("assets/png/bg_mgramseva.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Stack(
          children: [
            AppHeader(),widget
          ],
        ));
  }
}