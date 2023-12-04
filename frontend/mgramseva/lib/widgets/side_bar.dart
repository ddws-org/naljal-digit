import 'package:flutter/material.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/widgets/language_card.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:provider/provider.dart';

class SideBar extends StatelessWidget {
  SideBar();

  @override
  Widget build(BuildContext context) {
    const iconColor = Color(0xff505A5F);
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    return new ListView(children: <Widget>[
      Container(
          height: 200.0,
          color: Color(0xffD6D5D4),
          child: DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: Text(
                  commonProvider.userDetails != null
                      ? commonProvider.userDetails!.userRequest!.name.toString()
                      : "",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                )),
                SizedBox(
                  height: 10,
                ),
                Center(
                    child: Text(
                  commonProvider.userDetails != null
                      ? commonProvider.userDetails!.userRequest!.mobileNumber
                          .toString()
                      : "",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ))
              ],
            ),
          ),
          margin: EdgeInsets.all(0.0),
          padding: EdgeInsets.all(0.0)),
      ListTile(
        title: Text(
            ApplicationLocalizations.of(context).translate(i18.common.HOME)),
        leading: Icon(
          Icons.home,
          color: iconColor,
        ),
        onTap: () {
          // Update the state of the app
          // ...
          // Then close the drawer
          if (currentRoute != Routes.HOME) CommonMethods.home();
        },
      ),
      ListTile(
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(ApplicationLocalizations.of(context)
                  .translate(i18.common.LANGUAGE)),
              SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                for (var language
                    in Provider.of<LanguageProvider>(context, listen: false)
                            .stateInfo
                            ?.languages ??
                        [])
                  LanguageCard(
                    language,
                    Provider.of<LanguageProvider>(context, listen: false)
                            .stateInfo
                            ?.languages ??
                        [],
                    75,
                    4,
                    4,
                  )
              ])
            ],
          ),
          leading: Icon(
            Icons.translate,
            color: iconColor,
          ),
          onTap: () => Navigator.pop(context)),
      ListTile(
        key: Keys.editProfile.SIDE_BAR_EDIT_PROFILE_TILE_KEY,
          title: Text(ApplicationLocalizations.of(context)
              .translate(i18.common.EDIT_PROFILE)),
          leading: Icon(
            Icons.assignment_ind,
            color: iconColor,
          ),
          onTap: () => Navigator.pushNamed(context, Routes.EDIT_PROFILE)),
      ListTile(
          title: Text(ApplicationLocalizations.of(context)
              .translate(i18.password.CHANGE_PASSWORD)),
          leading: Icon(
            Icons.sync_alt,
            color: iconColor,
          ),
          onTap: () => Navigator.pushNamed(context, Routes.CHANGE_PASSWORD),
      key: Keys.changePassword.SIDE_BAR_CHANGE_PASSWORD_TILE_KEY,),
      ListTile(
        key: Keys.common.LOGOUT_TILE_KEY,
        title: Text(
            ApplicationLocalizations.of(context).translate(i18.common.LOGOUT)),
        leading: Icon(
          Icons.logout,
          color: iconColor,
        ),
        onTap: () {
          var commonProvider =
              Provider.of<CommonProvider>(context, listen: false);
          commonProvider.onLogout();
        },
      ),
      Align(
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // your footer widgets here
            Footer()
          ],
        ),
      )
    ]);
  }
}
