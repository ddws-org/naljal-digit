import 'package:flutter/material.dart';
import 'package:mgramseva/providers/reports_provider.dart';
import 'package:mgramseva/screeens/generate_bill/widgets/water_connection_count_widget.dart';
import 'package:mgramseva/widgets/keyboard_focus_watcher.dart';
import 'package:mgramseva/model/bill/bill_generation_details/bill_generation_details.dart';
import 'package:mgramseva/model/connection/water_connection.dart';
import 'package:mgramseva/providers/bill_generation_details_provider.dart';
import 'package:mgramseva/screeens/generate_bill/widgets/meter_reading.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/utils/validators/validators.dart';
import 'package:mgramseva/widgets/bases_app_bar.dart';
import 'package:mgramseva/widgets/bottom_button_bar.dart';
import 'package:mgramseva/widgets/date_picker_field_builder.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/form_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/label_text.dart';
import 'package:mgramseva/widgets/select_field_builder.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:mgramseva/widgets/text_field_builder.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:provider/provider.dart';

import '../../providers/ifix_hierarchy_provider.dart';
import '../../utils/localization/application_localizations.dart';

class GenerateBill extends StatefulWidget {
  final String? id;
  final WaterConnection? waterconnection;
  const GenerateBill({Key? key, this.id, this.waterconnection})
      : super(key: key);
  State<StatefulWidget> createState() {
    return _GenerateBillState();
  }
}

