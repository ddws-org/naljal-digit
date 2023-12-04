import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_styles.dart';

class ShortButton extends StatelessWidget {
  final String label;
  final VoidCallback? callBack;
  final Key? key;
  ShortButton(this.label, this.callBack,{this.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return new  Container(
        height: 48,
        width: constraints.maxWidth > 760 ? constraints.maxWidth / 4 : constraints.maxWidth,
            decoration: CommonStyles.buttonBottomDecoration,
            child: new ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 13),
                backgroundColor: callBack!=null?Theme.of(context).primaryColor:Theme.of(context).disabledColor
              ),
              key: key,
              child: new Text(
                  ApplicationLocalizations.of(context).translate(label),
                   style:
                   Theme.of(context).textTheme.titleMedium!.apply(color: Colors.white)
            ),
              onPressed: callBack
            ),
          );
    });
  }
}
