import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mgramseva/widgets/keyboard_focus_watcher.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/expenses_details_provider.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';
import 'package:mgramseva/utils/notifiers.dart';
import 'package:mgramseva/widgets/bottom_button_bar.dart';
import 'package:mgramseva/widgets/drawer_wrapper.dart';
import 'package:mgramseva/widgets/form_wrapper.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:mgramseva/widgets/label_text.dart';
import 'package:mgramseva/widgets/select_field_builder.dart';
import 'package:mgramseva/widgets/side_bar.dart';
import 'package:mgramseva/widgets/sub_label.dart';
import 'package:mgramseva/widgets/text_field_builder.dart';
import 'package:mgramseva/widgets/custom_app_bar.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:provider/provider.dart';

class SearchExpense extends StatefulWidget {
  const SearchExpense({Key? key}) : super(key: key);

  @override
  _SearchExpenseState createState() => _SearchExpenseState();
}

class _SearchExpenseState extends State<SearchExpense> {
  var vendorNameCtrl = TextEditingController();
  String? expenseType;
  var billIdCtrl = TextEditingController();
  var expenseTypeCtrl = TextEditingController();
  bool isVisible = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }
  afterViewBuild() {
    Provider.of<ExpensesDetailsProvider>(context, listen: false)..getExpenses();
  }
  @override
  Widget build(BuildContext context) {
    return KeyboardFocusWatcher(child:Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(),
      drawer: DrawerWrapper(
        Drawer(child: SideBar()),
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        FormWrapper(
          Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeBack(),
                Card(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      LabelText(i18.expense.SEARCH_EXPENSE_BILL),
                      SubLabelText(
                        i18.expense.ENTER_VENDOR_BILL_EXPENSE,
                      ),
                      BuildTextField(
                        i18.expense.VENDOR_NAME,
                        vendorNameCtrl,
                        key: Keys.expense.SEARCH_VENDOR_NAME,
                      ),
                      Text(
                          '\n${ApplicationLocalizations.of(context).translate(i18.common.OR)}',
                          textAlign: TextAlign.center),
                      Consumer<ExpensesDetailsProvider>(
                        builder: (_, expensesDetailsProvider, child) {
                          return SelectFieldBuilder(
                            i18.expense.EXPENSE_TYPE,
                            expenseType,
                            '',
                            '',
                            onChangeOfExpense,
                            expensesDetailsProvider.getExpenseTypeList(isSearch: true)??[],
                            false,
                            hint:
                            '${ApplicationLocalizations.of(context).translate(i18.common.ELECTRICITY_HINT)}',
                            controller: expenseTypeCtrl,
                            key: Keys.expense.SEARCH_EXPENSE_TYPE, itemAsString: (i) =>'${ApplicationLocalizations.of(context)
                              .translate(
                              i.toString())}',
                          );
                        }
                            ,
                      ),
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                                '\n${ApplicationLocalizations.of(context).translate(i18.common.OR)}',
                                textAlign: TextAlign.center),
                            BuildTextField(
                              i18.common.BILL_ID,
                              billIdCtrl,
                              hint: i18.common.BILL_HINT,
                              textCapitalization:
                                  TextCapitalization.characters,
                              inputFormatter: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[A-Z0-9-]"))
                              ],
                              key: Keys.expense.SEARCH_EXPENSE_BILL_ID,
                            ),
                          ]),
                    ]))
              ]),
        ),
        Footer()
      ])),
      bottomNavigationBar: BottomButtonBar(i18.common.SEARCH, onSubmit, key: Keys.expense.SEARCH_EXPENSES),
    ));
  }

  void onChangeOfExpense(val) {
    setState(() {
      expenseType = val;
    });
  }

  void onSubmit() {
    FocusScope.of(context).nextFocus();
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);

    if (vendorNameCtrl.text.trim().isNotEmpty ||
        expenseType != null ||
        billIdCtrl.text.trim().isNotEmpty) {
      var query = {
        'tenantId': commonProvider.userDetails?.selectedtenant?.code,
        'vendorName': vendorNameCtrl.text.trim(),
        'expenseType': expenseType,
        'challanNo': billIdCtrl.text.trim()
      };

      query.removeWhere((key, value) => value == null || value.trim().isEmpty);



      Provider.of<ExpensesDetailsProvider>(context, listen: false)
          .searchExpense(query, () => getCrteria(query), context);
    } else {
      Notifiers.getToastMessage(context, i18.expense.NO_FIELDS_FILLED, 'ERROR');
    }
  }

  String getCrteria(Map query){
    var criteria = '';

    query.forEach((key, value) {
      switch (key) {
        case 'expenseType':
          criteria +=
          '${ApplicationLocalizations.of(context).translate(i18.expense.EXPENSE_TYPE)} ${ApplicationLocalizations.of(context).translate(expenseType ?? '')} \t';
          break;
        case 'challanNo':
          criteria +=
          '${ApplicationLocalizations.of(context).translate(i18.common.BILL_ID)} ${billIdCtrl.text}';
          break;
        case 'vendorName':
          criteria +=
          '${ApplicationLocalizations.of(context).translate(i18.expense.VENDOR_NAME)} ${vendorNameCtrl.text} \t';
          break;
      }
    });
    return criteria;
  }
}
