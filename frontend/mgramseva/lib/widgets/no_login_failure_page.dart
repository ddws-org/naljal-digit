import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class NoLoginFailurePage extends StatelessWidget {
  final label;

  NoLoginFailurePage(this.label);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Card(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(30),
                  decoration: new BoxDecoration(color: Colors.red[900]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      new Align(
                        alignment: Alignment.center,
                        child: Text(
                            ApplicationLocalizations.of(context)
                                .translate(label),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            )),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.white,
                        size: 32,
                      )
                    ],
                  )),
              SizedBox(
                height: 20,
              ),
            ],
          ))
        ]));
  }
}
