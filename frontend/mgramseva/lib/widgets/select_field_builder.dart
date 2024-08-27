import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_widgets.dart';
import 'package:mgramseva/widgets/search_select_field_builder.dart';
import 'package:provider/provider.dart';

class SelectFieldBuilder extends StatefulWidget {
  final String labelText;
  final dynamic value;
  final String input;
  final String prefixText;
  final Function(dynamic) widget;
  final String Function(dynamic) itemAsString;
  final List<dynamic> options;
  final bool isRequired;
  final String? hint;
  final bool? readOnly;
  final bool showSearchBox;
  final String? requiredMessage;
  final GlobalKey? contextKey;
  final TextEditingController? controller;
  final Key? key;
  final GlobalKey<SearchSelectFieldState>? suggestionKey;

  const SelectFieldBuilder(this.labelText, this.value, this.input, this.prefixText,
      this.widget, this.options, this.isRequired,
      {this.hint,
      this.readOnly = false,
      this.requiredMessage,
      this.contextKey,
      this.controller,this.key, this.suggestionKey, required this.itemAsString, this.showSearchBox = false});

  @override
  State<SelectFieldBuilder> createState() => SelectFieldBuilderState();
}

class SelectFieldBuilderState extends State<SelectFieldBuilder> {
  var suggestionCtrl = new SuggestionsBoxController();

  @override
  Widget build(BuildContext context) {
// Label Text
    Widget textLabelWidget =
        Wrap(direction: Axis.horizontal, children: <Widget>[
      Text(ApplicationLocalizations.of(context).translate(widget.labelText),
          textAlign: TextAlign.left,
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: (!widget.readOnly!)
                  ? Theme.of(context).primaryColorDark
                  : Colors.grey)),
      Visibility(
        visible: widget.isRequired,
        child: Text('* ',
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: (!widget.readOnly! ?? true)
                    ? Theme.of(context).primaryColorDark
                    : Colors.grey)),
      ),
    ]);

    // //DropDown
    // Widget dropDown = DropdownButtonFormField(
    //   decoration: InputDecoration(
    //     prefixText: prefixText,
    //     prefixStyle: TextStyle(color: Theme.of(context).primaryColorDark),
    //     contentPadding:
    //         new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
    //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(1.0)),
    //   ),
    //   value: value,
    //   validator: (val) {
    //     if (isRequired != null && isRequired && val == null) {
    //       return ApplicationLocalizations.of(context)
    //           .translate(requiredMessage ?? '${labelText}_REQUIRED');
    //     }
    //     return null;
    //   },
    //   items: [],
    //   onChanged: !(isEnabled ?? true) || readOnly == true
    //       ? null
    //       : (value) => widget(value),
    // );

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > 760) {
        return Container(
          key: widget.contextKey,
          margin:
              const EdgeInsets.only(top: 5.0, bottom: 5, right: 20, left: 20),
          child: Row(children: [
            Container(
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width / 3,
                padding: EdgeInsets.only(top: 18, bottom: 3),
                child: textLabelWidget),
            Container(
                width: MediaQuery.of(context).size.width / 2.5,
                padding: EdgeInsets.only(top: 18, bottom: 3),
                child: Column(
                  children: [
                    Consumer<LanguageProvider>(
                        builder: (_, consumerProvider, child) =>
                            // SearchSelectField(
                            //     widget.labelText,
                            //     widget.options,
                            //     widget.controller,
                            //     widget.widget,
                            //     widget.value,
                            //     widget.isEnabled,
                            //     widget.isRequired,
                            //     widget.requiredMessage, key : widget.suggestionKey),
                      DropdownSearch(
                        key: widget.suggestionKey,
                        selectedItem: widget.value,
                        itemAsString: widget.itemAsString,
                        items: widget.options,
                        onChanged: widget.widget,
                        enabled: !widget.readOnly!,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            baseStyle: TextStyle(
                                color: !widget.readOnly!?Theme.of(context).primaryColorDark:Colors.grey
                            )
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: widget.showSearchBox,
                          fit: FlexFit.loose,
                          searchDelay: Duration(seconds: 0),
                          //comment this if you want that the items do not takes all available height
                          constraints: BoxConstraints(maxHeight: 400),
                        ),
                      )
                    ),
                    CommonWidgets().buildHint(
                      widget.hint,
                      context,
                    )
                  ],
                )),
          ]),
        );
      } else {
        return Container(
          key: widget.contextKey,
          margin: const EdgeInsets.only(top: 5.0, bottom: 5, right: 8, left: 8),
          child: Column(children: [
            Container(
                padding: EdgeInsets.only(top: 18, bottom: 3),
                child: new Align(
                    alignment: Alignment.centerLeft, child: textLabelWidget)),
            Consumer<LanguageProvider>(builder: (_, consumerProvider, child) {
              return DropdownSearch(
                key: widget.suggestionKey,
                selectedItem: widget.value,
              
                itemAsString: widget.itemAsString,
                items: widget.options,
                onChanged: widget.widget,
                enabled: !widget.readOnly!,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  baseStyle: TextStyle(
                    color: !widget.readOnly!?Theme.of(context).primaryColorDark:Colors.grey
                  )
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: widget.showSearchBox,
                  fit: FlexFit.loose,
                  searchDelay: Duration(seconds: 0),
                  //comment this if you want that the items do not takes all available height
                  constraints: BoxConstraints(maxHeight: 200),
                ),
              );
            }),
            CommonWidgets().buildHint(widget.hint, context)
          ]),
        );
      }
    });
  }
}
