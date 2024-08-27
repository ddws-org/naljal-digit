import 'package:flutter/material.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/home_provider.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:provider/provider.dart';
import 'package:mgramseva/utils/role_actions.dart';

final String assetName = 'assets/svg/HHRegister.svg';

class HomeCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeCard();
  }
}

class _HomeCard extends State<HomeCard> {
  @override
  void initState() {
    super.initState();
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.getLocalizationData(context);
  }

  List<Widget> getList(HomeProvider homeProvider) {
    return RoleActionsFiltering().getFilteredModules().map((item) {
      return GridTile(
        child: new GestureDetector(
            onTap: () => Navigator.pushNamed(context, item.link,
                arguments: item.arguments),
            child: new Card(
              key :Key(item.label),
                // key: homeProvider.homeWalkthroughList
                //     .where((element) => element.label == item.label).isNotEmpty?homeProvider.homeWalkthroughList
                //     .where((element) => element.label == item.label).first
                //     .key:Key(item.label),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(item.iconData, size: 30),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: Center(
                          child: new Text(
                        ApplicationLocalizations.of(context)
                            .translate(item.label),
                            textScaleFactor: MediaQuery.of(context).size.width<400 ? 0.90 : 1,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      )),
                    )
                  ],
                ))),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var homeProvider = Provider.of<HomeProvider>(context, listen: false);
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 760) {
        return Container(
            child: commonProvider.userDetails?.selectedtenant != null &&
                    commonProvider.userDetails?.userRequest != null
                ? (new GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: .85,
                    children: getList(homeProvider),
                  ))
                : Text(""));
      } else {
        return Container(
            margin: EdgeInsets.only(left: 75, right: 75),
            child: commonProvider.userDetails?.selectedtenant != null &&
                    commonProvider.userDetails?.userRequest != null
                ? (new GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 3,
                    childAspectRatio: 3,
                    children: getList(homeProvider),
                  ))
                : Text(""));
      }
    });
  }
}
