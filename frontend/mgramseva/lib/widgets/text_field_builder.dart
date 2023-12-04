import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_widgets.dart';

class BuildTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isRequired;
  final String input;
  final String prefixText;
  final Function(String)? onChange;
  final Function(String)? onSubmit;
  final String? pattern;
  final String message;
  final FocusNode? focusNode;
  final List<FilteringTextInputFormatter>? inputFormatter;
  final Function(String?)? validator;
  final int? maxLength;
  final int? maxLines;
  final TextCapitalization? textCapitalization;
  final bool? obscureText;
  final TextInputType? textInputType;
  final bool? isDisabled;
  final bool? readOnly;
  final String? labelSuffix;
  final String? hint;
  final String? requiredMessage;
  final InputBorder? inputBorder;
  final Widget? prefixIcon;
  final String? placeHolder;
  final GlobalKey? contextKey;
  final AutovalidateMode? autoValidation;
  final bool? isFilled;
  final Widget? suffixIcon;
  final Key? key;
  final TextInputAction? textInputAction;

  BuildTextField(this.labelText, this.controller,
      {this.input = '',
        this.prefixText = '',
        this.onChange,
        this.isRequired = false,
        this.onSubmit,
        this.pattern = '',
        this.message = '',
        this.inputFormatter,
        this.validator,
        this.maxLength,
        this.maxLines,
        this.textCapitalization,
        this.obscureText,
        this.textInputType,
        this.isDisabled,
        this.readOnly,
        this.labelSuffix,
        this.hint,
        this.focusNode,
        this.inputBorder,
        this.prefixIcon,
        this.placeHolder,
        this.contextKey,
        this.isFilled,
        this.requiredMessage,
        this.autoValidation,
        this.suffixIcon,
        this.key, this.textInputAction});

  @override
  State<StatefulWidget> createState() => _BuildTextField();
}

class _BuildTextField extends State<BuildTextField> {
  @override
  Widget build(BuildContext context) {
    // TextForm
    Widget textFormWidget = ForceFocusWatcher(
        child: TextFormField(
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: widget.isDisabled != null && widget.isDisabled!
                    ? Colors.grey
                    : Theme.of(context).primaryColorDark),
            enabled: widget.isDisabled != null
                ? (widget.isDisabled == true)
                ? false
                : true
                : true,
            controller: widget.controller,
            keyboardType: widget.textInputType ?? TextInputType.text,
            textInputAction: widget.textInputAction??TextInputAction.done,
            inputFormatters: widget.inputFormatter,
            autofocus: false,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            focusNode: widget.focusNode,
            autovalidateMode: widget.autoValidation,
            textCapitalization:
            widget.textCapitalization ?? TextCapitalization.none,
            obscureText: widget.obscureText ?? false,
            readOnly: widget.readOnly ?? false,
            validator: widget.validator != null
                ? (val) => widget.validator!(val)
                : (value) {
              if (value!.trim().isEmpty && widget.isRequired) {
                return ApplicationLocalizations.of(context).translate(
                    widget.requiredMessage ?? '${widget.labelText}_REQUIRED');
              } else if (widget.pattern != null && widget.pattern != '') {
                return (new RegExp(widget.pattern!).hasMatch(value))
                    ? null
                    : ApplicationLocalizations.of(context)
                    .translate(widget.message);
              }
              return null;
            },
            decoration: InputDecoration(
                hintText: widget.placeHolder != null
                    ? ApplicationLocalizations.of(context)
                    .translate((widget.placeHolder!))
                    : "",
                border: widget.inputBorder,
                enabledBorder: widget.inputBorder,
                errorMaxLines: 2,
                enabled: widget.isDisabled ?? true,
                filled: widget.isFilled,
                fillColor: widget.isDisabled != null && widget.isDisabled!
                    ? Colors.grey
                    : Colors.white,
                prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                prefixStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color:
                    widget.isDisabled != null && widget.isDisabled!
                        ? Colors.grey
                        : Theme.of(context).primaryColorDark),
                prefixIcon: widget.prefixIcon ??
                    (widget.prefixText == ''
                        ? null
                        : Padding(
                      padding: const EdgeInsets.only(top: 10, left: 10, bottom: 10, right: 0),
                      child: Text(
                        widget.prefixText,
                        style: TextStyle(
                            fontSize: kIsWeb ? 15 : 16,
                            fontWeight: FontWeight.w400,
                            color:
                            widget.isDisabled != null && widget.isDisabled!
                                ? Colors.grey
                                : Theme.of(context).primaryColorDark),
                      ),
                    )),
                suffixIcon: widget.suffixIcon
            ),
            onChanged: widget.onChange,
            onFieldSubmitted: widget.onSubmit,
        ));
// Label Text
    Widget textLabelwidget =
    Wrap(direction: Axis.horizontal, children: <Widget>[
      Text(
          '${ApplicationLocalizations.of(context).translate(widget.labelText)}'
              '${widget.labelSuffix != null ? ' ${widget.labelSuffix}' : ''}',
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: widget.isDisabled != null && widget.isDisabled!
                  ? Colors.grey
                  : Theme.of(context).primaryColorDark)),
      Text(widget.isRequired ? '*' : ' ',
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: widget.isDisabled != null && widget.isDisabled!
                  ? Colors.grey
                  : Theme.of(context).primaryColorDark)),
    ]);
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 760) {
        return Container(
            key: widget.contextKey,
            margin:
            const EdgeInsets.only(top: 5.0, bottom: 5, right: 20, left: 20),
            child: Row(
              children: [
                Visibility(
                  visible: widget.labelText.isNotEmpty,
                  child: Container(
                      width: MediaQuery.of(context).size.width / 3,
                      padding: EdgeInsets.only(top: 18, bottom: 3),
                      child: new Align(
                          alignment: Alignment.centerLeft,
                          child: textLabelwidget)),
                ),
                Container(
                    width: MediaQuery.of(context).size.width / 2.5,
                    padding: EdgeInsets.only(top: 18, bottom: 3),
                    child: Column(
                      children: [
                        textFormWidget,
                        CommonWidgets().buildHint(widget.hint, context)
                      ],
                    )),
              ],
            ));
      } else {
        return Container(
            key: widget.contextKey,
            margin:
            const EdgeInsets.only(top: 5.0, bottom: 5, right: 8, left: 8),
            child: Column(
              children: [
                Visibility(
                  visible: widget.labelText.isNotEmpty,
                  child: Container(
                      padding: EdgeInsets.only(top: 18, bottom: 3),
                      child: new Align(
                          alignment: Alignment.centerLeft,
                          child: textLabelwidget)),
                ),
                textFormWidget,
                CommonWidgets().buildHint(widget.hint, context)
              ],
            ));
      }
    });
  }
}