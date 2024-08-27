import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/components/house_connection_and_bill/consumer_bill_payment.dart';
import 'package:mgramseva/components/house_connection_and_bill/generate_new_bill.dart';
import 'package:mgramseva/components/house_connection_and_bill/house_connection_detail_card.dart';
import 'package:mgramseva/components/house_connection_and_bill/new_consumer_bill.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/model/demand/demand_list.dart';
import 'package:mgramseva/providers/household_details_provider.dart';
import 'package:mgramseva/routers/routers.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/widgets/custom_app_bar.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:mgramseva/widgets/form_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/short_button.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:provider/provider.dart';

class HouseholdDetail extends StatefulWidget {
  final String? id;
  final String? mode;
  final String? status;
  final WaterConnection? waterConnection;
  HouseholdDetail(
      {Key? key, this.id, this.mode, this.status, this.waterConnection});
  @override
  State<StatefulWidget> createState() {
    return _HouseholdDetailState();
  }
}

class _HouseholdDetailState extends State<HouseholdDetail> {
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  afterViewBuild() {
    Provider.of<HouseHoldProvider>(context, listen: false)
      ..isVisible = false
      ..fetchDemand(widget.waterConnection, widget.waterConnection?.demands,
          widget.id, widget.status);
  }

  buildDemandView(DemandList data) {
    var houseHoldProvider =
        Provider.of<HouseHoldProvider>(context, listen: false);

    return Column(
      children: [
        data.demands!.isEmpty
            ? (houseHoldProvider.waterConnection!.connectionType == 'Metered' &&
                    widget.mode == 'collect'
                ? Align(
                    alignment: Alignment.centerRight,
                    child: ShortButton(
                        i18.generateBillDetails.GENERATE_NEW_BTN_LABEL,
                        widget.waterConnection?.status ==
                                Constants.CONNECTION_STATUS.first
                            ? null
                            : () => {
                                  Navigator.pushNamed(
                                      context, Routes.BILL_GENERATE,
                                      arguments:
                                          houseHoldProvider.waterConnection)
                                }))
                : Text(""))
            : Text(""),
        houseHoldProvider.waterConnection!.connectionType == 'Metered' &&
                widget.mode == 'collect'
            ? GenerateNewBill(houseHoldProvider.waterConnection, data)
            : Text(""),
        data.demands!.isEmpty ||
                (houseHoldProvider.waterConnection?.connectionType ==
                        'Metered' &&
                    houseHoldProvider.isfirstdemand == false)
            ? Text("")
            : NewConsumerBill(widget.mode, widget.status,
                houseHoldProvider.waterConnection, data.demands!),
        ConsumerBillPayments(houseHoldProvider.waterConnection)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var houseHoldProvider =
        Provider.of<HouseHoldProvider>(context, listen: false);

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: CustomAppBar(),
        drawer: DrawerWrapper(
          Drawer(child: SideBar()),
        ),
        body: SingleChildScrollView(
            child: FormWrapper(Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              HomeBack(),
              StreamBuilder(
                  stream: houseHoldProvider.streamController.stream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          HouseConnectionDetailCard(
                              waterconnection:
                                  houseHoldProvider.waterConnection),
                          buildDemandView(snapshot.data)
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Notifiers.networkErrorPage(
                          context,
                          () => houseHoldProvider.fetchDemand(
                              widget.waterConnection,
                              widget.waterConnection?.demands));
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
                  }),
              Footer()
            ]))));
  }
}
