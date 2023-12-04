import 'package:flutter/material.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:provider/provider.dart';

import '../../providers/ifix_hierarchy_provider.dart';
import '../../repository/water_services_calculation.dart';
import '../../utils/localization/application_localizations.dart';
import '../../utils/common_widgets.dart';
import '../../utils/loaders.dart';
import '../../utils/notifiers.dart';
import '../../widgets/label_text.dart';
import 'gpwsc_card.dart';

class GPWSCRateCard extends StatelessWidget {
  final String rateType;

  const GPWSCRateCard({Key? key, required this.rateType}) : super(key: key);

  Color getColor(Set<MaterialState> states) {
    return Colors.grey.shade200;
  }

  List<Widget> getTableTitle(context, constraints, String rateType) {
    return [
      LabelText(
          "${ApplicationLocalizations.of(context).translate(i18.dashboard.GPWSC_RATE_INFO)}"),
      Padding(
        padding: (constraints.maxWidth > 760
            ? const EdgeInsets.all(15.0)
            : const EdgeInsets.all(8.0)),
        child: Text(
          "(${ApplicationLocalizations.of(context).translate(rateType)})",
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.left,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    WCBillingSlabs? wcBillingSlabs;
    return LayoutBuilder(builder: (context, constraints) {
      var ifixProvider =
          Provider.of<IfixHierarchyProvider>(context, listen: false);
      return GPWSCCard(
        children: [
          constraints.maxWidth < 760
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: getTableTitle(context, constraints, rateType),
                )
              : Row(
                  children: getTableTitle(context, constraints, rateType),
                ),
          StreamBuilder(
              stream: ifixProvider.streamControllerRate.stream,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data is String) {
                    return CommonWidgets.buildEmptyMessage(
                        snapshot.data, context);
                  }
                  wcBillingSlabs = snapshot.data;
                  return Consumer<IfixHierarchyProvider>(
                      key: key,
                      builder: (_, departmentProvider, child) {
                        return _getRateCard(
                            rateType, wcBillingSlabs!, context, constraints);
                      });
                } else if (snapshot.hasError) {
                  return Notifiers.networkErrorPage(context, () => {});
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
              })
        ],
      );
    });
  }

  Widget _getRateCard(String type, WCBillingSlabs wcBillingSlabs, context,
      BoxConstraints constraints) {
    List<DataRow> getMeteredRows() {
      List<DataRow> rows = [];
      wcBillingSlabs.wCBillingSlabs
          ?.where(
              (element) => element.connectionType?.compareTo("Metered") == 0)
          .forEach((e) => e.slabs?.forEach((slabs) => rows.add(DataRow(cells: [
                      DataCell(Text(
                          "${ApplicationLocalizations.of(context).translate(i18.common.WATER_CHARGES)}-10101")),
                      DataCell(Text(
                          "${ApplicationLocalizations.of(context).translate("${e.calculationAttribute}")}")),
                      DataCell(Text("${slabs.from}-${slabs.to}")),
                      DataCell(Text(
                          "${ApplicationLocalizations.of(context).translate("${e.buildingType}")}")),
                      DataCell(Text("${slabs.charge}"))
                    ])))
              );
      return rows;
    }

    if (type.compareTo("Metered") == 0) {
      return Padding(
        padding: constraints.maxWidth > 760
            ? const EdgeInsets.all(20.0)
            : const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
              border: TableBorder.all(
                  width: 0.5,
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              columns: [
                DataColumn(
                    label: Text(
                  "${ApplicationLocalizations.of(context).translate(i18.common.CHARGE_HEAD)}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
                DataColumn(
                    label: Text(
                  "${ApplicationLocalizations.of(context).translate(i18.common.CALC_TYPE)}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
                DataColumn(
                    label: Text(
                  "${ApplicationLocalizations.of(context).translate(i18.common.BILLING_SLAB)}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
                DataColumn(
                    label: Text(
                  "${ApplicationLocalizations.of(context).translate(i18.searchWaterConnection.CONNECTION_TYPE)}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
                DataColumn(
                    label: Text(
                  "${ApplicationLocalizations.of(context).translate(i18.common.RATE_PERCENTAGE)}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
              ],
              rows: getMeteredRows()),
        ),
      );
    }
    return Padding(
      padding: constraints.maxWidth > 760
          ? const EdgeInsets.all(20.0)
          : const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
            border: TableBorder.all(
                width: 0.5, borderRadius: BorderRadius.all(Radius.circular(5))),
            columns: [
              DataColumn(
                  label: Text(
                "${ApplicationLocalizations.of(context).translate(i18.common.CHARGE_HEAD)}",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  label: Text(
                "${ApplicationLocalizations.of(context).translate(i18.common.CALC_TYPE)}",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  label: Text(
                "${ApplicationLocalizations.of(context).translate(i18.searchWaterConnection.CONNECTION_TYPE)}",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  label: Text(
                "${ApplicationLocalizations.of(context).translate(i18.common.RATE_PERCENTAGE)}",
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              )),
            ],
            rows: (wcBillingSlabs.wCBillingSlabs ?? [])
                .where((element) =>
                    element.connectionType?.compareTo("Metered") != 0)
                .map((slab) => DataRow(cells: [
                      DataCell(Text(
                          "${ApplicationLocalizations.of(context).translate(i18.common.WATER_CHARGES)}-10101")),
                      DataCell(Text(
                          "${ApplicationLocalizations.of(context).translate("${slab.calculationAttribute}")}")),
                      DataCell(Text(
                          "${ApplicationLocalizations.of(context).translate("${slab.buildingType}")}")),
                      DataCell(Text("${slab.minimumCharge}"))
                    ]))
                .toList()),
      ),
    );
  }
}