class _GenerateBillState extends State<GenerateBill> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }
  @override
  void dispose() {
    Provider.of<BillGenerationProvider>(context, listen: false).clearBillYear();
    super.dispose();
  }

  afterViewBuild() {
    Provider.of<BillGenerationProvider>(context, listen: false)
      ..setModel(widget.id, widget.waterconnection, context)
      ..readingExist
      ..getServiceTypePropertyTypeandConnectionType()
      ..autoValidation = false
      ..clearBillYear()
      ..formKey = GlobalKey<FormState>();

    Provider.of<IfixHierarchyProvider>(context,listen: false)
      ..getBillingSlabs();
  }

  var metVal = "";

  saveInput(context) async {
    setState(() {
      metVal = context;
    });
  }

  Widget buildview(BillGenerationDetails billGenerationDetails) {
    return Container(
        child: FormWrapper(Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          HomeBack(callback: (){
            Provider.of<BillGenerationProvider>(context, listen: false).clearBillYear();
            // Navigator.pop(context);
            Navigator.of(context,rootNavigator: true).pop();
          },),
              widget.id == null ?WaterConnectionCountWidget():Container(),
          Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                  child: Padding(
                      padding: EdgeInsets.only(bottom: 20),
                      child: Consumer<BillGenerationProvider>(
                          builder: (_, billgenerationprovider, child) => Form(
                              key: billgenerationprovider.formKey,
                              autovalidateMode:
                                  billgenerationprovider.autoValidation
                                      ? AutovalidateMode.always
                                      : AutovalidateMode.disabled,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    LabelText(
                                        '${widget.id == null ? i18.demandGenerate.SERVICE_DETAILS_HEADER : i18.demandGenerate.GENERATE_BILL_HEADER}'),
                                    Consumer<BillGenerationProvider>(
                                        builder: (_, billgenerationprovider,
                                                child) =>
                                            SelectFieldBuilder(
                                              i18.demandGenerate
                                                  .SERVICE_CATEGORY_LABEL,
                                              billgenerationprovider
                                                  .billGenerateDetails
                                                  .serviceCat,
                                              '',
                                              '',
                                              billgenerationprovider
                                                  .onChangeOfServiceCat,
                                              billgenerationprovider
                                                  .getServiceCategoryList(),
                                              true,
                                              itemAsString: (i) =>"${ApplicationLocalizations.of(context).translate(i.toString())}",
                                              readOnly: true,
                                              controller: billgenerationprovider
                                                  .billGenerateDetails
                                                  .serviceCategoryCtrl,
                                            )),
                                    Consumer<BillGenerationProvider>(
                                        builder: (_,
                                                billgenerationprovider, child) =>
                                            SelectFieldBuilder(
                                                i18.demandGenerate
                                                    .SERVICE_TYPE_LABEL,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .serviceType,
                                                '',
                                                '',
                                                billgenerationprovider
                                                    .onChangeOfServiceType,
                                                billgenerationprovider
                                                    .getConnectionTypeList(),
                                                true,
                                                itemAsString: (i) =>"${ApplicationLocalizations.of(context).translate(i.toString())}",
                                                readOnly: true,
                                                controller:
                                                    billgenerationprovider
                                                        .billGenerateDetails
                                                        .serviceTypeCtrl)),
                                    billgenerationprovider.billGenerateDetails
                                                .serviceType !=
                                            "Metered"
                                        ? Container()
                                        : Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(children: [
                                              Consumer<BillGenerationProvider>(
                                                  builder: (_,
                                                          billgenerationprovider,
                                                          child) =>
                                                      SelectFieldBuilder(
                                                          i18.demandGenerate
                                                              .PROPERTY_TYPE_LABEL,
                                                          billgenerationprovider
                                                              .billGenerateDetails
                                                              .propertyType,
                                                          '',
                                                          '',
                                                          billgenerationprovider
                                                              .onChangeOfProperty,
                                                          billgenerationprovider
                                                              .getPropertyTypeList(),
                                                          true,
                                                          itemAsString: (i) =>"${ApplicationLocalizations.of(context).translate(i.toString())}",
                                                          readOnly: true,
                                                          controller: billgenerationprovider
                                                              .billGenerateDetails
                                                              .propertyTypeCtrl)),
                                              Consumer<BillGenerationProvider>(
                                                  builder: (_,
                                                          billgenerationprovider,
                                                          child) =>
                                                      BuildTextField(
                                                        i18.demandGenerate
                                                            .METER_NUMBER_LABEL,
                                                        billgenerationprovider
                                                            .billGenerateDetails
                                                            .meterNumberCtrl,
                                                        isRequired: true,
                                                        validator: Validators
                                                            .meterNumberValidator,
                                                        textInputType:
                                                            TextInputType
                                                                .number,
                                                        onChange: (value) =>
                                                            saveInput(value),
                                                        isDisabled: true,
                                                        readOnly:
                                                            widget.id == null
                                                                ? false
                                                                : true,
                                                      )),
                                              MeterReading(
                                                i18.demandGenerate
                                                    .PREV_METER_READING_LABEL,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .om_1Ctrl,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .om_2Ctrl,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .om_3Ctrl,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .om_4Ctrl,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .om_5Ctrl,
                                                isRequired: true,
                                                isDisabled: billgenerationprovider.readingExist == false ? true : false,
                                              ),
                                              MeterReading(
                                                i18.demandGenerate
                                                    .NEW_METER_READING_LABEL,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .nm_1Ctrl,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .nm_2Ctrl,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .nm_3Ctrl,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .nm_4Ctrl,
                                                billgenerationprovider
                                                    .billGenerateDetails
                                                    .nm_5Ctrl,
                                                isRequired: true,
                                                isDisabled: false,
                                              ),
                                              BasicDateField(
                                                  i18.demandGenerate
                                                      .METER_READING_DATE,
                                                  true,
                                                  billGenerationDetails
                                                      .meterReadingDateCtrl,
                                                  lastDate: DateTime.now(),
                                                  onChangeOfDate:
                                                      billgenerationprovider
                                                          .onChangeOfDate),
                                            ])),
                                    billgenerationprovider.billGenerateDetails
                                                .serviceType !=
                                            "Non_Metered"
                                        ? Container()
                                        : Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Consumer<
                                                          BillGenerationProvider>(
                                                      builder: (_,
                                                              billgenerationprovider,
                                                              child) =>
                                                          SelectFieldBuilder(
                                                            i18.demandGenerate
                                                                .BILLING_YEAR_LABEL,
                                                            billgenerationprovider
                                                                .billGenerateDetails
                                                                .billYear,
                                                            '',
                                                            '',
                                                            billgenerationprovider
                                                                .onChangeOfBillYear,
                                                            billgenerationprovider
                                                                .getFinancialYearList(),
                                                            true,
                                                            itemAsString: (i) =>"${ApplicationLocalizations.of(context).translate(i.financialYear)}",
                                                            controller: billgenerationprovider
                                                                .billGenerateDetails
                                                                .billingyearCtrl,
                                                            key: Keys.bulkDemand.BULK_DEMAND_BILLING_YEAR,
                                                          )),
                                                  Consumer<
                                                          BillGenerationProvider>(
                                                      builder: (_,
                                                              billgenerationprovider,
                                                              child) =>
                                                          SelectFieldBuilder(
                                                            i18.demandGenerate
                                                                .BILLING_CYCLE_LABEL,
                                                            billgenerationprovider
                                                                .selectedBillCycle,
                                                            '',
                                                            '',
                                                            billgenerationprovider
                                                                .onChangeOfBillCycle,
                                                            billgenerationprovider
                                                                .getBillingCycle(),
                                                            true,
                                                            itemAsString: (i) =>"${ApplicationLocalizations.of(context).translate(i['name'])}",
                                                            controller: billgenerationprovider
                                                                .billGenerateDetails
                                                                .billingcycleCtrl,
                                                            key: Keys.bulkDemand.BULK_DEMAND_BILLING_CYCLE,
                                                          )),
                                                ])),
                                  ]))))))
        ])));
  }

  @override
  Widget build(BuildContext context) {
    var billGenerateProvider =
        Provider.of<BillGenerationProvider>(context, listen: false);
    return KeyboardFocusWatcher(
        child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: BaseAppBar(
          Text(i18.common.MGRAM_SEVA),
          AppBar(),
          <Widget>[Icon(Icons.more_vert)],
        ),
        drawer: DrawerWrapper(
          Drawer(child: SideBar()),
        ),
        body: SingleChildScrollView(
            child: Container(
                child: Column(children: [
          StreamBuilder(
              stream: billGenerateProvider.streamController.stream,
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return buildview(snapshot.data);
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
              }),
          Footer()
        ]))),
        bottomNavigationBar: BottomButtonBar(
            '${widget.id == null ? i18.demandGenerate.GENERATE_DEMAND_BUTTON : i18.demandGenerate.GENERATE_BILL_BUTTON}',
            () => {billGenerateProvider.onSubmit(context)},
        key: Keys.bulkDemand.GENERATE_BILL_BTN,)));
  }
}
