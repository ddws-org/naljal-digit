import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:provider/provider.dart';

class BasicDateField extends StatelessWidget {
  final format = DateFormat("dd/MM/yyyy");
  final label;
  final isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;
  final Function(DateTime?)? onChangeOfDate;
  final TextEditingController controller;
  final bool? isEnabled;
  final String? requiredMessage;
  final GlobalKey? contextKey;
  final Key? key;
  final String? Function(DateTime?)? validator;
  final AutovalidateMode? autoValidation;
  final EdgeInsets? margin;

  BasicDateField(this.label, this.isRequired, this.controller,
      {this.firstDate,
      this.lastDate,
      this.onChangeOfDate,
      this.initialDate,
      this.isEnabled,
      this.requiredMessage,
      this.autoValidation,
      this.contextKey, this.key, this.validator, this.margin});

  @override
  Widget build(BuildContext context) {
    Widget datePicker = AbsorbPointer(
        absorbing: !(isEnabled ?? true),
        child: DateTimeField(
            style: TextStyle(color: (isEnabled ?? true) ? null : Colors.grey),
            format: format,
            decoration: InputDecoration(
              fillColor: (isEnabled ?? true) ? Colors.white : Colors.grey,
              prefixText: "",
              suffixIcon: Icon(Icons.calendar_today),
              prefixStyle: TextStyle(color: Theme.of(context).primaryColorDark),
              contentPadding:
                  new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(1.0)),
              errorMaxLines: 3
            ),
            controller: controller,
            autovalidateMode: autoValidation,
            validator: validator ?? (val) {
              if (isRequired != null &&
                  isRequired &&
                  controller.text.trim().isEmpty) {
                return ApplicationLocalizations.of(context)
                    .translate(requiredMessage ?? '${label}_REQUIRED');
              }
              return null;
            },
            onShowPicker: (context, currentValue) {
              var languageProvider =
                  Provider.of<LanguageProvider>(context, listen: false);
              return showDatePicker(
                context: context,
                locale: languageProvider.selectedLanguage!.value
                            .toString()
                            .split('_')[0] ==
                        'pn'
                    ? Locale('pa', 'IN')
                    : Locale(
                        languageProvider.selectedLanguage!.value
                            .toString()
                            .split('_')[0],
                        languageProvider.selectedLanguage!.value
                            .toString()
                            .split('_')[1]),
                firstDate: firstDate ?? DateTime(1900),
                initialDate:
                    initialDate ?? lastDate ?? currentValue ?? DateTime.now(),
                lastDate: lastDate ?? DateTime(2100),
              );
            },
            onChanged: onChangeOfDate));

    Widget textLabelwidget = Row(children: <Widget>[
      Text(ApplicationLocalizations.of(context).translate(label),
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: (isEnabled ?? true)
                  ? Theme.of(context).primaryColorDark
                  : Theme.of(context).disabledColor)),
      Text(isRequired ? '* ' : ' ',
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: (isEnabled ?? true)
                  ? Theme.of(context).primaryColorDark
                  : Theme.of(context).disabledColor)),
    ]);

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 760) {
        return Container(
            key: contextKey,
            margin:
            margin ?? EdgeInsets.only(top: 5.0, bottom: 5, right: 8, left: 8),
            child: Column(children: [
              Container(
                  padding: EdgeInsets.only(top: 18, bottom: 3),
                  child: new Align(
                      alignment: Alignment.centerLeft, child: textLabelwidget)),
              datePicker,
            ]));
      } else {
        return Container(
            key: contextKey,
            margin: margin ?? EdgeInsets.only(
                top: 20.0, bottom: 5, right: 20, left: 20),
            child: Row(children: [
              Container(
                  padding: EdgeInsets.only(top: 18, bottom: 3),
                  width: MediaQuery.of(context).size.width / 3,
                  child: new Align(
                      alignment: Alignment.centerLeft, child: textLabelwidget)),
              Container(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: datePicker),
            ]));
      }
    });
  }
}
