import 'package:flutter/material.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import '../utils/localization/application_localizations.dart';

class CustomCheckBoxWidget extends StatelessWidget {
  final bool value;
  final String? text;
  final Function() onChange;
  final String? linkText;
  final Function()? onTapLink;
  CustomCheckBoxWidget( this.value , this.text, this.onChange, {this.linkText, this.onTapLink});
  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
            vertical: 10, horizontal: 4),
        child: Wrap(
          children: [
            Row(
              children: [
                Checkbox(
                    value: value,
                    onChanged: onChange()
                ),
                Text(
                    ApplicationLocalizations.of(context)
                        .translate(
                        text ?? i18.payment.CORE_I_AGREE_TO_THE),
                    style: TextStyle(
                      // color: Theme.of(context).primaryColor,
                        fontSize: 19,
                        fontWeight: FontWeight.normal)),
                linkText != null ?  GestureDetector(
                  onTap: onTapLink != null ? onTapLink : null,
                  child: Text(
                      ApplicationLocalizations.of(context)
                          .translate(
                          linkText ?? i18.payment.TERMS_N_CONDITIONS),
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 19,
                          fontWeight: FontWeight.normal)),
                ) : Text('')

              ],
            )

          ],
        )
    );
  }
}