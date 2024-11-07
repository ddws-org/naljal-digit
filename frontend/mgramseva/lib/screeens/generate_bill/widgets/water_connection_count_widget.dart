import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mgramseva/model/reports/WaterConnectionCount.dart';
import 'package:mgramseva/providers/reports_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:provider/provider.dart';

import '../../../utils/localization/application_localizations.dart';
import '../../../widgets/label_text.dart';
import 'count_table_widget.dart';

class WaterConnectionCountWidget extends StatefulWidget {
  @override
  _WaterConnectionCountWidgetState createState() =>
      _WaterConnectionCountWidgetState();
}

class _WaterConnectionCountWidgetState
    extends State<WaterConnectionCountWidget> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  afterViewBuild() {
    Provider.of<ReportsProvider>(context, listen: false)
      ..getWaterConnectionsCount();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Container(
            child: Column(
              children: [
                LabelText(
                    '${"${ApplicationLocalizations.of(context).translate(i18.common.WS_REPORTS_WATER_CONNECTION_COUNT)}"}'),
                Container(
                  margin: MediaQuery.of(context).size.width > 760
                      ? EdgeInsets.only(
                          top: 5.0, bottom: 5, right: 20, left: 20)
                      : EdgeInsets.only(top: 5.0, bottom: 5, right: 8, left: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final provider = Provider.of<ReportsProvider>(context);
                      final waterConnectionCount =
                          provider.waterConnectionCount;
                      if (waterConnectionCount == null) {
                        return SizedBox();
                      }
                      return Column(
                        children: [
                          if (waterConnectionCount.waterConnectionsDemandGenerated !=
                                  null &&
                              waterConnectionCount
                                      .waterConnectionsDemandGenerated
                                      ?.length !=
                                  0 &&
                              constraints.maxWidth > 760)
                            _buildDataTableRow(
                              context,
                              "${ApplicationLocalizations.of(context).translate(i18.common.LAST_BILL_CYCLE_DEMAND_GENERATED)}",
                              waterConnectionCount
                                  .waterConnectionsDemandGenerated,
                                 
                            ),
                          if (waterConnectionCount.waterConnectionsDemandGenerated !=
                                  null &&
                              waterConnectionCount
                                      .waterConnectionsDemandGenerated
                                      ?.length !=
                                  0 &&
                              constraints.maxWidth <= 760)
                            _buildDataTableColumn(
                              context,
                              "${ApplicationLocalizations.of(context).translate(i18.common.LAST_BILL_CYCLE_DEMAND_GENERATED)}",
                              waterConnectionCount
                                  .waterConnectionsDemandGenerated,

                            ),
                          SizedBox(height: 20),
                          if (waterConnectionCount.waterConnectionsDemandNotGenerated !=
                                  null &&
                              waterConnectionCount
                                      .waterConnectionsDemandNotGenerated
                                      ?.length !=
                                  0 &&
                              constraints.maxWidth > 760)
                            _buildDataTableRow(
                              context,
                              "${ApplicationLocalizations.of(context).translate(i18.common.LAST_BILL_CYCLE_DEMAND_NOT_GENERATED)}",
                              waterConnectionCount
                                  .waterConnectionsDemandNotGenerated,
                                  isWCDemandNotGenerated: true

                            ),
                          if (waterConnectionCount.waterConnectionsDemandNotGenerated !=
                                  null &&
                              waterConnectionCount
                                      .waterConnectionsDemandNotGenerated
                                      ?.length !=
                                  0 &&
                              constraints.maxWidth <= 760)
                            _buildDataTableColumn(
                              context,
                              "${ApplicationLocalizations.of(context).translate(i18.common.LAST_BILL_CYCLE_DEMAND_NOT_GENERATED)}",
                              waterConnectionCount
                                  .waterConnectionsDemandNotGenerated,
                                  isWCDemandNotGenerated: true
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataTableRow(BuildContext context, String title,
      List<WaterConnectionCount>? waterConnections,{bool isWCDemandNotGenerated = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          
          alignment: Alignment.centerLeft,
          width: MediaQuery.of(context).size.width / 3,
          padding: EdgeInsets.only(top: 18, bottom: 3),
          child: Text(title ),
        ),
        Container(
          width: MediaQuery.of(context).size.width / 2.5,
          padding: EdgeInsets.only(top: 18, bottom: 3),
          child: CountTableWidget(waterConnectionCount: waterConnections,
          isWCDemandNotGenerated: isWCDemandNotGenerated,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTableColumn(BuildContext context, String title,
      List<WaterConnectionCount>? waterConnections,{bool isWCDemandNotGenerated = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        SizedBox(height: 10),
        CountTableWidget(waterConnectionCount: waterConnections,
        isWCDemandNotGenerated: isWCDemandNotGenerated,
        ),
      ],
    );
  }
}
