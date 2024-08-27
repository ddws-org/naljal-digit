import 'package:flutter/material.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/household_details_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:provider/provider.dart';

class HouseConnectionDetailCard extends StatelessWidget {
  final WaterConnection? waterconnection;
  HouseConnectionDetailCard({this.waterconnection});
  _getLabelText(label, value, context) {
    return (Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
              padding: EdgeInsets.only(top: 16, bottom: 16),
              width: MediaQuery.of(context).size.width / 3,
              child: Text(
                ApplicationLocalizations.of(context).translate(label),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              )),
          new Flexible(
              child: Container(
                  padding: EdgeInsets.only(top: 16, bottom: 16, left: 8),
                  child: Text(
                      ApplicationLocalizations.of(context).translate(value),
                      maxLines: 3,
                      softWrap: true,
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400))))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    var commonProvider = Provider.of<CommonProvider>(context,
        listen: false);
    return Card(
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: Text(
                            "${ApplicationLocalizations.of(context).translate(
                              i18.consumer.CONSUMER_CONNECTION_ID,
                            )} ",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          )),
                      Container(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            waterconnection!.connectionNo!,
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w700),
                          )),
                    ],
                  ),
                ),
                _getLabelText(i18.searchWaterConnection.RESULTS_CONSUMER_NAME,
                    waterconnection!.connectionHolders!.first.name, context),
                _getLabelText(
                    i18.consumer.FATHER_SPOUSE_NAME,
                    waterconnection?.connectionHolders?.first.fatherOrHusbandName != null &&
                        waterconnection!.connectionHolders!.first.fatherOrHusbandName!.isNotEmpty ? waterconnection!
                        .connectionHolders!.first.fatherOrHusbandName : "NA",
                    context),
                _getLabelText(
                    i18.searchWaterConnection.RESULTS_PHONE_NUM,
                    waterconnection!.connectionHolders!.first.mobileNumber,
                    context),
                _getLabelText(
                    i18.searchWaterConnection.OLD_CONNECTION_ID,
                    waterconnection!.oldConnectionNo != ""
                        ? waterconnection!.oldConnectionNo
                        : "NA",
                    context),
                _getLabelText(
                  ApplicationLocalizations.of(context)
                      .translate(i18.searchWaterConnection.RESULTS_ADDRESS),
                  (waterconnection!.additionalDetails!.doorNo != null
                          ? waterconnection!.additionalDetails!.doorNo! != ""
                              ? waterconnection!.additionalDetails!.doorNo! +
                                  ', '
                              : ""
                          : "") +
                      (waterconnection!.additionalDetails!.street != null
                          ? waterconnection!.additionalDetails!.street! != ""
                              ? waterconnection!.additionalDetails!.street! +
                                  ', '
                              : ""
                          : "") +
                      (waterconnection!.additionalDetails!.locality!.isNotEmpty
                          ? ApplicationLocalizations.of(context)
                          .translate(waterconnection!.additionalDetails!.locality.toString())
                          : "") + ApplicationLocalizations.of(context)
                      .translate(commonProvider.userDetails!.selectedtenant!.code!),
                  context,
                ),
                _getLabelText(i18.searchWaterConnection.PROPERTY_TYPE,
                    waterconnection!.additionalDetails!.propertyType, context),
                _getLabelText(i18.consumer.SERVICE_TYPE,
                    waterconnection!.connectionType, context),
                waterconnection!.meterId == null
                    ? Text("")
                    : _getLabelText(
                        i18.searchWaterConnection.METER_NUMBER,
                        waterconnection!.meterId,
                        context,
                      ),
                _getLabelText(
                  i18.common.STATUS,
                  waterconnection!.status == "Active"
                      ? ApplicationLocalizations.of(context).translate(i18.searchWaterConnection.STATUS_ACTIVE)
                      : ApplicationLocalizations.of(context).translate(i18.searchWaterConnection.STATUS_INACTIVE),
                  context,
                ),
                Consumer<HouseHoldProvider>(
                    builder: (_, provider, child) =>
                        Wrap(
                          children: [
                            Visibility(
                              visible: provider.isVisible,
                              child: Wrap(
                                children: [
                                  _getLabelText(
                                      i18.consumer.CONSUMER_CATEGORY, waterconnection?.additionalDetails?.category ?? i18.common.NA,
                                      context,
                                      ),
                                  _getLabelText(
                                      i18.consumer.CONSUMER_SUBCATEGORY,  waterconnection?.additionalDetails?.subCategory ?? i18.common.NA,
                                      context,
                                      )
                                ],
                              ),
                            ),
                            InkWell(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                       bottom: 10, right: 25),
                                  child: new Row(
                                    children: [
                                      new Text(
                                        '\n${ApplicationLocalizations.of(context).translate(!provider.isVisible ? i18.common.SHOW_MORE : i18.common.SHOW_LESS)}',
                                        style: new TextStyle(
                                            color: Colors.deepOrangeAccent),
                                      )
                                    ],
                                  ),
                                ),
                                onTap: provider.onTapOfShow
                            )
                          ],
                        )
                )
              ],
            )));
  }
}
