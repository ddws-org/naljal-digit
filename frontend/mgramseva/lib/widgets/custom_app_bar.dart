import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/mdms/tenants.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/providers/tenants_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:provider/provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar()
      : preferredSize = Size.fromHeight(kToolbarHeight),
        super();
  @override
  final Size preferredSize; // default is 56.0
  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  Tenants? tenants;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  afterViewBuild() {
  //   var commonProvider = Provider.of<CommonProvider>(
  //       navigatorKey.currentContext!,
  //       listen: false);
  //  commonProvider.appBarUpdate();    

  }

  showDialogBox(List<Tenants> tenants) {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    var tenantProvider = Provider.of<TenantsProvider>(context, listen: false);
    final r = commonProvider.userDetails!.userRequest!.roles!
        .map((e) => e.tenantId)
        .toSet()
        .toList();
    final res = tenantProvider.tenants!.tenantsList!
        .where((element) => r.contains(element.code?.trim()))
        .toList();
    showDialog(
        barrierDismissible: commonProvider.userDetails!.selectedtenant != null,
        context: context,
        builder: (BuildContext context) {
          var searchController = TextEditingController();
          var visibleTenants = tenants.asMap().values.where((element) =>element.city?.districtCode != null).toList();
          return StatefulBuilder(
            builder: (context, StateSetter stateSetter) {
              return Stack(children: <Widget>[
                Container(
                    margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width > 720
                            ? MediaQuery.of(context).size.width -
                                MediaQuery.of(context).size.width / 3
                            : 0,
                        top: 60),
                    width: MediaQuery.of(context).size.width > 720
                        ? MediaQuery.of(context).size.width / 3
                        : MediaQuery.of(context).size.width,
                    height: (visibleTenants.length * 50 < 300 ?
                    visibleTenants.length * 50 : 300)+ 60,
                    color: Colors.white,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        Material(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                hintText: "${ApplicationLocalizations.of(context)
                                    .translate(i18.common.SEARCH)}"
                              ),
                              onChanged: (text) {
                                  if(text.isEmpty){
                                    stateSetter(()=>visibleTenants = tenants.asMap().values.toList()
                                    );
                                  }else{
                                    var tresult = tenants.where((e) => "${ApplicationLocalizations.of(context)
                                        .translate(e.code!)}-${e.city!.code!}".toLowerCase().trim().contains(text.toLowerCase().trim())).toList();
                                    stateSetter(()=>visibleTenants = tresult
                                    );
                                  }
                              },
                            ),
                          ),
                        ),
                        ...List.generate(visibleTenants.length, (index) {
                        return GestureDetector(
                            onTap: () {
                              commonProvider.setTenant(visibleTenants[index]);
                              Navigator.of(context,rootNavigator: true).pop();
                              CommonMethods.home();
                            },
                            child: Material(
                                child: Container(
                              color: index.isEven
                                  ? Colors.white
                                  : Color.fromRGBO(238, 238, 238, 1),
                              width: MediaQuery.of(context).size.width,
                              height: 50,
                              padding: EdgeInsets.all(5),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ApplicationLocalizations.of(context)
                                            .translate(visibleTenants[index].code!),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: commonProvider.userDetails!
                                                            .selectedtenant !=
                                                        null &&
                                                    commonProvider
                                                            .userDetails!
                                                            .selectedtenant!
                                                            .city!
                                                            .code ==
                                                        visibleTenants[index].city!.code!
                                                ? Theme.of(context).primaryColor
                                                : Colors.black),
                                      ),
                                      Text(visibleTenants[index].city!.code!,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color: commonProvider.userDetails!
                                                              .selectedtenant !=
                                                          null &&
                                                      commonProvider
                                                              .userDetails!
                                                              .selectedtenant!
                                                              .city!
                                                              .code ==
                                                          visibleTenants[index].city!.code!
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.black))
                                    ]),
                              ),
                            )));
                      },growable: true)],
                    ))
              ]);
            }
          );
        });
  }

  buildTenantsView(Tenant tenant) {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    final r = commonProvider.userDetails!.userRequest!.roles!
        .map((e) => e.tenantId)
        .toSet()
        .toList();
    final result = tenant.tenantsList!
        .where((element) => r.contains(element.code?.trim()))
        .toList();
    return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Consumer<CommonProvider>(
                  builder: (_, commonProvider, child) =>
                      commonProvider.userDetails?.selectedtenant == null
                          ? Text("")
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                  Text(ApplicationLocalizations.of(context)
                                      .translate(commonProvider
                                          .userDetails!.selectedtenant!.code!),style: Theme.of(context).textTheme.labelMedium,),
                                  Text(ApplicationLocalizations.of(context)
                                      .translate(commonProvider.userDetails!
                                          .selectedtenant!.city!.code!),style: Theme.of(context).textTheme.labelSmall,)
                                ])),
              Icon(Icons.arrow_drop_down)
            ],
          ),
        ),
        onTap: () => showDialogBox(result));
  }

  @override
  Widget build(BuildContext context) {
    var tenantProvider = Provider.of<TenantsProvider>(context, listen: false);
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return AppBar(
      titleSpacing: 0,
      iconTheme: IconThemeData(color: Colors.white),
      title: Image(
          width: 130,
          image: NetworkImage(
            languageProvider.stateInfo!.logoUrlWhite!,
          )),
      actions: [
        Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width / 3,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  tenantProvider.tenants != null
                      ? buildTenantsView(tenantProvider.tenants!)
                      : StreamBuilder(
                          stream: tenantProvider.streamController.stream,
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return buildTenantsView(snapshot.data);
                            } else if (snapshot.hasError) {
                              return Notifiers.networkErrorPage(context, () {});
                            } else {
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Loaders.circularLoader();
                                case ConnectionState.active:
                                  return Loaders.circularLoader();
                                default:
                                  return Container(
                                    child: Text(""),
                                  );
                              }
                            }
                          })
                ]))
      ],
    );
  }
}
