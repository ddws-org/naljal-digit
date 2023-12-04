import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/model/connection/search_connection.dart';
import 'package:mgramseva/providers/search_connection_provider.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/widgets/custom_app_bar.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/widgets/bottom_button_bar.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/form_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/label_text.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:mgramseva/widgets/sub_label.dart';
import 'package:mgramseva/widgets/text_field_builder.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:provider/provider.dart';

class SearchConsumerConnection extends StatefulWidget {
  final Map? arguments;
  SearchConsumerConnection(this.arguments);
  State<StatefulWidget> createState() {
    return _SearchConsumerConnectionState();
  }
}

class _SearchConsumerConnectionState extends State<SearchConsumerConnection> {
  var isVisible = true;

  @override
  void initState() {
    Provider.of<SearchConnectionProvider>(context, listen: false)
      ..searchconnection = SearchConnection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var searchConnectionProvider =
        Provider.of<SearchConnectionProvider>(context, listen: false);
    return FocusWatcher(
        child: Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
          appBar: CustomAppBar(),
          drawer: DrawerWrapper(
            Drawer(child: SideBar()),
          ),
          body: SingleChildScrollView(
            child: Column(children: [
              FormWrapper(Consumer<SearchConnectionProvider>(
                builder: (_, searchConnectionProvider, child) => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeBack(),
                  Card(
                    child: Form(
                        key: searchConnectionProvider.formKey,
                        autovalidateMode:
                            searchConnectionProvider.autoValidation
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              LabelText(i18.searchWaterConnection
                                  .SEARCH_CONNECTION_LABEL),
                              SubLabelText(i18.searchWaterConnection
                                  .SEARCH_CONNECTION_SUBLABEL),
                              BuildTextField(
                                i18.searchWaterConnection.OWNER_MOB_NUM,
                                searchConnectionProvider
                                    .searchconnection.mobileCtrl,
                                prefixText: '+91 - ',
                                textInputType: TextInputType.number,
                                maxLength: 10,
                                pattern: (searchConnectionProvider
                                                .searchconnection
                                                .controllers[0] ==
                                            null ||
                                        searchConnectionProvider
                                                .searchconnection
                                                .controllers[0] ==
                                            false)
                                    ? (r'^(?:[+0]9)?[0-9]{10}$')
                                    : '',
                                message: i18.validators
                                    .MOBILE_NUMBER_SHOULD_BE_10_DIGIT,
                                inputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]"))
                                ],
                                isDisabled: searchConnectionProvider
                                    .searchconnection.controllers[0],
                                onChange: (value) => searchConnectionProvider
                                    .getdetails(value, 0),
                                key: Keys.searchConnection.SEARCH_PHONE_NUMBER_KEY,
                                  onSubmit: (value){
                                    searchConnectionProvider.validatesearchConnectionDetails(
                                        context, widget.arguments, (searchConnectionProvider.searchconnection.controllers[1] == false)
                                        ? true : false);
                                  }
                              ),
                              Text(
                                '\n${ApplicationLocalizations.of(context).translate(i18.common.OR)}',
                                textAlign: TextAlign.center,
                              ),
                              BuildTextField(
                                i18.searchWaterConnection.CONSUMER_NAME,
                                searchConnectionProvider
                                    .searchconnection.nameCtrl,
                                isDisabled: searchConnectionProvider
                                    .searchconnection.controllers[1],
                                inputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[A-Za-z ]"))
                                ],
                                onChange: (value) => searchConnectionProvider
                                    .getdetails(value, 1),
                                onSubmit: (value){
                                      searchConnectionProvider.validatesearchConnectionDetails(
                                      context, widget.arguments, (searchConnectionProvider.searchconnection.controllers[1] == false)
                                      ? true : false);
                                },
                                hint: ApplicationLocalizations.of(context)
                                    .translate(
                                        i18.searchWaterConnection.NAME_HINT),
                                key: Keys.searchConnection.SEARCH_NAME_KEY,
                              ),
                              Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.start,
                                  children: [
                                    Text(
                                        '\n${ApplicationLocalizations.of(context).translate(i18.common.OR)}',
                                        textAlign: TextAlign.center),
                                    BuildTextField(
                                      i18.searchWaterConnection
                                          .OLD_CONNECTION_ID,
                                      searchConnectionProvider
                                          .searchconnection
                                          .oldConnectionCtrl,
                                      isDisabled: searchConnectionProvider
                                          .searchconnection.controllers[2],
                                      onChange: (value) =>
                                          searchConnectionProvider
                                              .getdetails(value, 2),
                                      hint: ApplicationLocalizations.of(
                                              context)
                                          .translate(i18
                                              .searchWaterConnection
                                              .OLD_CONNECTION_HINT),
                                      key: Keys.searchConnection.SEARCH_OLD_ID_KEY,
                                        onSubmit: (value){
                                          searchConnectionProvider.validatesearchConnectionDetails(
                                              context, widget.arguments, (searchConnectionProvider.searchconnection.controllers[1] == false)
                                              ? true : false);
                                        }
                                    ),
                                    Text(
                                        '\n${ApplicationLocalizations.of(context).translate(i18.common.OR)}',
                                        textAlign: TextAlign.center),
                                    BuildTextField(
                                      i18.searchWaterConnection
                                          .NEW_CONNECTION_ID,
                                      searchConnectionProvider
                                          .searchconnection
                                          .newConnectionCtrl,
                                      isDisabled: searchConnectionProvider
                                          .searchconnection.controllers[3],
                                      onChange: (value) =>
                                          searchConnectionProvider
                                              .getdetails(value, 3),
                                      hint: ApplicationLocalizations.of(
                                              context)
                                          .translate(i18
                                              .searchWaterConnection
                                              .NEW_CONNECTION_HINT),
                                      key: Keys.searchConnection.SEARCH_NEW_ID_KEY,
                                        onSubmit: (value){
                                          searchConnectionProvider.validatesearchConnectionDetails(
                                              context, widget.arguments, (searchConnectionProvider.searchconnection.controllers[1] == false)
                                              ? true : false);
                                        }
                                    ),
                                  ]),
                            ]))),
              ]),
        )),
        Footer()
      ])),
      bottomNavigationBar: BottomButtonBar(
          i18.searchWaterConnection.SEARCH_CONNECTION_BUTTON,
          () => searchConnectionProvider.validatesearchConnectionDetails(
              context, widget.arguments, (searchConnectionProvider.searchconnection.controllers[1] == false)
              ? true : false),
      key: Keys.searchConnection.SEARCH_BTN_KEY,),
    ));
  }
}
