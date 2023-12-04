import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class SuccessPage extends StatelessWidget {
  final label;
  final String? amount;
  final String? subText;
  final String? subTextHeader;
  SuccessPage(this.label, {this.amount, this.subText, this.subTextHeader});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(30),
        decoration: new BoxDecoration(color: Colors.green[900]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            new Align(
              alignment: Alignment.center,
              child: Text(ApplicationLocalizations.of(context).translate(label),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.background,
                    fontSize: 32,
                    fontFamily: 'Roboto Condensed',
                    fontWeight: FontWeight.w700
                  )),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                amount==null?SizedBox():Text('₹$amount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.background,
                        fontSize: 32,
                        fontFamily: 'Roboto Condensed',
                        fontWeight: FontWeight.w700
                    )),
                SizedBox(width: 8,),
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.background,
                  size: 32,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            if(subTextHeader != null) Container(
              padding: EdgeInsets.only(top: 8),
              alignment: Alignment.center,
              child: Text(ApplicationLocalizations.of(context).translate(subTextHeader ?? ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.background,
                    fontSize: 18,
                    fontWeight: FontWeight.w700
                  )),
            ),
            if(subText != null) Container(
              padding: EdgeInsets.only(top: 8),
              alignment: Alignment.center,
              child: Text(ApplicationLocalizations.of(context).translate(subText ?? ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.background,
                    fontSize: 24,
                    fontWeight: FontWeight.w700
                  )),
            ),
          ],
        ));
  }
}
