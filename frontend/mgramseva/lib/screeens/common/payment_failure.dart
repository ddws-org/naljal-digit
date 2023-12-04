import 'package:flutter/material.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/widgets/no_login_failure_page.dart';
import 'package:provider/provider.dart';

import '../../model/localization/language.dart';
import '../../providers/language.dart';
import '../../utils/loaders.dart';
import '../../utils/notifiers.dart';

class PaymentFailure extends StatefulWidget {
  PaymentFailure({Key? key});
  @override
  State<StatefulWidget> createState() {
    return _PaymentFailureState();
  }
}

class _PaymentFailureState extends State<PaymentFailure> {
  List<StateInfo>? stateList;
  Languages? selectedLanguage;

  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  afterViewBuild() async {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider
        .getLocalizationData(context)
        .then((value) => callNotifyer());
  }

  @override
  Widget build(BuildContext context) {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: Text('mGramSeva'),
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder(
            stream: languageProvider.streamController.stream,
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                var stateData = snapshot.data as List<StateInfo>;
                stateList = stateData;
                var index = stateData.first.languages
                    ?.indexWhere((element) => element.isSelected);
                if (index != null && index != -1) {
                  selectedLanguage = stateData.first.languages?[index];
                } else {
                  selectedLanguage = stateData.first.languages?.first;
                }
                return _buildFailurePage(context);
              } else if (snapshot.hasError) {
                return Notifiers.networkErrorPage(context,
                    () => languageProvider.getLocalizationData(context));
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
  }

  Widget _buildFailurePage(BuildContext context) {
    return NoLoginFailurePage(i18.payment.PAYMENT_FAILED);
  }

  Widget _buildDropDown() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: DropdownButton(
          value: selectedLanguage,
          style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16),
          items: dropDownItems,
          onChanged: onChangeOfLanguage),
    );
  }

  callNotifyer() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {});
  }

  get dropDownItems {
    return stateList?.first.languages!.map((value) {
      return DropdownMenuItem(
        value: value,
        child: Text('${value.label}'),
      );
    }).toList();
  }

  void onChangeOfLanguage(value) {
    selectedLanguage = value;
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.onSelectionOfLanguage(
        value!, stateList?.first.languages ?? []);
  }
}
