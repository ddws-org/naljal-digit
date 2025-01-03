import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/widgets/background_container.dart';
import 'package:mgramseva/widgets/button.dart';
import 'package:mgramseva/widgets/footer_banner.dart';
import 'package:mgramseva/widgets/language_card.dart';
import 'package:provider/provider.dart';

class LanguageSelectMobileView extends StatelessWidget {
  final StateInfo stateInfo;
  LanguageSelectMobileView(this.stateInfo);

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(Container(
      height: MediaQuery.of(context).size.height,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 35.0),
              child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Color(0x4590c5e5), width: 1.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Column(
                children: [
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                            child: Image(
                                width: 120,
                                fit: BoxFit.contain,
                                image: NetworkImage(
                                  stateInfo.logoUrl ?? '',
                                ),
                              ), //add logo_main.png in s3
                          ),
                          Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                " |",
                                style: TextStyle(
                                    fontSize: 19,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Container(
                          alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          textDirection: TextDirection.rtl,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                                child: FittedBox(
                                child: Text(
                                    ApplicationLocalizations.of(context).translate(stateInfo.code!),
                                  style: TextStyle(
                                      fontSize: 19,
                                      color: Color.fromRGBO(0, 0, 0, 1),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (var language in stateInfo.languages ?? [])
                              LanguageCard(
                              language,
                              stateInfo.languages ?? [],
                              MediaQuery.of(context).size.width * 0.22,
                              10,
                              10,
                            ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                    padding: EdgeInsets.all(15),
                    child: Consumer<LanguageProvider>(
                      builder: (_, languageProvider, child) => Button(
                        i18.common.CONTINUE,
                        () => Navigator.pushNamed(context, Routes.LOGIN),
                        key: Keys.language.LANGUAGE_PAGE_CONTINUE_BTN,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FooterBanner(),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }
}
