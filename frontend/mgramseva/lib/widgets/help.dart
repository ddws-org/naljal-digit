import 'package:flutter/material.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:provider/provider.dart';

class Help extends StatefulWidget {
  final VoidCallback? callBack;
  final String? walkThroughKey;

  Help({this.callBack, this.walkThroughKey});
  State<StatefulWidget> createState() {
    return _Help();
  }
}

class _Help extends State<Help> {
  @override
  void initState() {
    var commonProvider = Provider.of<CommonProvider>(context, listen: false);
    (commonProvider.getWalkThroughCheck(widget.walkThroughKey!)).then((value) {
      if (value == 'true' &&
          commonProvider.userDetails!.selectedtenant != null) {
        widget.callBack!();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: widget.callBack,
        icon: Icon(Icons.help_outline_outlined),
        iconSize: 30);
  }
}
