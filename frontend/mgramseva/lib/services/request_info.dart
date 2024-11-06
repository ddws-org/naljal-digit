import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:provider/provider.dart';

class RequestInfo {
  final apiId;
  final ver;
  final ts;
  final action;
  final did;
  final key;
  final msgId;
  final authToken;
  Map? userInfo;
  RequestInfo(this.apiId, this.ver, this.ts, this.action, this.did, this.key,
      this.msgId, this.authToken,
      [this.userInfo]);
  var languageProvider = Provider.of<LanguageProvider>(
      navigatorKey.currentContext!,
      listen: false);
  Map<String, dynamic> toJson() => {
        "apiId": apiId == null ? null : apiId,
        "ver": ver == null ? 1 : ver,
        "ts": ts == null ? null : ts,
        "action": action == null ? null : action,
        "did": did == null ? null : did,
        "key": key == null ? null : key,
        "msgId": languageProvider.selectedLanguage != null
            ? '20170310130900|' +
                languageProvider.selectedLanguage!.value.toString()
            : "",
        "authToken": authToken == null ? null : authToken,
        "userInfo": userInfo
      };
}
