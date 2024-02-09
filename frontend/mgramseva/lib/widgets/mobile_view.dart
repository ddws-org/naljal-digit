import 'package:flutter/material.dart';
import 'package:mgramseva/widgets/back.dart';
import 'package:mgramseva/widgets/background_container.dart';
import 'package:mgramseva/widgets/desktop_view.dart';
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
    return SingleChildScrollView(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
          Container(child: Center(child: LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
            return ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height-80),
                child: IntrinsicHeight(
                    child: Column(children: <Widget>[
                  Expanded(
                      // A flexible child that will grow to fit the viewport but
                      // still be at least as big as necessary to fit its contents.
                      child: Container(
                          //height: 120.0,
                          child: new Container(
                              child: new Stack(
                                  // // fit: StackFit.expand,
                                  // clipBehavior: Clip.antiAlias,
                                  children: <Widget>[
                                (new Positioned(
                                    bottom: 30.0,
                                    child: new Container(
                                        margin: EdgeInsets.only(bottom: 24),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        // height: MediaQuery.of(context).size.height + 20,
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Back(),
                                              ],
                                            ),
                                            widget,
                                          ],
                                        )))),
                                (new Positioned(
                                    bottom: 0.0,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          FooterBanner(),
                                        ],
                                      ),
                                    )))
                              ]))))
                ])));
          })))
        ]));
  }
}
