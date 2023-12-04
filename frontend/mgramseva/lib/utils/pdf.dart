import 'package:flutter/material.dart';
import 'package:mgramseva/env/app_config.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

import 'localization/application_localizations.dart';
import 'global_variables.dart';

class PdfUtils {

  static pw.Widget buildAppBar(BuildContext context, pw.ImageProvider image, pw.Font icons, pw.Font font) {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var style = pw.TextStyle(fontSize: 14, font: font, color: PdfColor.fromHex('#FFFFFF'));

    return pw.Container(
        padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        margin: pw.EdgeInsets.only(bottom: 5),
        decoration: pw.BoxDecoration(color: PdfColor.fromHex('#0B4B66')),
        child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Wrap(
                  crossAxisAlignment: pw.WrapCrossAlignment.center,
                  children : [
                    pw.SizedBox(width: 2),
                    pw.Image(image,
                        width: 90),
                  ]),
              pw.Wrap(
                spacing: 3,
                children: [
                  pw.Text(
                      ApplicationLocalizations.of(context).translate(
                          commonProvider.userDetails?.selectedtenant?.code ??
                              ''),
                      style: style),
                  pw.Text(
                      ApplicationLocalizations.of(context).translate(
                          commonProvider
                              .userDetails?.selectedtenant?.city?.code ??
                              ''),
                      style: style)
                ],
              )
            ]));
  }

  static Future<pw.ImageProvider> get mgramSevaLogo async {
    var languageProvider =
    Provider.of<LanguageProvider>(navigatorKey.currentContext!, listen: false);

    return await networkImage(
      languageProvider.stateInfo?.logoUrlWhite ?? '');
  }

  static Future<pw.ImageProvider> get powerdByDigit async => await networkImage(
      "$apiBaseUrl${Constants.DIGIT_FOOTER_ENDPOINT}");

  static pw.Widget pdfFooter(pw.ImageProvider image){
    return pw.Container(
        margin: pw.EdgeInsets.only(top: 10),
        alignment: pw.Alignment.center,
        child: pw.SizedBox(
            width: 100,
            child: pw.Image(image)
        )
    );

  }
}