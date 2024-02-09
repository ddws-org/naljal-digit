import 'package:flutter/material.dart';
import 'package:mgramseva/widgets/back.dart';
import 'package:mgramseva/widgets/background_container.dart';
import 'package:mgramseva/widgets/footer_banner.dart';

class MobileView extends StatelessWidget {
  final Widget widget;
  MobileView(this.widget);

  @override
  Widget build(BuildContext context) {
    return (BackgroundContainer(Container(
      height: MediaQuery.of(context).size.height-80,
      child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Center(
              child: Container(
                alignment: Alignment.topLeft,
                child: Back(),
              ),
            ),
            (Center(
                child: new Container(
                    padding: EdgeInsets.all(15),
                    child: new Container(
                        padding: EdgeInsets.all(8), child: widget)))),
            FooterBanner()
          ]),
    )));
  }
}
