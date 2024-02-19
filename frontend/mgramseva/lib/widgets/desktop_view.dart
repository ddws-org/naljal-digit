import 'package:flutter/material.dart';
import 'package:mgramseva/widgets/back.dart';
import 'package:mgramseva/widgets/background_container.dart';
import 'package:mgramseva/widgets/footer_banner.dart';

class DesktopView extends StatelessWidget {
  final Widget widget;
  DesktopView(this.widget);

  @override
  Widget build(BuildContext context) {
    return (BackgroundContainer(Container(
      height: MediaQuery.of(context).size.height-20,
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                alignment: Alignment.topLeft,
              width: 500,
                child: Back(),
              ),
            ),
            (Center(
                child: new Container(
                    width: 500,
                    padding: EdgeInsets.all(15),
                    child: new Container(
                        padding: EdgeInsets.all(8), child: widget)))),
            FooterBanner()
          ]),
    )));
  }
}
