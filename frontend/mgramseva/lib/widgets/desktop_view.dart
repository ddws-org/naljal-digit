import 'package:flutter/material.dart';
import 'package:mgramseva/widgets/background_container.dart';
import 'package:mgramseva/widgets/footer_banner.dart';

class DesktopView extends StatelessWidget {
  final Widget widget;
  DesktopView(this.widget);

  @override
  Widget build(BuildContext context) {
    return (BackgroundContainer(new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 4),
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                    ),
                    iconSize: 25,
                    color: Colors.white,
                    splashColor: Colors.purple,
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).maybePop()),
              )),
          (Center(
              child: new Container(
                  width: 500,
                  padding: EdgeInsets.all(15),
                  child: new Container(
                      padding: EdgeInsets.all(8), child: widget)))),
          FooterBanner()
        ])));
  }
}
