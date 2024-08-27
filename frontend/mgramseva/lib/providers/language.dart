import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/repository/core_repo.dart';
import 'package:mgramseva/services/local_storage.dart';
import 'package:mgramseva/services/mdms.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/custom_exception.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:universal_html/html.dart';

class LanguageProvider with ChangeNotifier {
  var streamController = StreamController.broadcast();
  var userLoggedStreamCtrl = StreamController.broadcast();
  StateInfo? stateInfo;

  dispose() {
    streamController.close();
    super.dispose();
  }

  Future<void> getLocalizationData(BuildContext context) async {
    try {
      var res = await getLanguages();
      if (res != null) {
        stateInfo ??= res;
        setSelectedState(res);
        await ApplicationLocalizations(
                Locale(selectedLanguage?.label ?? '', selectedLanguage?.value))
            .load();
        var stateInfos = <StateInfo>[];
        stateInfos.add(new StateInfo.fromJson(res.toJson()));
        streamController.add(stateInfos);
      } else {
        var localizationList =
            await CoreRepository().getMdms(initRequestBody({"tenantId": dotenv.get('STATE_LEVEL_TENANT_ID')}));
        stateInfo = localizationList.mdmsRes?.commonMasters?.stateInfo?.first;
        if (stateInfo != null) {
          stateInfo?.languages?.first.isSelected = true;
          setSelectedState(stateInfo!);
          await ApplicationLocalizations(Locale(
                  selectedLanguage?.label ?? '', selectedLanguage?.value))
              .load();
        }
        streamController.add(
            localizationList.mdmsRes?.commonMasters?.stateInfo ??
                <StateInfo>[]);
      }
    } on CustomException catch (e, s) {
      ErrorHandler.handleApiException(context, e, s);
      streamController.addError('error');
    } catch (e, s) {
      ErrorHandler.logError(e.toString(), s);
      streamController.add('error');
    }
  }

  void onSelectionOfLanguage(
      Languages language, List<Languages> languages) async {
    if (language.isSelected) return;
    languages.forEach((element) => element.isSelected = false);
    language.isSelected = true;
    languages[languages.indexOf(language)] = language;
    stateInfo!.languages = languages;

    setSelectedState(stateInfo!);
    await ApplicationLocalizations(
            Locale(selectedLanguage?.label ?? '', selectedLanguage?.value))
        .load();
    notifyListeners();
  }

  void setSelectedState(StateInfo stateInfo) {
    if (kIsWeb) {
      window.localStorage[Constants.STATES_KEY] =
          jsonEncode(stateInfo.toJson());
    } else {
      storage.write(
          key: Constants.STATES_KEY, value: jsonEncode(stateInfo.toJson()));
    }
  }

  Future<StateInfo?> getLanguages() async {
    var userReposne;
    try {
      if (kIsWeb) {
        userReposne = window.localStorage[Constants.STATES_KEY];
      } else {
        userReposne = await storage.read(key: Constants.STATES_KEY);
      }
    } catch (e) {
      userLoggedStreamCtrl.add(null);
    }

    return userReposne != null
        ? StateInfo.fromJson(jsonDecode(userReposne))
        : null;
  }

  Languages? get selectedLanguage =>
      stateInfo?.languages?.firstWhere((element) => element.isSelected);
}
