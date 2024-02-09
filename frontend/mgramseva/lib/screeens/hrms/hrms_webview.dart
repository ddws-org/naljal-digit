import 'package:flutter/material.dart';
import 'package:mgramseva/screeens/home/home.dart';
import 'package:mgramseva/widgets/custom_app_bar.dart';
import 'package:mgramseva/widgets/home_back.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/drawer_wrapper.dart';
import '../../widgets/side_bar.dart';

class HrmsWebview extends StatefulWidget {
  @override
  State<HrmsWebview> createState() => _HrmsWebviewState();
}

class _HrmsWebviewState extends State<HrmsWebview> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: DrawerWrapper(
        Drawer(child: SideBar()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children:<Widget> [
            HomeBack(),
            WebView(
              initialUrl: 'https://naljal-uat.digit.org/mgramseva-web/employee/user/language-selection',
              javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (finish) {
                  setState(() {
                    isLoading = false;
                  });
                }
            ),
            isLoading ? Center(child: CircularProgressIndicator(),):Stack()
          ],
        ),
      )

      /*      Stack(
          children: <Widget>[
            WebView(
              initialUrl: 'https://naljal-uat.digit.org/mgramseva-web/employee/user/language-selection',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (finish) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
            isLoading ? Center( child: CircularProgressIndicator(),)
                : Stack(),
          ],
        )*/
      ,
    );
  }
}
