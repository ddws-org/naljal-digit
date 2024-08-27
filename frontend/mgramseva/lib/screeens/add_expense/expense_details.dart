import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mgramseva/widgets/keyboard_focus_watcher.dart';
import 'package:mgramseva/model/expenses_details/expenses_details.dart';
import 'package:mgramseva/providers/expenses_details_provider.dart';
import 'package:mgramseva/screeens/add_expense/add_expense_walk_through/expense_walk_through.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/widgets/custom_app_bar.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_methods.dart';
import 'package:mgramseva/utils/common_widgets.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/utils/validators/validators.dart';
import 'package:mgramseva/widgets/bottom_button_bar.dart';
import 'package:mgramseva/widgets/date_picker_field_builder.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/file_picker.dart';
import 'package:mgramseva/widgets/form_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/label_text.dart';
import 'package:mgramseva/widgets/radio_button_field_builder.dart';
import 'package:mgramseva/widgets/select_field_builder.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:mgramseva/widgets/sub_label.dart';
import 'package:mgramseva/widgets/text_field_builder.dart';
import 'package:mgramseva/widgets/auto_complete_view.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:mgramseva/widgets/help.dart';
import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';

import 'add_expense_walk_through/walk_through_container.dart';

class ExpenseDetails extends StatefulWidget {
  final String? id;
  final ExpensesDetailsModel? expensesDetails;

  const ExpenseDetails({Key? key, this.id, this.expensesDetails})
      : super(key: key);
  State<StatefulWidget> createState() {
    return _ExpenseDetailsState();
  }
}

