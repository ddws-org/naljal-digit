import 'package:flutter/material.dart';
import 'package:mgramseva/providers/language.dart';
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
          color: const Color(0xff0B4B66),
          image: DecorationImage(
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.2), BlendMode.dstATop),
            image: NetworkImage(languageProvider.stateInfo!.bannerUrl!),
            fit: BoxFit.cover,
          ),
        ),
        child: widget);
  }
}
