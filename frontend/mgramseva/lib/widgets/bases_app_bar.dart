import 'package:flutter/material.dart';
import 'package:mgramseva/widgets/custom_app_bar.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Text title;
  final AppBar appBar;
  final List<Widget> widgets;

  /// you can add more fields that meet your needs

  const BaseAppBar(this.title, this.appBar, this.widgets);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar();
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
