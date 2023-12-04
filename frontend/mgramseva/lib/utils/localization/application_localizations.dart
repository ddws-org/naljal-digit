import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mgramseva/model/localization/localization_label.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:provider/provider.dart';

class ApplicationLocalizations {
  ApplicationLocalizations(this.locale);

  final Locale? locale;

  static ApplicationLocalizations of(BuildContext context) {
    return Localizations.of<ApplicationLocalizations>(
        context, ApplicationLocalizations)!;
  }

  List<LocalizationLabel> _localizedStrings = <LocalizationLabel>[];

  Future<bool> load() async {
    if (navigatorKey.currentContext == null) return false;
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);
    _localizedStrings = await commonProvider.getLocalizationLabels();
    return true;
    // if (kIsWeb) {
    //   String? res = window.localStorage['localisation_' + locale.toString()];
    //   if (res != null) {
    //     _localizedStrings = jsonDecode(res);
    //   } else {
    //     _localizedStrings = [];
    //   }
    // }else{
    //   String? res = await storage.read(key: 'localisation_' + locale.toString());
    //   if(res != null){
    //     _localizedStrings = jsonDecode(res);
    //   } else {
    //     _localizedStrings = [];
    //   }
    // }
  }

  // called from every widget which needs a localized text
  translate(String _localizedValues) {
    var commonProvider = Provider.of<CommonProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var index = commonProvider.localizedStrings
        .indexWhere((medium) => medium.code == _localizedValues);
    return index != -1
        ? commonProvider.localizedStrings[index].message
        : _localizedValues;
  }

  static const LocalizationsDelegate<ApplicationLocalizations> delegate =
      _ApplicationLocalizationsDelegate();
}

class _ApplicationLocalizationsDelegate
    extends LocalizationsDelegate<ApplicationLocalizations> {
  const _ApplicationLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pn', 'ar', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<ApplicationLocalizations> load(Locale locale) async {
    ApplicationLocalizations localization =
        new ApplicationLocalizations(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<ApplicationLocalizations> old) =>
      false;
}
