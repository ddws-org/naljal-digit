import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/components/notifications/notifications_list.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/home_provider.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/providers/notifications_provider.dart';
import 'package:mgramseva/providers/tenants_provider.dart';
import 'package:mgramseva/screeens/home/home_card.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:mgramseva/widgets/help.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_app_bar.dart';
import 'home_walk_through/home_walk_through_container.dart';
import 'home_walk_through/home_walk_through_list.dart';

class Home extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  afterViewBuild() {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    commonProvider.appBarUpdate();
    languageProvider.getLocalizationData(context);
  }

  _buildView(homeProvider, Widget notification) {
    var tenantProvider = Provider.of<TenantsProvider>(context, listen: false);
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    String loginUsername = "login user name";
    if(commonProvider.userDetails != null){   
    final dashboardName = commonProvider.userDetails!.userRequest!.roles!
        .map((e) => e.code)
        .toSet()
        .toList();
    if (dashboardName.contains('CHAIRMEN')) {
      loginUsername = "Chairmen";
    } else if (dashboardName.contains('REVENUE_COLLECTOR')) {
      loginUsername = "Revenue Collector";
    } else if (dashboardName.contains('DIV_ADMIN')) {
      loginUsername = "Division User";
    } else if (dashboardName.contains('SECRETARY')) {
      loginUsername = "Secretary";
    }
    }
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: FractionalOffset.topCenter,
              end: FractionalOffset.bottomCenter,
              colors: [
                Color(0xff90c5e5),
                Color(0xffeef7f2),
                Color(0xffffeca7),
              ],
            ),
          ),
          child: Column(children: [
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Center(
                        child: Container(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(loginUsername,
                                                style: TextStyle(fontSize: 18.0, color: Colors.black),
                                              ),
                            )))),
                // Container(
                //   child: Column(
                //     children: [
                //       Help(
                //         callBack: () => showGeneralDialog(
                //           barrierLabel: "Label",
                //           barrierDismissible: false,
                //           barrierColor: Colors.black.withOpacity(0.5),
                //           transitionDuration: Duration(milliseconds: 700),
                //           context: context,
                //           pageBuilder: (context, anim1, anim2) {
                //             return HomeWalkThroughContainer((index) =>
                //                 homeProvider.incrementIndex(
                //                     index,
                //                     homeProvider
                //                         .homeWalkthroughList[index + 1].key));
                //           },
                //           transitionBuilder: (context, anim1, anim2, child) {
                //             return SlideTransition(
                //               position:
                //                   Tween(begin: Offset(0, 1), end: Offset(0, 0))
                //                       .animate(anim1),
                //               child: child,
                //             );
                //           },
                //         ),
                //         walkThroughKey: Constants.HOME_KEY,
                //       ),
                //       Text('help')
                //     ],
                //   ),
                // )
              ],
            ),
            HomeCard(),
            notification,
            Footer()
          ]),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var tenantProvider = Provider.of<TenantsProvider>(context, listen: false);
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: CustomAppBar(),
        drawer: DrawerWrapper(
          Drawer(child: SideBar()),
        ),
        body: SingleChildScrollView(
            child: LayoutBuilder(builder: (context, constraint) {
          return Consumer<CommonProvider>(
              builder: (_, commonProvider, child) => tenantProvider.tenants !=
                      null
                  ? Consumer<CommonProvider>(builder: (_, userProvider, child) {
                      Provider.of<HomeProvider>(context, listen: false)
                        ..setWalkThrough(
                            HomeWalkThrough().homeWalkThrough.map((e) {
                          e.key = GlobalKey();
                          return e;
                        }).toList());
                      return _buildHome(constraint);
                    })
                  : StreamBuilder(
                      stream: tenantProvider.streamController.stream,
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return Consumer<CommonProvider>(
                              builder: (_, userProvider, child) {
                            Provider.of<HomeProvider>(context, listen: false)
                              ..setWalkThrough(
                                  HomeWalkThrough().homeWalkThrough.map((e) {
                                e.key = GlobalKey();
                                return e;
                              }).toList());
                            return _buildHome(constraint);
                          });
                        } else if (snapshot.hasError) {
                          return Notifiers.networkErrorPage(
                              context,
                              () => languageProvider
                                  .getLocalizationData(context));
                        } else {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return Loaders.circularLoader();
                            case ConnectionState.active:
                              return Loaders.circularLoader();
                            default:
                              return Container();
                          }
                        }
                      }));
        })));
  }

  Widget _buildHome(BoxConstraints constraint) {
    var homeProvider = Provider.of<HomeProvider>(context, listen: false);

    return _buildView(
      homeProvider,
      Container(
          margin: constraint.maxWidth < 720
              ? EdgeInsets.all(8)
              : EdgeInsets.only(left: 75, right: 75),
          child: Consumer<CommonProvider>(builder: (_, userProvider, child) {
            if (userProvider.userDetails?.selectedtenant?.code != null) {
              var commonProvider =
                  Provider.of<CommonProvider>(context, listen: false);
              try {
                Provider.of<NotificationProvider>(context, listen: false)
                  ..getNotiications({
                    "tenantId": userProvider.userDetails?.selectedtenant?.code!,
                    "eventType": "SYSTEMGENERATED",
                    "recepients": commonProvider.userDetails?.userRequest?.uuid,
                    "limit": Constants.HOME_NOTIFICATIONS_LIMIT
                  }, {
                    "tenantId": userProvider.userDetails?.selectedtenant?.code!,
                    "eventType": "SYSTEMGENERATED",
                    "roles":
                        commonProvider.uniqueRolesList()?.join(',').toString(),
                    "limit": Constants.HOME_NOTIFICATIONS_LIMIT
                  });
              } catch (e) {
                ErrorHandler()
                    .allExceptionsHandler(navigatorKey.currentContext!, e);
              }
            }
            return userProvider.userDetails?.selectedtenant?.code != null
                ? NotificationsList(
                    close: true,
                  )
                : Text("");
          })),
    );
  }
}
