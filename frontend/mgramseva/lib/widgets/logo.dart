import 'package:flutter/material.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:provider/provider.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Align(
        alignment: Alignment.centerLeft,
        child: Container(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 15, bottom: 15),
                child: Center(
                  child: Image(
                      width: 150,
                      image: NetworkImage(
                        languageProvider.stateInfo!.logoUrl!,
                      )),
                )),
            Padding(
                padding: const EdgeInsets.only(left: 15), child: Text(" | ", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400, color: Color.fromRGBO(0,0,0,1)),)),
            Align(
                alignment: Alignment.centerLeft,
                child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        ApplicationLocalizations.of(context).translate(languageProvider.stateInfo!.code!),
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w400, color: Color.fromRGBO(0,0,0,1)),
                        textAlign: TextAlign.left,
                      ),
                    )))
          ],
        )));
  }
}
