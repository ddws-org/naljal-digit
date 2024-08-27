import 'package:flutter/material.dart';
import 'package:mgramseva/providers/dashboard_provider.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/widgets/label_text.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:provider/provider.dart';

class DashboardCard extends StatelessWidget {
  final Function() onMonthSelection;
  final bool isFromScreenshot;
  DashboardCard(this.onMonthSelection, {this.isFromScreenshot = false});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Card(
          margin: EdgeInsets.only(bottom: isFromScreenshot ? 0 : 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              LabelText(i18.dashboard.DASHBOARD, padding:  isFromScreenshot ? const EdgeInsets.all(5.0) : null),
              Expanded(
                child: InkWell(
                  key: Keys.dashboard.DASHBOARD_DATE_PICKER,
                  onTap: onMonthSelection,
                  child: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Consumer<DashBoardProvider>(
                            builder: (_, dashBoardProvider, child) => Text(
                              DateFormats.getMonthAndYear(
                                  dashBoardProvider.selectedMonth, context),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.apply(
                                      color: Theme.of(context).primaryColor),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: isFromScreenshot ? 8.0 : 3.0),
                            child: Visibility(
                              visible: !isFromScreenshot,
                              child: Icon(Icons.arrow_drop_down),
                            ),
                          )
                        ]),
                  ),
                ),
              )
            ]),
            _buildRatingView(context, constraints)
          ]));
    });
  }

  Widget _buildRatingView(BuildContext context, BoxConstraints constraints) {
    return Consumer<DashBoardProvider>(builder: (_, dashBoardProvider, child) {
      var feedBack = dashBoardProvider.userFeedBackInformation;
      if (feedBack != null && feedBack.isNotEmpty) {
        Map feedBackDetails = Map.from(feedBack);
        feedBackDetails.remove('count');
        var localizationLabel =
            '${ApplicationLocalizations.of(context).translate(i18.dashboard.USER_GAVE_FEEDBACK)}';
        localizationLabel = localizationLabel.replaceAll(
            '{n}', (feedBack['count'] ?? 0).toString());
        localizationLabel = localizationLabel
            .replaceAll(
                '{date}',
                DateFormats.getMonthAndYear(
                    dashBoardProvider.selectedMonth, context))
            .toString();
        return Padding(
          padding: constraints.maxWidth > 760
              ? isFromScreenshot ? const EdgeInsets.all(5.0) : const EdgeInsets.all(20.0)
              : const EdgeInsets.all(8.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GridView.count(
              crossAxisCount: 3,
              childAspectRatio: constraints.maxWidth > 760 ? (isFromScreenshot ? (1 / .2) : ((1 / .3))) : 1.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: List.generate(
                  feedBackDetails.keys.length,
                  (index) => GridTile(
                        child: Container(
                          alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: index == 0
                                  ? null
                                  : Border(
                                      left: BorderSide(
                                          width: 1.0, color: Colors.grey)),
                              color: Colors.white,
                            ),
                            // alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      new Text(
                                        feedBackDetails.values
                                            .toList()[index]
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Icon(Icons.star,
                                          color:
                                              Theme.of(context).primaryColor),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      '${ApplicationLocalizations.of(context).translate('DASHBOARD_${feedBackDetails.keys.toList()[index].toString()}')}',
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ])),
                      )).toList(),
            ),
            Padding(
              padding:  EdgeInsets.symmetric(vertical: isFromScreenshot ? 5 : 10),
              child: Text(
                "$localizationLabel",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(11, 12, 12, 1),
                    fontWeight: FontWeight.w400),
              ),
            ),
          ]),
        );
      } else {
        return Container();
      }
    });
  }
}
