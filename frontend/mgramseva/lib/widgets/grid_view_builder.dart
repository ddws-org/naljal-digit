import 'package:flutter/material.dart';
import 'package:mgramseva/model/common/metric.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';

class GridViewBuilder extends StatelessWidget {
  final List<Metric> gridList;
  final int crossAxisCount;
  final ScrollPhysics? physics;
  const GridViewBuilder({Key? key, required this.gridList, this.crossAxisCount = 3, this.physics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var incrementer = crossAxisCount;

    return LayoutBuilder(
      builder: (_, constraints) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: GridView.count(
             shrinkWrap: true,
            crossAxisCount: crossAxisCount,
              physics: physics,
              childAspectRatio: constraints.maxWidth > 760 ?  (1 / .3) : 1.0,
              children: List.generate(gridList.length, (index) {
                var item = gridList[index];
                if(incrementer == index){
                  incrementer += crossAxisCount;
                }
                return GridTile(
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(width: index == (incrementer - crossAxisCount) ? 0 : 1.0, color: Colors.grey),
                        bottom:  BorderSide(width: index < gridList.length - (gridList.length % crossAxisCount == 0 ? crossAxisCount : gridList.length % crossAxisCount) ? 1.0 : 0, color: Colors.grey),
                        ),
                        color: Colors.white,
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      child:  Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${item.type == 'amount' ? '₹' : ''}${ApplicationLocalizations.of(context).translate('${item.label}')}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              ApplicationLocalizations.of(context).translate('${item.value}'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16
                              ),
                            )
                          ])),
                );
              }
              )
        ),
      ),
    );
  }
}

