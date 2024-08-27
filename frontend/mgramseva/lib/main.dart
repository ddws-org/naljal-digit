import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
// import 'package:dart_ping_ios/dart_ping_ios.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mgramseva/env/app_config.dart';
import 'package:mgramseva/providers/reports_provider.dart';
import 'package:mgramseva/routing.dart';
import 'package:mgramseva/providers/authentication_provider.dart';
import 'package:mgramseva/providers/bill_generation_details_provider.dart';
import 'package:mgramseva/providers/bill_payments_provider.dart';
import 'package:mgramseva/providers/change_password_details_provider.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/consumer_details_provider.dart';
import 'package:mgramseva/providers/demand_details_provider.dart';
import 'package:mgramseva/providers/expenses_details_provider.dart';
import 'package:mgramseva/providers/fetch_bill_provider.dart';
import 'package:mgramseva/providers/forgot_password_provider.dart';
import 'package:mgramseva/providers/home_provider.dart';
import 'package:mgramseva/providers/household_details_provider.dart';
import 'package:mgramseva/providers/household_register_provider.dart';
import 'package:mgramseva/providers/ifix_hierarchy_provider.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/providers/notification_screen_provider.dart';
import 'package:mgramseva/providers/notifications_provider.dart';
import 'package:mgramseva/providers/reset_password_provider.dart';
import 'package:mgramseva/providers/search_connection_provider.dart';
import 'package:mgramseva/providers/tenants_provider.dart';
import 'package:mgramseva/providers/transaction_update_provider.dart';
import 'package:mgramseva/providers/user_edit_profile_provider.dart';
import 'package:mgramseva/providers/user_profile_provider.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/screeens/home/home.dart';
import 'package:mgramseva/screeens/select_language/select_language.dart';
import 'package:mgramseva/theme.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:url_strategy/url_strategy.dart';

import 'providers/collect_payment_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/revenue_dashboard_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  setPathUrlStrategy();
  //configureApp();
  setEnvironment(Environment.dev);
  // Register DartPingIOS
  // if (Platform.isIOS) {
  //   DartPingIOS.register();
  // }
  // Uncomment when compiling on iOS
  runZonedGuarded(() async {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
      ErrorHandler.logError(details.exception.toString(), details.stack);
      // exit(1); /// to close the app smoothly
    };

    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: 'assets/.env');
    if (kIsWeb) {
      await Firebase.initializeApp(
          options: FirebaseConfigurations.firebaseOptions);
    } else {
      await Firebase.initializeApp();
    }
    if (Firebase.apps.length == 0) {}

    if (!kIsWeb) {
      await FlutterDownloader.initialize(
          debug: true // optional: set false to disable printing logs to console
          );
    }

    await CommonMethods.fetchPackageInfo();

    runApp(
      MyApp(),
    );
  }, (Object error, StackTrace stack) {
    ErrorHandler.logError(error.toString(), stack);
    // exit(1); /// to close the app smoothly
  });

  // runApp(new MyApp());
}

_MyAppState myAppstate = '' as _MyAppState;

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() {
    myAppstate = _MyAppState();
    return myAppstate;
  }
}

