import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mgramseva/model/localization/language.dart';
import 'package:mgramseva/model/success_handler.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/repository/core_repo.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/error_logging.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/widgets/common_success_page.dart';
import 'package:mgramseva/widgets/form_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/label_text.dart';
import 'package:mgramseva/widgets/short_button.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:provider/provider.dart';


class PaymentFeedBack extends StatefulWidget {
  final Map query;
  final bool isFromTakeSurveyBtn;
  const PaymentFeedBack(
      {Key? key, required this.query, this.isFromTakeSurveyBtn = false})
      : super(key: key);

  @override
  _PaymentFeedBackState createState() => _PaymentFeedBackState();
}

class _PaymentFeedBackState extends State<PaymentFeedBack> {
  double waterSupply = 0.0;
  double supplyRegular = 0.0;
  double qualityGood = 0.0;
  List<StateInfo>? stateList;
  Languages? selectedLanguage;

  @override
  void initState() {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider
        .getLocalizationData(context)
        .then((value) => callNotifyer());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FocusWatcher(
        child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              title: Text('mGramSeva'),
              automaticallyImplyLeading: false,
              actions: [_buildDropDown()],
            ),
            body: _buildLocalizationData()));
  }

  Widget _buildView() {
    String requestText = ApplicationLocalizations.of(context)
        .translate(i18.postPaymentFeedback.SURVEY_REQUEST);
    requestText =
        requestText.replaceAll('{connectionNo}', widget.query['connectionno']);
    requestText = requestText.replaceAll('{GPWSC}', 'GPWSC');
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 5),
      child: SingleChildScrollView(
        child: FormWrapper(Column(
          children: [
            Visibility(visible: widget.isFromTakeSurveyBtn, child: HomeBack()),
            Card(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabelText(i18.postPaymentFeedback.HELP_US_HELP_YOU),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Text(requestText),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRating(
                            i18.postPaymentFeedback.HAPPY_WITH_WATER_SUPPLY,
                            (rating) => onChangeOfRating(0, rating)),
                        _buildRating(
                            i18.postPaymentFeedback.IS_WATER_SUPPLY_REGULAR,
                            (rating) => onChangeOfRating(1, rating)),
                        _buildRating(
                            i18.postPaymentFeedback.IS_WATER_QUALITY_GOOD,
                            (rating) => onChangeOfRating(2, rating)),
                      ]),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: ShortButton(
                      i18.common.SUBMIT,
                      (waterSupply > 0.0 &&
                              supplyRegular > 0.0 &&
                              qualityGood > 0.0)
                          ? onSubmit
                          : null),
                )
              ],
            )),
            Footer()
          ],
        )),
      ),
    );
  }

  Widget _buildRating(String label, ValueChanged<double> callBack) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ApplicationLocalizations.of(context).translate(label),
            style:
                TextStyle(fontSize: 16, color: Color.fromRGBO(11, 12, 12, 1)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: RatingBar.builder(
                  initialRating: 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  // unratedColor: Colors.transparent,
                  glowColor: Colors.red,
                  itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Theme.of(context).primaryColor,
                      ),
                  onRatingUpdate: callBack),
            ),
          )
        ]);
  }

  void onChangeOfRating(int index, double rating) {
    switch (index) {
      case 0:
        waterSupply = rating;
        break;
      case 1:
        supplyRegular = rating;
        break;
      case 2:
        qualityGood = rating;
        break;
    }
    setState(() {});
  }

  Future<void> onSubmit() async {

    Loaders.showLoadingDialog(context);

    try {
      var body = {
        "RequestInfo": {},
        'feedback': {
          "tenantId": widget.query['tenantId'],
          "paymentId": widget.query['paymentId'],
          "connectionno": widget.query['connectionno'],
          "additionaldetails": {
            "CheckList": [
              {
                "code": "HAPPY_WATER_SUPPLY",
                "type": "SINGLE_SELECT",
                "value": waterSupply.toInt().toString()
              },
              {
                "code": "WATER_QUALITY_GOOD",
                "type": "SINGLE_SELECT",
                "value": supplyRegular.toInt().toString()
              },
              {
                "code": "WATER_SUPPLY_REGULAR",
                "type": "SINGLE_SELECT",
                "value": qualityGood.toInt().toString()
              }
            ]
          }
        }
      };

      await CoreRepository().submitFeedBack(body);

      Navigator.pop(context);

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => CommonSuccess(
                  SuccessHandler(
                      i18.postPaymentFeedback.FEED_BACK_SUBMITTED_SUCCESSFULLY,
                      i18.postPaymentFeedback
                          .FEEDBACK_RESPONSE_SUBMITTED_SUCCESSFULLY,
                      '',
                      Routes.FEED_BACK_SUBMITTED_SUCCESSFULLY),
                  backButton: false,
                  isWithoutLogin: true),
              settings: RouteSettings(name: '/feedBack/success')));
    } catch (e, s) {
      Navigator.pop(context);
      ErrorHandler().allExceptionsHandler(context, e, s);
    }
  }

  Widget _buildLocalizationData() {
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    return StreamBuilder(
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
            return _buildView();
          } else if (snapshot.hasError) {
            return Notifiers.networkErrorPage(
                context, () => languageProvider.getLocalizationData(context));
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
        });
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

  void onChangeOfLanguage(value) {
    selectedLanguage = value;
    var languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.onSelectionOfLanguage(
        value!, stateList?.first.languages ?? []);
  }

  callNotifyer() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  get dropDownItems {
    return stateList?.first.languages?.map((value) {
      return DropdownMenuItem(
        value: value,
        child: Text('${value.label}'),
      );
    }).toList();
  }
}
