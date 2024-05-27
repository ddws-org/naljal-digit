import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/components/household_register/household_card.dart';
import 'package:mgramseva/providers/household_register_provider.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:provider/provider.dart';

import '../../widgets/custom_app_bar.dart';
import '../../widgets/pagination.dart';
import 'household_search.dart';

class HouseholdRegister extends StatefulWidget {
  final int initialTabIndex;

  const HouseholdRegister({Key? key, this.initialTabIndex = 0})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HouseholdRegister();
  }
}

class _HouseholdRegister extends State<HouseholdRegister>
    with SingleTickerProviderStateMixin {
  OverlayState? overlayState;
  OverlayEntry? _overlayEntry;
  GlobalKey key = GlobalKey();

  @override
  void initState() {
    super.initState();
    var householdRegisterProvider =
        Provider.of<HouseholdRegisterProvider>(context, listen: false);
    //householdRegisterProvider.selectedDate = DateTime(DateTime.now().year, DateTime.now().month);
    householdRegisterProvider.debounce = null;
  }

  @override
  Widget build(BuildContext context) {
    var householdRegisterProvider =
        Provider.of<HouseholdRegisterProvider>(context, listen: false);

    return WillPopScope(
      onWillPop: () async {
        if (householdRegisterProvider.removeOverLay(_overlayEntry))
          return false;
        return true;
      },
      child: GestureDetector(
        onTap: () => householdRegisterProvider.removeOverLay(_overlayEntry),
        child: FocusWatcher(
            child: Scaffold(
          appBar: CustomAppBar(),
          drawer: DrawerWrapper(
            Drawer(child: SideBar()),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) => Container(
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
              alignment: Alignment.center,
            /*  margin: constraints.maxWidth < 760
                  ? null
                  : EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 25),*/
              child: Stack(children: [
                Container(
                    margin: constraints.maxWidth < 760
                        ? null
                        : EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width / 25),
                    padding: EdgeInsets.only(left: 8, right: 8),
                    height: constraints.maxHeight - 50,
                    child: CustomScrollView(slivers: [
                      SliverList(
                          delegate: SliverChildListDelegate([
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            HomeBack(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [_buildDownload, _buildShare])
                          ],
                        ),
                        Container(key: key, child: HouseholdCard()),
                      ])),
                      SliverToBoxAdapter(child: HouseholdSearch())
                    ])),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Consumer<HouseholdRegisterProvider>(
                        builder: (_, householdRegisterProvider, child) {
                      var totalCount = (householdRegisterProvider
                              .waterConnectionsDetails?.totalCount) ??
                          0;
                      return Visibility(
                          visible: totalCount > 0,
                          child: Pagination(
                              limit: householdRegisterProvider.limit,
                              offSet: householdRegisterProvider.offset,
                              callBack: (pageResponse) =>
                                  householdRegisterProvider.onChangeOfPageLimit(
                                      pageResponse, context),
                              totalCount: totalCount,
                              isDisabled:
                                  householdRegisterProvider.isLoaderEnabled));
                    }))
              ]),
            ),
          ),
        )),
      ),
    );
  }

  Widget get _buildShare => TextButton.icon(
      key: Keys.common.SHARE,
      onPressed: () {
        Provider.of<HouseholdRegisterProvider>(context, listen: false)
          ..createExcelOrPdfForAllConnections(context, false);
      },
      icon: Image.asset('assets/png/whats_app.png'),
      label: Text(
          ApplicationLocalizations.of(context).translate(i18.common.SHARE), style: TextStyle(color: Color.fromRGBO(3, 60, 207, 0.7))));

  Widget get _buildDownload => TextButton.icon(
      onPressed: () => showDownloadList(Constants.DOWNLOAD_OPTIONS, context),
      icon: Icon(Icons.download_sharp,color: Color.fromRGBO(3, 60, 207, 0.7),),
      label: Text(
          ApplicationLocalizations.of(context).translate(i18.common.DOWNLOAD), style: TextStyle(color: Color.fromRGBO(3, 60, 207, 0.7)),));
}

showDownloadList(List<String> result, BuildContext context) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return Stack(children: <Widget>[
          Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width > 720
                      ? MediaQuery.of(context).size.width -
                          MediaQuery.of(context).size.width / 3
                      : 200,
                  top: 105),
              width: MediaQuery.of(context).size.width > 720
                  ? MediaQuery.of(context).size.width / 6
                  : MediaQuery.of(context).size.width / 4,
              height: result.length * 50 < 300 ? result.length * 50 : 300,
              color: Colors.white,
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: List.generate(result.length, (index) {
                  return GestureDetector(
                      onTap: () {
                        result[index] == i18.householdRegister.PDF
                            ? Provider.of<HouseholdRegisterProvider>(context,
                                    listen: false)
                                .createExcelOrPdfForAllConnections(
                                    context, true, isExcelDownload: false)
                            : Provider.of<HouseholdRegisterProvider>(context,
                                    listen: false)
                                .createExcelOrPdfForAllConnections(
                                    context, true,
                                    isExcelDownload: true);
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
                            child: Text(
                              ApplicationLocalizations.of(context)
                                  .translate(result[index]),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            )),
                      )));
                }),
              ))
        ]);
      });
}
