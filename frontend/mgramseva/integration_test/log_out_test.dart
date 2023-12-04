import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mgramseva/main.dart' as app;
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';

void main() {
  testWidgets("Log Out Test", (tester) async {
    app.main();
    await tester.pumpAndSettle(Duration(milliseconds: 3000));

    final appBar = find.byType(AppBar);
    await tester.tap(appBar);
    await tester.pumpAndSettle(Duration(seconds: 3));

    final tapAppDrawer = find.byIcon(Icons.menu);
    await tester.tap(tapAppDrawer);
    await tester.pumpAndSettle(Duration(seconds: 3));

    final tapLogOutTile = find.byKey(Keys.common.LOGOUT_TILE_KEY);
    await tester.tap(tapLogOutTile);
    await tester.pumpAndSettle(Duration(seconds: 5));

  });
}