class _MyAppState extends State<MyApp> {
  late Locale _locale = Locale('en', 'IN');
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);
  ReceivePort _port = ReceivePort();

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;

    send.send([id, DownloadTaskStatus.values.elementAt(status), progress]);
  }

  afterViewBuild() async {
    if (kIsWeb) return;
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      // int progress = data[2];
      // print("Download progress: "+progress.toString());
      if (status == DownloadTaskStatus.complete) {
        if (CommonProvider.downloadUrl.containsKey(id)) {
          if (CommonProvider.downloadUrl[id] != null)
            OpenFilex.open(CommonProvider.downloadUrl[id] ?? '');
          CommonProvider.downloadUrl.remove(id);
        } else if (status == DownloadTaskStatus.failed ||
            status == DownloadTaskStatus.canceled ||
            status == DownloadTaskStatus.undefined) {
          if (CommonProvider.downloadUrl.containsKey(id))
            CommonProvider.downloadUrl.remove(id);
        }
      }
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ConsumerProvider()),
          ChangeNotifierProvider(create: (_) => UserProfileProvider()),
          ChangeNotifierProvider(create: (_) => CommonProvider()),
          ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
          ChangeNotifierProvider(create: (_) => ExpensesDetailsProvider()),
          ChangeNotifierProvider(create: (_) => ChangePasswordProvider()),
          ChangeNotifierProvider(create: (_) => UserEditProfileProvider()),
          ChangeNotifierProvider(create: (_) => ExpensesDetailsProvider()),
          ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
          ChangeNotifierProvider(create: (_) => ResetPasswordProvider()),
          ChangeNotifierProvider(create: (_) => TenantsProvider()),
          ChangeNotifierProvider(create: (_) => BillGenerationProvider()),
          ChangeNotifierProvider(create: (_) => TenantsProvider()),
          ChangeNotifierProvider(create: (_) => HouseHoldProvider()),
          ChangeNotifierProvider(create: (_) => SearchConnectionProvider()),
          ChangeNotifierProvider(create: (_) => CollectPaymentProvider()),
          ChangeNotifierProvider(create: (_) => DashBoardProvider()),
          ChangeNotifierProvider(create: (_) => BillPaymentsProvider()),
          ChangeNotifierProvider(create: (_) => HomeProvider()),
          ChangeNotifierProvider(create: (_) => DemandDetailProvider()),
          ChangeNotifierProvider(create: (_) => FetchBillProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => RevenueDashboard()),
          ChangeNotifierProvider(create: (_) => HouseholdRegisterProvider()),
          ChangeNotifierProvider(create: (_) => NotificationScreenProvider()),
          ChangeNotifierProvider(create: (_) => TransactionUpdateProvider()),
          ChangeNotifierProvider(create: (_) => IfixHierarchyProvider()),
          ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ],
        child: Consumer<LanguageProvider>(
            builder: (_, userProvider, child) => GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: MaterialApp(
                  title: 'mGramSeva',
                  supportedLocales: [
                    Locale('en', 'IN'),
                    Locale('hi', 'IN'),
                    Locale.fromSubtags(languageCode: 'pn')
                  ],
                  locale: _locale,
                  localizationsDelegates: [
                    ApplicationLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: (locale, supportedLocales) {
                    for (var supportedLocaleLanguage in supportedLocales) {
                      if (supportedLocaleLanguage.languageCode ==
                              locale?.languageCode &&
                          supportedLocaleLanguage.countryCode ==
                              locale?.countryCode) {
                        return supportedLocaleLanguage;
                      }
                    }
                    return supportedLocales.first;
                  },
                  navigatorKey: navigatorKey,
                  navigatorObservers: <NavigatorObserver>[observer],
                  initialRoute: Routes.LANDING_PAGE,
                  onGenerateRoute: Routing.generateRoute,
                  theme: theme,
                  // home: SelectLanguage((val) => setLocale(Locale(val, 'IN'))),
                ))));
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  // @override
  // void dispose() {
  //   IsolateNameServer.removePortNameMapping('downloader_send_port');
  //   super.dispose();
  // }
  //
  // static void downloadCallback(
  //     String id, DownloadTaskStatus status, int progress) {
  //   final SendPort send =
  //       IsolateNameServer.lookupPortByName('downloader_send_port')!;
  //
  //   send.send([id, status, progress]);
  // }
  //
  afterViewBuild() async {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    commonProvider.getLoginCredentials();
    await commonProvider.getAppVersionDetails();
    if (!kIsWeb)
      CommonMethods().checkVersion(context, commonProvider.appVersion!);
  }

  @override
  Widget build(BuildContext context) {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    return Scaffold(
      body: StreamBuilder(
          stream: commonProvider.userLoggedStreamCtrl.stream,
          builder: (context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:

                /// While waiting for the data to load, show a loading spinner.
                return Loaders.circularLoader();
              default:
                if (snapshot.hasError) {
                  return Notifiers.networkErrorPage(context, () {});
                } else {
                  if (snapshot.data != null &&
                      commonProvider.userDetails!.isFirstTimeLogin == true) {
                    return Home();
                  }
                  return SelectLanguage();
                }
            }
          }),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
