import 'package:flutter/material.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/expenses_details_provider.dart';
import 'package:mgramseva/screeens/consumer_details/pointer.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:provider/provider.dart';

class ExpenseWalkThroughContainer extends StatefulWidget {
  final Function? onNext;

  ExpenseWalkThroughContainer(this.onNext);
  @override
  State<StatefulWidget> createState() {
    return _ExpenseWalkThroughContainerState();
  }
}

class _ExpenseWalkThroughContainerState
    extends State<ExpenseWalkThroughContainer> {
  int active = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpensesDetailsProvider>(
        builder: (_, expenseProvider, child) {
      RenderBox? box = expenseProvider
          .expenseWalkthrougList[expenseProvider.activeIndex]
          .key!
          .currentContext!
          .findRenderObject() as RenderBox?;
      Offset position = box!.localToGlobal(Offset.zero);
      return Stack(children: [
        Positioned(
            left: position.dx,
            top: position.dy,
            child: Container(
                width: MediaQuery.of(context).size.width / 1.06,
                child: Card(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            expenseProvider
                                .expenseWalkthrougList[
                                    expenseProvider.activeIndex]
                                .widget,
                          ],
                        ))))),
        Positioned(
            right: box.size.width / 3,
            top: expenseProvider.activeIndex ==
                    (expenseProvider.expenseWalkthrougList.length - 1)
                ? position.dy - 25
                : box.size.height + position.dy + 20,
            child: CustomPaint(
              painter: TrianglePainter(
                strokeColor: Colors.white,
                strokeWidth: 5,
                paintingStyle: PaintingStyle.fill,
              ),
              child: Container(
                height: 30,
                width: 50,
              ),
            )),
        Positioned(
            right: position.dx,
            top: expenseProvider.activeIndex ==
                    (expenseProvider.expenseWalkthrougList.length - 1)
                ? position.dy -
                    box.size.height -
                    (MediaQuery.of(context).size.width > 720 ? 65 : 40)
                : box.size.height + position.dy + 45,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: MediaQuery.of(context).size.width > 720
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 1.5,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 8),
                child: Card(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                      Padding(
                          padding:
                              EdgeInsets.only(top: 20, left: 10, right: 10),
                          child: Text(
                            ApplicationLocalizations.of(context).translate(
                                expenseProvider
                                    .expenseWalkthrougList[
                                        expenseProvider.activeIndex]
                                    .name),
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).primaryColorLight),
                            textAlign: TextAlign.start,
                          )),
                      expenseProvider.activeIndex ==
                              expenseProvider.expenseWalkthrougList.length - 1
                          ? Padding(
                              padding: EdgeInsets.only(
                                  top: 10, right: 20, bottom: 10),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                        onTap: () async {
                                          expenseProvider.activeIndex = 0;
                                          Navigator.pop(context);
                                          Provider.of<CommonProvider>(context,
                                              listen: false)
                                            ..walkThroughCondition(false,
                                                Constants.ADD_EXPENSE_KEY);
                                          setState(() {
                                            active = 0;
                                          });
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(5.0),
                                          height: 35,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color:
                                                Theme.of(context).primaryColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                              child: Text(
                                            ApplicationLocalizations.of(context)
                                                .translate(i18.common.END),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          )),
                                        ))
                                  ]))
                          : Padding(
                              padding: EdgeInsets.all(0),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                        onPressed: () async {
                                          expenseProvider.activeIndex = 0;
                                          Navigator.pop(context);
                                          Provider.of<CommonProvider>(context,
                                              listen: false)
                                            ..walkThroughCondition(false,
                                                Constants.ADD_EXPENSE_KEY);
                                          setState(() {
                                            active = 0;
                                          });
                                        },
                                        child: Text(
                                          ApplicationLocalizations.of(context)
                                              .translate(i18.common.SKIP),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .primaryColorLight),
                                        )),
                                    GestureDetector(
                                        onTap: () async {
                                          if (expenseProvider
                                                      .expenseWalkthrougList
                                                      .length -
                                                  1 <=
                                              active) {
                                            expenseProvider.activeIndex = 0;
                                            Navigator.pop(context);
                                            setState(() {
                                              active = 0;
                                            });
                                          } else {
                                            widget.onNext!(
                                                expenseProvider.activeIndex);
                                            await Scrollable.ensureVisible(
                                                expenseProvider
                                                    .expenseWalkthrougList[
                                                        expenseProvider
                                                            .activeIndex]
                                                    .key!
                                                    .currentContext!,
                                                duration: new Duration(
                                                    milliseconds: 100));

                                            setState(() {
                                              active = active + 1;
                                            });
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(5.0),
                                          height: 35,
                                          width: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color:
                                                Theme.of(context).primaryColor,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                              child: Text(
                                            ApplicationLocalizations.of(context)
                                                .translate(i18.common.NEXT),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12),
                                          )),
                                        ))
                                  ]))
                    ]))))
      ]);
    });
  }
}
