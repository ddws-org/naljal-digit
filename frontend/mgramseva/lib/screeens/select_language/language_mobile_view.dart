import 'package:flutter/material.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/screeens/landing_page/AppHeader.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/widgets/background_container.dart';
import 'package:mgramseva/widgets/button.dart';
import 'package:mgramseva/widgets/language_card.dart';
import 'package:mgramseva/widgets/footer_banner.dart';
import 'package:provider/provider.dart';

class LanguageMobileView extends StatelessWidget {
  final StateInfo stateInfo;

  LanguageMobileView(this.stateInfo);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/png/bg_mgramseva.png',
          // Replace with the path to your image asset
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
        ),
        AppHeader(),
        Positioned(
            bottom: 35.0,
            child: Column(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(8),
                    child: FittedBox(
                      child: Card(
                          color: Color(0xfff6f6f6),
                          child: (Column(children: [
                            Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                           Image(
                                                width: 120,
                                                fit: BoxFit.contain,
                                                image: NetworkImage(
                                                  stateInfo.logoUrl ?? '',
                                                ))
                                            ,
                                          ),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.only(right: 1),
                                              child: Text(
                                                " | ",
                                                style: TextStyle(
                                                    fontSize: 19,
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 1)),
                                              )),
                                        ],
                                      ),
                                      Container(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          textDirection: TextDirection.rtl,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 0.0),
                                                child: Text(
                                                  ApplicationLocalizations.of(
                                                          context)
                                                      .translate(stateInfo.code!),
                                                  style: TextStyle(
                                                      fontSize: 19,
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 1),
                                                      fontWeight:
                                                          FontWeight.w400),
                                                )),
                                          ],
                                        ),
                                      ),
                                    ])),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        for (var language
                                            in stateInfo.languages ?? [])
                                          LanguageCard(
                                              language,
                                              stateInfo.languages ?? [],
                                              MediaQuery.of(context).size.width *
                                                  0.22,
                                              10,
                                              10)
                                      ]),
                                )),
                            Padding(
                                padding: EdgeInsets.all(15),
                                child: Consumer<LanguageProvider>(
                                  builder: (_, languageProvider, child) => Button(
                                    i18.common.CONTINUE,
                                    () => Navigator.pushNamed(
                                        context, Routes.LOGIN),
                                    key: Keys.language.LANGUAGE_PAGE_CONTINUE_BTN,
                                  ),
                                ))
                          ]))),
                    ))
              ],
            )),
        Positioned(
            bottom: 0.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FooterBanner(),
                ],
              ),
            ))
      ],
    );
  }
}