class _ExpenseDetailsState extends State<ExpenseDetails> {
  FocusNode _numberFocus = new FocusNode();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    _numberFocus.addListener(_onFocusChange);
    super.initState();
  }

  afterViewBuild() {
    Provider.of<ExpensesDetailsProvider>(context, listen: false)
      ..phoneNumberAutoValidation = false
      ..dateAutoValidation = false
      ..formKey = GlobalKey<FormState>()
      ..filePickerKey = GlobalKey<FilePickerDemoState>()
      ..suggestionsBoxController = SuggestionsBoxController()
      ..expenditureDetails = ExpensesDetailsModel()
      ..autoValidation = false
      ..getExpensesDetails(context, widget.expensesDetails, widget.id)
      ..getExpenses()
      ..setwalkthrough(ExpenseWalkThrough().expenseWalkThrough.map((e) {
        e.key = GlobalKey();
        return e;
      }).toList());
  }

  dispose() {
    _numberFocus.addListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    if (!_numberFocus.hasFocus) {
      Provider.of<ExpensesDetailsProvider>(context, listen: false)
        ..phoneNumberAutoValidation = true
        ..callNotifyer();
    }
  }

  @override
  Widget build(BuildContext context) {
    var expensesDetailsProvider =
        Provider.of<ExpensesDetailsProvider>(context, listen: false);
    return KeyboardFocusWatcher(
        child: Scaffold(
            appBar: CustomAppBar(),
            drawer: DrawerWrapper(
              Drawer(child: SideBar()),
            ),
            body: SingleChildScrollView(
                child: Column(children: [
              StreamBuilder(
                  stream: expensesDetailsProvider.streamController.stream,
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data is String) {
                        return CommonWidgets.buildEmptyMessage(
                            snapshot.data, context);
                      }
                      return _buildUserView();
                    } else if (snapshot.hasError) {
                      return Notifiers.networkErrorPage(
                          context,
                          () => expensesDetailsProvider.getExpensesDetails(
                              context, widget.expensesDetails, widget.id));
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
            ])),
            bottomNavigationBar: Consumer<ExpensesDetailsProvider>(
              builder: (_, expensesDetailsProvider, child) => BottomButtonBar(
                i18.common.SUBMIT,
                (isUpdate &&
                            (expensesDetailsProvider
                                    .expenditureDetails.allowEdit ??
                                false)) ||
                        ((isUpdate &&
                                !(expensesDetailsProvider
                                        .expenditureDetails.allowEdit ??
                                    false) &&
                                (expensesDetailsProvider
                                        .expenditureDetails.isBillCancelled ??
                                    false)) ||
                            !isUpdate)
                    ? expensesDetailsProvider.isPSPCLEnabled &&
                            expensesDetailsProvider
                                    .expenditureDetails.expenseType ==
                                'ELECTRICITY_BILL'
                        ? null
                        : () => expensesDetailsProvider.validateExpensesDetails(
                            context, isUpdate)
                    : null,
                key: Keys.expense.EXPENSE_SUBMIT,
              ),
            )));
  }

  saveInput(context) async {
    print(context);
  }

  Widget _buildUserView() {
    return FormWrapper(Consumer<ExpensesDetailsProvider>(
        builder: (_, expenseProvider, child) => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // ExpenseWalkThroughContainer Is Removed
                  // HomeBack(
                  //     widget: Help(
                  //   callBack: () => showGeneralDialog(
                  //     barrierLabel: "Label",
                  //     barrierDismissible: false,
                  //     barrierColor: Colors.black.withOpacity(0.5),
                  //     transitionDuration: Duration(milliseconds: 700),
                  //     context: context,
                  //     pageBuilder: (context, anim1, anim2) {
                  //       return ExpenseWalkThroughContainer((index) =>
                  //           expenseProvider.incrementindex(
                  //               index,
                  //               expenseProvider
                  //                   .expenseWalkthrougList[index + 1].key));
                  //     },
                  //     transitionBuilder: (context, anim1, anim2, child) {
                  //       return SlideTransition(
                  //         position:
                  //             Tween(begin: Offset(0, 1), end: Offset(0, 0))
                  //                 .animate(anim1),
                  //         child: child,
                  //       );
                  //     },
                  //   ),
                  //   walkThroughKey: Constants.ADD_EXPENSE_KEY,
                  // )),
                  HomeBack(),
                  Card(
                      child: Consumer<ExpensesDetailsProvider>(
                    builder: (_, expensesDetailsProvider, child) => Form(
                      key: expensesDetailsProvider.formKey,
                      autovalidateMode: expensesDetailsProvider.autoValidation
                          ? AutovalidateMode.always
                          : AutovalidateMode.disabled,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            LabelText(isUpdate
                                ? i18.expense.EDIT_EXPENSE_BILL
                                : i18.expense.EXPENSE_DETAILS),
                            SubLabelText(isUpdate
                                ? i18.expense.UPDATE_SUBMIT_EXPENDITURE
                                : i18.expense.PROVIDE_INFO_TO_CREATE_EXPENSE),
                            if (isUpdate)
                              BuildTextField(
                                '${i18.common.BILL_ID}',
                                expensesDetailsProvider
                                    .expenditureDetails.challanNumberCtrl,
                                isDisabled: true,
                              ),
                            SelectFieldBuilder(
                              i18.expense.EXPENSE_TYPE,
                              expensesDetailsProvider
                                  .expenditureDetails.expenseType,
                              '',
                              '',
                              expensesDetailsProvider.onChangeOfExpenses,
                              expensesDetailsProvider.getExpenseTypeList(
                                  isSearch: isUpdate),
                              true,
                              readOnly: !expensesDetailsProvider
                                  .expenditureDetails.allowEdit!,
                              requiredMessage:
                                  i18.expense.SELECT_EXPENDITURE_CATEGORY,
                              contextKey:
                                  expenseProvider.expenseWalkthrougList[0].key,
                              controller: expensesDetailsProvider
                                  .expenditureDetails.expenseTypeController,
                              key: Keys.expense.EXPENSE_TYPE,
                              itemAsString: (i) =>
                                  '${ApplicationLocalizations.of(context).translate(i.toString())}',
                            ),
                            AutoCompleteView(
                              labelText: i18.expense.VENDOR_NAME,
                              controller: expensesDetailsProvider
                                  .expenditureDetails.vendorNameCtrl,
                              suggestionsBoxController: expensesDetailsProvider
                                  .suggestionsBoxController,
                              onSuggestionSelected:
                                  expensesDetailsProvider.onSuggestionSelected,
                              callBack:
                                  expensesDetailsProvider.onSearchVendorList,
                              listTile: buildTile,
                              isRequired: true,
                              isEnabled: expensesDetailsProvider
                                  .expenditureDetails.allowEdit,
                              requiredMessage:
                                  i18.expense.MENTION_NAME_OF_VENDOR,
                              inputFormatter: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-zA-Z ]"))
                              ],
                              contextKey:
                                  expenseProvider.expenseWalkthrougList[1].key,
                              key: Keys.expense.VENDOR_NAME,
                            ),
                            if (expensesDetailsProvider
                                .expenditureDetails.vendorNameCtrl.text
                                .trim()
                                .isNotEmpty)
                              BuildTextField(
                                '${i18.common.MOBILE_NUMBER}',
                                expensesDetailsProvider
                                    .expenditureDetails.mobileNumberController,
                                isRequired: true,
                                prefixText: '+91 - ',
                                textInputType: TextInputType.number,
                                validator: Validators.mobileNumberValidator,
                                focusNode: _numberFocus,
                                autoValidation: expensesDetailsProvider
                                        .phoneNumberAutoValidation
                                    ? AutovalidateMode.always
                                    : AutovalidateMode.disabled,
                                maxLength: 10,
                                isDisabled:
                                    !expensesDetailsProvider.isNewVendor(),
                                inputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]"))
                                ],
                                onChange: expensesDetailsProvider
                                    .onChangeOfMobileNumber,
                                key: Keys.expense.VENDOR_MOBILE_NUMBER,
                              ),
                            BuildTextField(
                              '${i18.expense.AMOUNT}',
                              expensesDetailsProvider.expenditureDetails
                                  .expensesAmount!.first.amountCtrl,
                              isRequired: true,
                              textInputType: TextInputType.number,
                              inputFormatter: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"^[1-9][0-9]{0,5}$"))
                              ],
                              placeHolder: '${i18.expense.AMOUNT} (₹)',
                              labelSuffix: '(₹)',
                              isDisabled: (expensesDetailsProvider
                                          .expenditureDetails.allowEdit ??
                                      true)
                                  ? false
                                  : true,
                              requiredMessage:
                                  i18.expense.AMOUNT_MENTIONED_IN_THE_BILL,
                              validator: Validators.amountValidator,
                              contextKey:
                                  expenseProvider.expenseWalkthrougList[2].key,
                              key: Keys.expense.EXPENSE_AMOUNT,
                            ),
                            LayoutBuilder(builder: (context, constraints) {
                              var margin = constraints.maxWidth > 760
                                  ? EdgeInsets.only(
                                      top: 20.0, bottom: 5, right: 10, left: 10)
                                  : null;
                              return Container(
                                padding: constraints.maxWidth > 760
                                    ? EdgeInsets.only(bottom: 12)
                                    : EdgeInsets.all(8),
                                margin: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(238, 238, 238, 0.4),
                                    border: Border.all(
                                        color: Colors.grey, width: 0.6),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    )),
                                child: Wrap(
                                  children: [
                                    BasicDateField(
                                      i18.expense.BILL_DATE,
                                      true,
                                      expensesDetailsProvider
                                          .expenditureDetails.billDateCtrl,
                                      firstDate: expensesDetailsProvider
                                              .expenditureDetails
                                              .billIssuedDateCtrl
                                              .text
                                              .trim()
                                              .isEmpty
                                          ? null
                                          : DateFormats
                                              .getFormattedDateToDateTime(
                                              expensesDetailsProvider
                                                  .expenditureDetails
                                                  .billIssuedDateCtrl
                                                  .text
                                                  .trim(),
                                            ),
                                      initialDate: DateFormats
                                          .getFormattedDateToDateTime(
                                        expensesDetailsProvider
                                            .expenditureDetails
                                            .billDateCtrl
                                            .text
                                            .trim(),
                                      ),
                                      lastDate: DateTime.now(),
                                      onChangeOfDate: expensesDetailsProvider
                                          .onChangeOfBillDate,
                                      isEnabled: expensesDetailsProvider
                                          .expenditureDetails.allowEdit,
                                      requiredMessage: i18
                                          .expense.DATE_BILL_ENTERED_IN_RECORDS,
                                      contextKey: expenseProvider
                                          .expenseWalkthrougList[3].key,
                                      key: Keys.expense.EXPENSE_BILL_DATE,
                                      margin: margin,
                                    ),
                                    BasicDateField(
                                      i18.expense.EXPENSE_START_DATE,
                                      true,
                                      expensesDetailsProvider
                                          .expenditureDetails.fromDateCtrl,
                                      onChangeOfDate: expensesDetailsProvider
                                          .onChangeOfStartEndDate,
                                      lastDate: DateFormats
                                              .getFormattedDateToDateTime(
                                            expensesDetailsProvider
                                                .expenditureDetails
                                                .billDateCtrl
                                                .text
                                                .trim(),
                                          ) ??
                                          DateTime.now(),
                                      isEnabled: expensesDetailsProvider
                                          .expenditureDetails.allowEdit,
                                      validator: (val) =>
                                          expensesDetailsProvider
                                              .fromToDateValidator(val, true),
                                      autoValidation:
                                          expenseProvider.dateAutoValidation
                                              ? AutovalidateMode.always
                                              : AutovalidateMode.disabled,
                                      margin: margin,
                                    ),
                                    BasicDateField(
                                      i18.expense.EXPENSE_END_DATE,
                                      true,
                                      expensesDetailsProvider
                                          .expenditureDetails.toDateCtrl,
                                      initialDate: DateFormats
                                          .getFormattedDateToDateTime(
                                        expensesDetailsProvider
                                            .expenditureDetails
                                            .billDateCtrl
                                            .text
                                            .trim(),
                                      ),
                                      lastDate: DateFormats
                                              .getFormattedDateToDateTime(
                                            expensesDetailsProvider
                                                .expenditureDetails
                                                .billDateCtrl
                                                .text
                                                .trim(),
                                          ) ??
                                          DateTime.now(),
                                      onChangeOfDate: expensesDetailsProvider
                                          .onChangeOfStartEndDate,
                                      isEnabled: expensesDetailsProvider
                                          .expenditureDetails.allowEdit,
                                      validator: expensesDetailsProvider
                                          .fromToDateValidator,
                                      autoValidation:
                                          expenseProvider.dateAutoValidation
                                              ? AutovalidateMode.always
                                              : AutovalidateMode.disabled,
                                      margin: margin,
                                    )
                                  ],
                                ),
                              );
                            }),
                            BasicDateField(
                              i18.expense.PARTY_BILL_DATE,
                              false,
                              expensesDetailsProvider
                                  .expenditureDetails.billIssuedDateCtrl,
                              initialDate:
                                  DateFormats.getFormattedDateToDateTime(
                                expensesDetailsProvider
                                    .expenditureDetails.billIssuedDateCtrl.text
                                    .trim(),
                              ),
                              lastDate: expensesDetailsProvider
                                      .expenditureDetails.billDateCtrl.text
                                      .trim()
                                      .isEmpty
                                  ? DateTime.now()
                                  : DateFormats.getFormattedDateToDateTime(
                                      expensesDetailsProvider
                                          .expenditureDetails.billDateCtrl.text
                                          .trim()),
                              onChangeOfDate:
                                  expensesDetailsProvider.onChangeOfDate,
                              isEnabled: expensesDetailsProvider
                                  .expenditureDetails.allowEdit,
                              contextKey:
                                  expenseProvider.expenseWalkthrougList[4].key,
                              key: Keys.expense.EXPENSE_PARTY_DATE,
                            ),
                            AbsorbPointer(
                              absorbing: expensesDetailsProvider
                                                    .expenditureDetails
                                                    .isBillCancelled == true ? true : false,
                              child: RadioButtonFieldBuilder(                              
                                  context,
                                  i18.expense.HAS_THIS_BILL_PAID,
                                  expensesDetailsProvider
                                      .expenditureDetails.isBillPaid,
                                  '',
                                  '',
                                  true,
                                  Constants.EXPENSESTYPE,
                                  expensesDetailsProvider.onChangeOfBillPaid,
                                  isEnabled: expensesDetailsProvider
                                      .expenditureDetails.allowEdit),
                            ),
                            if (expensesDetailsProvider.expenditureDetails.isBillPaid ?? false)
                              BasicDateField(i18.expense.PAYMENT_DATE, true,
                                  expensesDetailsProvider.expenditureDetails.paidDateCtrl,
                                  firstDate: DateFormats.getFormattedDateToDateTime(
                                      expensesDetailsProvider
                                          .expenditureDetails.billDateCtrl.text
                                          .trim()),
                                  lastDate: DateTime.now(),
                                  initialDate: DateFormats.getFormattedDateToDateTime(
                                      expensesDetailsProvider
                                          .expenditureDetails.paidDateCtrl.text
                                          .trim()),
                                  onChangeOfDate:
                                      expensesDetailsProvider.onChangeOfDate,
                                  isEnabled: expensesDetailsProvider
                                      .expenditureDetails.allowEdit),
                            if (isUpdate &&
                                expensesDetailsProvider
                                        .expenditureDetails.fileStoreList !=
                                    null &&
                                expensesDetailsProvider.expenditureDetails
                                    .fileStoreList!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 20.0, bottom: 5, right: 20, left: 20),
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  direction: Axis.vertical,
                                  children: [
                                    Text(
                                        ApplicationLocalizations.of(context)
                                            .translate(i18.common.ATTACHMENTS),
                                        style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.normal)),
                                    Wrap(
                                        children: expensesDetailsProvider
                                            .expenditureDetails.fileStoreList!
                                            .map<Widget>((e) => InkWell(
                                                  onTap: () =>
                                                      expensesDetailsProvider
                                                          .onTapOfAttachment(
                                                              e, context),
                                                  child: Container(
                                                      width: 50,
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10,
                                                              horizontal: 5),
                                                      child: Wrap(
                                                          runSpacing: 5,
                                                          spacing: 8,
                                                          children: [
                                                            Image.asset(
                                                                'assets/png/attachment.png'),
                                                            Text(
                                                              '${CommonMethods.getExtension(e.url ?? '')}',
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            )
                                                          ])),
                                                ))
                                            .toList())
                                  ],
                                ),
                              ),
                            if (expensesDetailsProvider
                                    .expenditureDetails.allowEdit ??
                                true)
                              FilePickerDemo(
                                key: expensesDetailsProvider.filePickerKey,
                                callBack:
                                    expensesDetailsProvider.fileStoreIdCallBack,
                                extensions: ['jpg', 'pdf', 'png', 'jpeg'],
                                contextKey: expenseProvider
                                    .expenseWalkthrougList[5].key,
                              ),
                            if (isUpdate)
                              expensesDetailsProvider.isPSPCLEnabled &&
                                      expensesDetailsProvider
                                              .expenditureDetails.expenseType ==
                                          'ELECTRICITY_BILL'
                                  ? Container()
                                  : Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 18),
                                      child: Wrap(
                                        direction: Axis.horizontal,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 8,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Checkbox(
                                                value: expensesDetailsProvider
                                                    .expenditureDetails
                                                    .isBillCancelled,
                                                onChanged: expensesDetailsProvider
                                                            .expenditureDetails
                                                            .allowEdit ==
                                                        true && expensesDetailsProvider.expenditureDetails.isBillPaid == false
                                                    ? expensesDetailsProvider
                                                        .onChangeOfCheckBox
                                                    : null),
                                          ),
                                          Text(
                                              ApplicationLocalizations.of(
                                                      context)
                                                  .translate(i18.expense
                                                      .MARK_BILL_HAS_CANCELLED),
                                              style: TextStyle(
                                                  fontSize: 19,
                                                  color: expensesDetailsProvider
                                                              .expenditureDetails
                                                              .allowEdit ==    
                                                          true &&   expensesDetailsProvider.expenditureDetails.isBillPaid == false
                                                      ? Colors.black
                                                      : Colors.grey,
                                                  fontWeight:
                                                      FontWeight.normal))
                                        ],
                                      ),
                                    ),
                            SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ]),
                    ),
                  ))
                ])));
  }

  Widget buildTile(context, vendor) {
    var style = TextStyle(fontSize: 18);
    return Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${vendor?.name}', style: style),
            Text('${vendor.owner.mobileNumber}',
                style: style.apply(fontSizeDelta: -2))
          ],
        ));
  }

  bool get isUpdate => widget.id != null || widget.expensesDetails != null;
}
