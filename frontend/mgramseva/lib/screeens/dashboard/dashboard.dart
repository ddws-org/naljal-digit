import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/components/dashboard/dashboard_card.dart';

import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/dashboard_provider.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/repository/core_repo.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:mgramseva/widgets/custom_overlay/custom_overlay.dart';
import 'package:mgramseva/components/dashboard/nested_date_picker.dart';
import 'package:mgramseva/widgets/tab_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../../routers/routers.dart';
import '../../widgets/custom_app_bar.dart';
import 'revenue_expense_dashboard/revenue_dashboard.dart';
import 'search_expense.dart';
import 'package:mgramseva/widgets/pagination.dart';
import 'package:flutter_share_me/flutter_share_me.dart';

class Dashboard extends StatefulWidget {
  final int? initialTabIndex;
  final DatePeriod? selectedMonth;

  const Dashboard({Key? key, this.initialTabIndex, this.selectedMonth})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Dashboard();
  }
}

class _Dashboard extends State<Dashboard> with SingleTickerProviderStateMixin {
  GlobalKey key = GlobalKey();
  ScreenshotController screenshotController = ScreenshotController();
  var takeScreenShot = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var dashBoardProvider =
        Provider.of<DashBoardProvider>(context, listen: false);
    if(widget.initialTabIndex == null){
    dashBoardProvider.selectedMonth =
        CommonMethods.getFinancialYearList().first.year;
    }else{
      dashBoardProvider.selectedMonth =
          CommonMethods.getFinancialYearList().first.monthList.first;
      dashBoardProvider.selectedDashboardType = widget.initialTabIndex == 0
          ? DashBoardType.collections
          : DashBoardType.Expenditure;
    }
    dashBoardProvider.scrollController = ScrollController();
    dashBoardProvider.debounce = null;
    dashBoardProvider.userFeedBackInformation = null;

    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
  }

  afterViewBuild() {
    var dashBoardProvider =
        Provider.of<DashBoardProvider>(context, listen: false);
    dashBoardProvider.fetchUserFeedbackDetails(context);
  }

  @override
  Widget build(BuildContext context) {

    return 
       PopScope(
      canPop: CustomOverlay.removeOverLay() ? false: true,
      onPopInvoked : (didPop){
        
  },
    
      child: GestureDetector(
        onTap: () => CustomOverlay.removeOverLay(),
        child: FocusWatcher(
            child: Scaffold(
          appBar: CustomAppBar(),
          drawer: DrawerWrapper(
            Drawer(child: SideBar()),
          ),
          backgroundColor: Color.fromRGBO(238, 238, 238, 1),
          body: LayoutBuilder(
            builder: (context, constraints) => Container(
              alignment: Alignment.center,
              margin: constraints.maxWidth < 760
                  ? null
                  : EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width / 25),
              child: Stack(children: [
                Consumer<DashBoardProvider>(
                  builder: (_, dashBoardProvider, child) => Container(
                      color: Color.fromRGBO(238, 238, 238, 1),
                      padding: EdgeInsets.only(left: 8, right: 8),
                      height: (dashBoardProvider.selectedMonth.dateType !=
                              DateType.MONTH)
                          ? constraints.maxHeight
                          : constraints.maxHeight - 50,
                      child: SingleChildScrollView(
                          controller: dashBoardProvider.scrollController,
                          // clipBehavior : ScrollConfiguration.of(context)
                          //     .copyWith(scrollbars: false),
                         child : Column (
                              children : [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  HomeBack(callback: onClickOfBackButton),
                                  _buildShare
                                ],
                              ),
                              Container(
                                  key: key,
                                  child: DashboardCard(onTapOfMonthPicker)),
                              Visibility(
                                visible: !(dashBoardProvider
                                        .selectedMonth.dateType !=
                                    DateType.MONTH),
                                child: _buildMainTabs(),
                              ),
                            _buildViewBasedOnTheSelection(dashBoardProvider)
                          ]))),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Consumer<DashBoardProvider>(
                        builder: (_, dashBoardProvider, child) {
                      var totalCount =
                          (dashBoardProvider.selectedDashboardType ==
                                      DashBoardType.Expenditure
                                  ? dashBoardProvider
                                      .expenseDashboardDetails?.totalCount
                                  : dashBoardProvider
                                      .waterConnectionsDetails?.totalCount) ??
                              0;
                      return Visibility(
                          visible: totalCount > 0 &&
                              !(dashBoardProvider.selectedMonth.dateType !=
                                  DateType.MONTH),
                          child: Pagination(
                              limit: dashBoardProvider.limit,
                              offSet: dashBoardProvider.offset,
                              callBack: (pageResponse) => dashBoardProvider
                                  .onChangeOfPageLimit(pageResponse, context),
                              totalCount: totalCount,
                              isDisabled: dashBoardProvider.isLoaderEnabled));
                    }))
              ]),
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildViewBasedOnTheSelection(DashBoardProvider dashBoardProvider) {
    return dashBoardProvider.selectedMonth.dateType != DateType.MONTH
        ? Column(children: [
        RevenueDashBoard(),
        Visibility(
            visible: takeScreenShot,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                  color: Color.fromRGBO(238, 238, 238, 1),
                  width: 900,
                  child: Screenshot(
                      controller: screenshotController,
                      child: Container(
                        color: Color.fromRGBO(238, 238, 238, 1),
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(children: [
                          customRevenueAppBar(),
                          DashboardCard(() {}, isFromScreenshot: true),
                          RevenueDashBoard(isFromScreenshot: true),
                        ]),
                      ))),
            )),
          ])
        : SearchExpenseDashboard(
            dashBoardType: dashBoardProvider.selectedDashboardType);
  }

  Widget customRevenueAppBar() {
    var languageProvider =
    Provider.of<LanguageProvider>(context, listen: false);
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    var style = TextStyle(fontSize: 14, color: Colors.white);

    return Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(color: Theme.of(context).appBarTheme.backgroundColor),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children : [
                    SizedBox(width: 2),
                    Image(
                        width: 130,
                        image: NetworkImage(
                          languageProvider.stateInfo!.logoUrlWhite!,
                        ))
                  ]),
              Wrap(
                spacing: 3,
                children: [
                  Text(
                      ApplicationLocalizations.of(context).translate(
                          commonProvider.userDetails?.selectedtenant?.code ??
                              ''),
                      style: style),
                  Text(
                      ApplicationLocalizations.of(context).translate(
                          commonProvider
                              .userDetails?.selectedtenant?.city?.code ??
                              ''),
                      style: style)
                ],
              )
            ]));
  }

  Widget _buildMainTabs() {
    var dashBoardProvider =
        Provider.of<DashBoardProvider>(context, listen: false);

    return Container(
      child: Wrap(
        children: [
          TabButton(i18.dashboard.COLLECTIONS,
              isMainTab: true,
              isSelected: dashBoardProvider.selectedDashboardType ==
                  DashBoardType.collections,
              onPressed: () => dashBoardProvider.onChangeOfMainTab(
                  context, DashBoardType.collections)),
          TabButton(i18.dashboard.EXPENDITURE,
              isMainTab: true,
              isSelected: dashBoardProvider.selectedDashboardType ==
                  DashBoardType.Expenditure,
              onPressed: () => dashBoardProvider.onChangeOfMainTab(
                  context, DashBoardType.Expenditure)),
        ],
      ),
    );
  }

  Widget get _buildShare => TextButton.icon(
      key: Keys.common.SHARE,
      onPressed: takeScreenShotOfDashboard,
      icon: Image.asset('assets/png/whats_app.png'),
      label: Text(
          ApplicationLocalizations.of(context).translate(i18.common.SHARE)));

  void onTapOfMonthPicker() {
    var dashBoardProvider =
        Provider.of<DashBoardProvider>(context, listen: false);

    RenderBox? box = key.currentContext!.findRenderObject() as RenderBox?;
    Offset position = box!.localToGlobal(Offset.zero);

    CustomOverlay.showOverlay(
        context,
        NestedDatePicker(
            onSelectionOfDate: (date) =>
                dashBoardProvider.onChangeOfDate(date, context),
            selectedMonth: dashBoardProvider.selectedMonth,
            left: position.dx + box.size.width - 200,
            top: position.dy + 60 - 10));
  }

  Future<void> takeScreenShotOfDashboard() async {
    var dashBoardProvider =
        Provider.of<DashBoardProvider>(context, listen: false);

    if (dashBoardProvider.selectedMonth.dateType == DateType.MONTH) {
      if (dashBoardProvider.selectedDashboardType ==
          DashBoardType.Expenditure) {
        dashBoardProvider.createPdfForExpenditure(context);
      } else {
        dashBoardProvider.createPdfForCollection(context);
      }
      return;
    }


    final FlutterShareMe flutterShareMe = FlutterShareMe();
    var fileName = 'annualdashboard';

    Loaders.showLoadingDialog(context, label: '');
    setState(() {
      takeScreenShot = true;
    });

    await Future.delayed(Duration(milliseconds: 100));
    screenshotController
        .capture(delay: Duration(seconds: 1))
        .then((capturedImage) async {
      if (capturedImage == null) return;

      try {
        setState(() {
          takeScreenShot = false;
        });

        if (kIsWeb) {
          var file = CustomFile(capturedImage, fileName, 'png');
          var response = await CoreRepository()
              .uploadFiles(<CustomFile>[file], APIConstants.API_MODULE_NAME);

          if (response.isNotEmpty) {
            var commonProvider =
                Provider.of<CommonProvider>(context, listen: false);
            var res = await CoreRepository()
                .fetchFiles([response.first.fileStoreId!]);
            if (res != null && res.isNotEmpty) {
              var url = res.first.url ?? '';
              if (url.contains(',')) {
                url = url.split(',').first;
              }
              response.first.url = url;

              /// Message which will be share on what's app via web
              var localizedText =
                  '${ApplicationLocalizations.of(context).translate(i18.dashboard.ANNUAL_SHARE_MSG_WEB)}';
              localizedText = localizedText.replaceFirst('{year-year}',
                  '${DateFormats.getMonthAndYear(dashBoardProvider.selectedMonth, context)}');
              localizedText = localizedText.replaceFirst('{link}', '{link}');
              commonProvider.shareonwatsapp(
                  response.first, null, localizedText);
            }
          }
        } else {
          final Directory? directory = await getExternalStorageDirectory();
          final file = await File('${directory?.path}/$fileName.png')
              .writeAsBytes(capturedImage);

          /// Message which will be share on what's app via mobile
          var localizedText =
              '${ApplicationLocalizations.of(context).translate(i18.dashboard.ANNUAL_SHARE_MSG_MOBILE)}';
          localizedText = localizedText.replaceFirst('{year-year}',
              '${DateFormats.getMonthAndYear(dashBoardProvider.selectedMonth, context)}');

          var response = await flutterShareMe.shareToWhatsApp(
              imagePath: file.path,
              fileType: FileType.image,
              msg: localizedText);
          if (response != null && response.contains('PlatformException'))
            ErrorHandler().allExceptionsHandler(context, response);
        }
        Navigator.pop(context);
      } catch (e, s) {
        Navigator.pop(context);
        ErrorHandler().allExceptionsHandler(context, e, s);
      }
    }).catchError((onError, s) {
      setState(() {
        takeScreenShot = false;
      });
      ErrorHandler().allExceptionsHandler(context, onError, s);
    });
  }

  void onClickOfBackButton() {
    CustomOverlay.removeOverLay();
    var dashBoardProvider =
    Provider.of<DashBoardProvider>(context, listen: false);
    if(dashBoardProvider.selectedMonth.dateType != DateType.MONTH) Navigator.pop(context);
    else{
      Navigator.popAndPushNamed(context,Routes.DASHBOARD);}
  }
}
