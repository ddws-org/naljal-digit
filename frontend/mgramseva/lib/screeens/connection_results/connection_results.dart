import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/connection/water_connections.dart';
import 'package:mgramseva/providers/search_connection_provider.dart';
import 'package:mgramseva/screeens/connection_results/connection_details_card.dart';
import 'package:mgramseva/widgets/custom_app_bar.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/form_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:provider/provider.dart';

class SearchConsumerResult extends StatefulWidget {
  static const String routeName = 'search/consumer';
  final Map arguments;
  SearchConsumerResult(this.arguments);
  @override
  State<StatefulWidget> createState() {
    return _SearchConsumerResultState();
  }
}

class _SearchConsumerResultState extends State<SearchConsumerResult> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  afterViewBuild() {
    Provider.of<SearchConnectionProvider>(context, listen: false)..getresults();
  }

  buildconsumerView(WaterConnections waterConnections) {
    return SearchConnectionDetailCard(
      waterConnections,
      widget.arguments,
      isNameSearch: widget.arguments['isNameSearch'],
    );
  }

  @override
  Widget build(BuildContext context) {
    var waterconnectionsProvider =
        Provider.of<SearchConnectionProvider>(context, listen: false);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: CustomAppBar(),
        drawer: DrawerWrapper(
          Drawer(child: SideBar()),
        ),
        body: FormWrapper(Container(
            child: Column(children: [
          HomeBack(),
          Expanded(
              child: StreamBuilder(
                  stream: waterconnectionsProvider.streamController.stream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return buildconsumerView(snapshot.data);
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
                  }))
        ]))));
  }
}
