import 'package:flutter/material.dart';

class GridCard extends StatelessWidget {
  final List<Map<String, Object>> data;
  GridCard(this.data);

  @override
  Widget build(BuildContext context) {
    late int i = 0;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return GridView.count(
        physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio:  constraints.maxWidth < 760 ? 1.2 : 6,
                  shrinkWrap: true,
                  children: data.map((
                      Map e,
                    ) {
                      Widget _tile = GridTile(
                        child: new Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.white, width: 0),
                              borderRadius: BorderRadius.circular(0),
                            ),
                            margin: EdgeInsets.zero,
                            child: Container(
                              alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: i != 0 && i != 2 && i != 1
                                        ? BorderSide(
                                            width: 1.0, color: Colors.grey)
                                        : BorderSide(
                                            width: 0.0, color: Colors.grey),
                                    left: i != 0 && i != 3 && i != 6
                                        ? BorderSide(
                                            width: 1.0, color: Colors.grey)
                                        : BorderSide(
                                            width: 0.0, color: Colors.grey),
                                  ),
                                  color: Colors.white,
                                ),
                                padding: EdgeInsets.all(2),
                                child: new Center(
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        new Text(
                                          e["value"].toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          e["label"].toString(),
                                          textAlign: TextAlign.center,
                                        )
                                      ]),
                                ))),
                      );
                      i++;
                      return _tile;
                    }).toList()
                  );
    });
  }
}
