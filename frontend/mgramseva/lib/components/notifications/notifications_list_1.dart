import 'package:flutter/material.dart';
import 'package:mgramseva/model/events/events_List.dart';
import 'package:mgramseva/providers/notifications_provider.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/widgets/button_link.dart';
import 'package:mgramseva/widgets/list_label_text.dart';
import 'package:mgramseva/widgets/notifications.dart';
import 'package:provider/provider.dart';

class NotificationsList extends StatefulWidget {
  final bool close;
  const NotificationsList({Key? key, required this.close})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return NotificationsListState();
  }
}

class NotificationsListState extends State<NotificationsList> {
  buildNotificationsView(List<Events>? events) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(mainAxisSize: MainAxisSize.min, children: [
        events!.length > 0
            ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListLabelText(ApplicationLocalizations.of(context)
                    .translate(i18.common.NOTIFICATIONS) +
                " (" +
                events.length.toString() +
                ")"),
              (events.length > 0)? Center(
                  child: ButtonLink(i18.common.VIEW_ALL, () => Navigator.pushNamed(context, Routes.NOTIFICATIONS))) : Text(""),
            ])
            : Text(""),
        ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, i) {
              var item = events[i];
              callBack() {
                Provider.of<NotificationProvider>(context, listen: false)
              ..updateNotify(item, events);
              }
              return Notifications(item, callBack, widget.close);
            }),
        (events.length > 0)? Center(
            child: ButtonLink(i18.common.VIEW_ALL, () => Navigator.pushNamed(context, Routes.NOTIFICATIONS))) : Text(""),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    var billPaymentsProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    return StreamBuilder(
        stream: billPaymentsProvider.streamController.stream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return buildNotificationsView(snapshot.data);
          } else if (snapshot.hasError) {
            return Notifiers.networkErrorPage(context, () {});
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
}
