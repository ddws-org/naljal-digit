import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mgramseva/model/mdms/department.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/ifix_hierarchy_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:provider/provider.dart';

import '../../utils/localization/application_localizations.dart';
import '../../utils/common_widgets.dart';
import '../../utils/loaders.dart';
import '../../widgets/label_text.dart';
import 'gpwsc_card.dart';

class GPWSCBoundaryDetailCard extends StatelessWidget {
  const GPWSCBoundaryDetailCard({Key? key}) : super(key: key);
  _getLabeltext(label, value, context) {
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
    var ifixProvider =
        Provider.of<IfixHierarchyProvider>(context, listen: false);
    Department? department;
    return LayoutBuilder(builder: (context, constraints) {
      return Consumer<IfixHierarchyProvider>(
          key: key,
          builder: (_, departmentProvider, child) {
            return Consumer<CommonProvider>(
              builder: (_, commonProvider, child) {
                return StreamBuilder(
                    stream: ifixProvider.streamController.stream,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data is String) {
                          return CommonWidgets.buildEmptyMessage(
                              snapshot.data, context);
                        }

                        department = snapshot.data;
                        return GPWSCCard(
                          children: [
                            LabelText(i18.dashboard.GPWSC_DETAILS),
                            Padding(
                              padding: constraints.maxWidth > 760
                                  ? const EdgeInsets.all(20.0)
                                  : const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  _getLabeltext(
                                      "${ApplicationLocalizations.of(context).translate(i18.common.VILLAGE_CODE)}",
                                      commonProvider
                                          .userDetails!.selectedtenant?.city?.code,
                                      context),
                                  _getLabeltext(
                                      "${ApplicationLocalizations.of(context).translate(i18.common.VILLAGE_NAME)}",
                                      commonProvider
                                          .userDetails!.selectedtenant?.code,
                                      context),
                                  _getLabeltext(
                                      "${ApplicationLocalizations.of(context).translate(i18.common.SECTION_CODE)}",
                                      departmentProvider.hierarchy
                                              .containsKey("5")
                                          ? '${departmentProvider.hierarchy["5"]!["code"]}-${departmentProvider.hierarchy["5"]!["name"]}'
                                          : 'NA',
                                      context),
                                  _getLabeltext(
                                      "${ApplicationLocalizations.of(context).translate(i18.common.SUB_DIVISION_CODE)}",
                                      departmentProvider.hierarchy
                                              .containsKey("4")
                                          ? '${departmentProvider.hierarchy["4"]!['code']}-${departmentProvider.hierarchy["5"]!["name"]}'
                                          : 'NA',
                                      context),
                                  _getLabeltext(
                                      "${ApplicationLocalizations.of(context).translate(i18.common.DIVISION_CODE)}",
                                      departmentProvider.hierarchy
                                              .containsKey("3")
                                          ? '${departmentProvider.hierarchy["3"]!['code']}-${departmentProvider.hierarchy["3"]!["name"]}'
                                          : 'NA',
                                      context),
                                  _getLabeltext(
                                      "${ApplicationLocalizations.of(context).translate(i18.common.PROJECT_SCHEME_CODE)}",
                                      department?.project?.code ?? 'NA',
                                      context),
                                  _getLabeltext(
                                      "${ApplicationLocalizations.of(context).translate(i18.common.REGION_NAME)}",
                                      commonProvider.userDetails!.selectedtenant
                                                      ?.city?.regionName !=
                                                  null &&
                                              (commonProvider
                                                          .userDetails!
                                                          .selectedtenant
                                                          ?.city
                                                          ?.regionName ??
                                                      '')
                                                  .isNotEmpty
                                          ? '${commonProvider.userDetails!.selectedtenant?.city?.regionName}'
                                          : 'NA',
                                      context),
                                  _getLabeltext(
                                      "${ApplicationLocalizations.of(context).translate(i18.common.DISTRICT_CODE)}",
                                      commonProvider.userDetails!.selectedtenant
                                                      ?.city?.districtCode ==
                                                  null &&
                                              commonProvider
                                                      .userDetails!
                                                      .selectedtenant
                                                      ?.city
                                                      ?.districtName ==
                                                  null
                                          ? 'NA'
                                          : '${commonProvider.userDetails!.selectedtenant?.city?.districtCode ?? 'NA'}-${commonProvider.userDetails!.selectedtenant?.city?.districtName ?? 'NA'}',
                                      context),
                                  _getLabeltext(
                                      "${ApplicationLocalizations.of(context).translate(i18.common.TENANT_ID)}",
                                      commonProvider
                                          .userDetails!.selectedtenant?.code
                                          ?.split('.')
                                          .last,
                                      context),
                                ],
                              ),
                            )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Column(
                          children: [
                            LabelText('${snapshot.error}'),
                          ],
                        );
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
              },
            );
          });
    });
  }
}
