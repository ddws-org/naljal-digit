

import 'package:flutter/material.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String content;
  final List<Map>? actions;
   CustomDialog({required this.title, required this.content,Key? key, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text( '${ApplicationLocalizations.of(context).translate(title)}'),
      content: Text('${ApplicationLocalizations.of(context).translate(content)}'),
      actions: actions?.map((e) => TextButton(
        child: Text("${e['label']}"),
        onPressed: e['callBack'],
      )
    ).toList());
  }
}