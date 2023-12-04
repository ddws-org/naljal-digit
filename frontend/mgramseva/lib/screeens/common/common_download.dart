import 'package:flutter/material.dart';
import 'package:mgramseva/providers/bill_payments_provider.dart';
import 'package:mgramseva/providers/fetch_bill_provider.dart';
import 'package:provider/provider.dart';

class CommonDownload extends StatefulWidget {
  final Map query;
  CommonDownload({Key? key, required this.query});
  @override
  State<StatefulWidget> createState() {
    return CommonDownloadState();
  }
}

class CommonDownloadState extends State<CommonDownload> {
  @override
  void initState() {
    if (widget.query['mode'] == 'download-receipt') {
      Provider.of<BillPaymentsProvider>(context, listen: false)
        ..FetchBillPaymentsWithoutLogin(widget.query);
    } else if (widget.query['mode'] == 'pay') {
      Provider.of<FetchBillProvider>(context, listen: false)
        ..FetchBillwithoutLogin(widget.query);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(""),
    );
  }
}
