import 'package:flutter/material.dart';
import 'package:mgramseva/model/events/events_List.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class Notifications extends StatefulWidget {
  final Events? event;
  final VoidCallback? callback;
  final bool close;
  Notifications(this.event, this.callback, this.close);
  @override
  State<StatefulWidget> createState() {
    return _NotificationsState();
  }
}

stringReplacer(String? input, Map? pattern) {
  var output = input;
  pattern?.keys.forEach((element) {
    output = output!.replaceFirst(element, pattern[element]);
  });
  return output;
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          decoration: BoxDecoration(
            border: Border(
              left:
                  BorderSide(width: 5.0, color: Theme.of(context).primaryColor),
            ),
            /*** The BorderRadius widget  is here ***/
            //BorderRadius.all
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: widget.event!.actions != null &&
                      widget.event!.actions?.actionUrls?.first
                          .actionUrl !=
                          "" ? () {
                    Navigator.pushNamed(context,
                            widget.event!.actions!.actionUrls!.first.actionUrl!);
                  } : null,
                  child: Container(
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Text(
                                    ApplicationLocalizations.of(context)
                                        .translate(widget.event?.name != null
                                            ? widget.event!.name!
                                            : ""),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Theme.of(context).primaryColorDark),
                                  )),
                              new Container(
                                  padding: EdgeInsets.all(4),
                                  width: !widget.close
                                      ? MediaQuery.of(context).size.width >720 ? MediaQuery.of(context).size.width/1.4 :  MediaQuery.of(context).size.width / 1.15
                                      : MediaQuery.of(context).size.width / 1.4,
                                  child: Text(
                                    stringReplacer(
                                        ApplicationLocalizations.of(context)
                                            .translate(widget
                                                        .event
                                                        ?.additionalDetails
                                                        ?.localizationCode !=
                                                    null
                                                ? widget
                                                    .event!
                                                    .additionalDetails!
                                                    .localizationCode
                                                    .trim()
                                                : "")
                                            .toString(),
                                        widget.event?.additionalDetails
                                            ?.attributes),
                                    //maxLines: 4,
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                    textAlign: TextAlign.left,
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: 24, bottom: 4, left: 4, right: 4),
                                  child: Text(
                                    DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(widget.event!.auditDetails!.createdTime!)).inDays > 0
                                        ? (DateTime.now()
                                                .difference(
                                                    DateTime.fromMillisecondsSinceEpoch(
                                                        widget
                                                            .event!
                                                            .auditDetails!
                                                            .createdTime!))
                                                .inDays
                                                .toString() +
                                            " " +
                                            (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(widget.event!.auditDetails!.createdTime!)).inDays.toString() == '1'
                                                ? ApplicationLocalizations.of(context)
                                                    .translate(i18
                                                        .generateBillDetails
                                                        .DAY_AGO)
                                                : ApplicationLocalizations.of(context)
                                                    .translate(
                                                        i18.generateBillDetails.DAYS_AGO)))
                                        : ApplicationLocalizations.of(context).translate(i18.generateBillDetails.TODAY),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .primaryColorLight),
                                  ))
                            ],
                          )))),
              Visibility(
                  visible: widget.close,
                  child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                          child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).primaryColorLight,
                          size: 20.0,
                        ),
                        onPressed: widget.callback,
                      )))),
            ],
          )),
    );
  }
}
