import 'package:flutter/material.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/widgets/background_container.dart';
import 'package:mgramseva/widgets/button.dart';
import 'package:mgramseva/widgets/language_card.dart';
import 'package:mgramseva/widgets/footer_banner.dart';


class LanguageSelectionDesktopView extends StatelessWidget {
  final StateInfo stateInfo;
  final Function changeLanguage;
  LanguageSelectionDesktopView(this.stateInfo, this.changeLanguage);

  @override
  Widget build(BuildContext context) {
    return BackgroundContainer(Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
            child: new Container(
                height: 256,
                width: 500,
                padding: EdgeInsets.all(16),
                child: Card(
                    child: (Column(
                        mainAxisAlignment:MainAxisAlignment.center,
                        children: [
                      Container(
                          width:MediaQuery.of(context).size.width*0.9,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image(
                                          width: 150,
                                          fit: BoxFit.fill,
                                          image: NetworkImage(
                                            stateInfo.logoUrl ?? '',
                                          )),
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Text(
                                          " | ",
                                          style: TextStyle(
                                              fontSize: 19,
                                              color: Color.fromRGBO(0, 0, 0, 1)),
                                        )),
                                  ],
                                ),
                                Container(
                                  width: 55,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    textDirection: TextDirection.rtl,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(left: 0.0),
                                          child: Text(
                                            ApplicationLocalizations.of(context)
                                                .translate(stateInfo.code!),
                                            style: TextStyle(
                                                fontSize: 19,
                                                color: Color.fromRGBO(0, 0, 0, 1),
                                                fontWeight: FontWeight.w400),
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
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  for (var language in stateInfo.languages ?? [])
                                    LanguageCard(
                                        language, stateInfo.languages ?? [], 120, 10, 10)
                                ]),
                          )),
                      Padding(
                          padding: EdgeInsets.all(15),
                          child: Button(
                              i18.common.CONTINUE,
                                  () => Navigator.pushNamed(context, Routes.LOGIN),
                              key: Keys.language.LANGUAGE_PAGE_CONTINUE_BTN,
                            ),
                          )
                    ]))))),
        SizedBox(height: 140),
        FooterBanner()
      ],
    ));
  }
}
