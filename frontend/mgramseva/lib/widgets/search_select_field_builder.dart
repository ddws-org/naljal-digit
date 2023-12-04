import 'package:flutter/material.dart';
import 'package:flutter_focus_watcher/flutter_focus_watcher.dart';
import 'package:mgramseva/providers/language.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:provider/provider.dart';

class SearchSelectField extends StatefulWidget {
  final String labelText;
  final List<dynamic> options;
  final dynamic value;
  final Function(dynamic) widget;
  final bool? isEnabled;
  final bool isRequired;
  final String? requiredMessage;
  final TextEditingController? controller;
  const SearchSelectField(this.labelText, this.options, this.controller, this.widget,
      this.value, this.isEnabled, this.isRequired, this.requiredMessage, {Key? key}) : super(key: key);
  @override
  SearchSelectFieldState createState() => SearchSelectFieldState();
}

class SearchSelectFieldState extends State<SearchSelectField> {
  final FocusNode _focusNode = FocusNode();
  bool isInit = false;
  var selectedCode;
  // ignore: non_constant_identifier_names
  List<DropdownMenuItem<Object>> Options = [];
  late OverlayEntry _overlayEntry;

  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        this._overlayEntry = this._createOverlayEntry();
        Overlay.of(context).insert(this._overlayEntry);
      } else {
        this._overlayEntry.remove();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
    filerobjects("");
  }

  afterViewBuild() {
    var res = widget.options
        .where((e) => (e.toString() == (widget.value)));
    if (res.isNotEmpty && _focusNode.hasFocus == false) {
      widget.controller?.text = ApplicationLocalizations.of(context)
          .translate((res.first).toString());
    }
  }

  filerobjects(val) {
    if (val != "") {
      setState(() {
        isInit = true;
        Options = widget.options
            .where((element) => element
                .toString()
                .toLowerCase()
                .contains(val.toString().toLowerCase())).map((e) =>
                    DropdownMenuItem(
                          value: e,
                          child: new Text(('${e.toString()}')),
                    ),
        ).toList();
      });
    } else {
      setState(() {
        Options = widget.options.map((e) =>
            DropdownMenuItem(
              value: e,
              child: new Text(('${e.toString()}')),
            ),
        ).toList();
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox? renderBox = context.findRenderObject() as RenderBox?;

    var size = renderBox!.size;

    return OverlayEntry(
        builder: (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: this._layerLink,
              showWhenUnlinked: true,
              offset: Offset(0.0, size.height),
              child: Material(
                elevation: 4.0,
                child: Container(
                  height: Options.length == 0 && isInit == false
                      ? (widget.options.length * 50 < 150
                          ? widget.options.length * 50
                          : 150)
                      : (Options.length * 50 < 150 ? Options.length * 50 : 150),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: <Widget>[
                      for (var item in Options.length == 0 && isInit == false
                          ? widget.options
                          : Options)
                        Ink(
                            color: Colors.white,
                            child: ListTile(
                              title: Text(ApplicationLocalizations.of(context)
                                  .translate(
                                      item.toString())),
                              onTap: () {
                                widget.widget(item.toString());
                                setState(() {
                                  selectedCode = item;
                                });
                                widget.controller?.text =
                                    ApplicationLocalizations.of(context)
                                        .translate((item.toString()));
                                _focusNode.unfocus();
                              },
                            )),
                    ],
                  ),
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Consumer<LanguageProvider>(builder: (_, consumerProvider, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
        return SizedBox(
          height: 0,
        );
      }),
      CompositedTransformTarget(
        link: this._layerLink,
        child: ForceFocusWatcher(
          child:TextFormField(
          style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
              color: (widget.isEnabled ?? true)
                  ? Theme.of(context).primaryColorDark
                  : Colors.grey),
          controller: widget.controller,
          onChanged: (value) => filerobjects(value),
          focusNode: this._focusNode,
          validator: (value) {
            if((value ?? '').trim().isEmpty && !widget.isRequired){
              return null;
            }else if(value!.isEmpty && widget.isRequired){
              return ApplicationLocalizations.of(context).translate(
                  widget.requiredMessage ?? '${widget.labelText}_REQUIRED');
            } else if (widget.options
                .where((element) =>
                    ApplicationLocalizations.of(context)
                        .translate((element).toString())
                        .toLowerCase() ==
                    (value.toString().toLowerCase()))
                .toList()
                .isEmpty) {
              return ApplicationLocalizations.of(context).translate(
                  widget.requiredMessage ?? '${i18.common.INVALID_SELECTED_INPUT}');
            }
            if (value.trim().isEmpty && widget.isRequired) {
              return ApplicationLocalizations.of(context).translate(
                  widget.requiredMessage ?? '${widget.labelText}_REQUIRED');
            }
            return null;
          },
          decoration: InputDecoration(
            suffixIcon: Icon(Icons.arrow_drop_down),
            errorMaxLines: 2,
            enabled: widget.isEnabled ?? true,
            fillColor: widget.isEnabled != null && widget.isEnabled!
                ? Colors.grey
                : Colors.white,
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ))
    ]);
  }
}
