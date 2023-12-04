import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mgramseva/model/common/metric.dart';
import 'package:mgramseva/providers/common_provider.dart';
import 'package:mgramseva/providers/dashboard_provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/constants.dart';
import 'package:mgramseva/utils/date_formats.dart';
import 'package:mgramseva/utils/global_variables.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:mgramseva/utils/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf/widgets.dart' as pw;

class DashboardPdfCreator {
  final List<String> headers;
  final List<List<String>> tableData;
  final List<Metric> gridList;
  BuildContext buildContext;
  final Map feedBack;

  DashboardPdfCreator(this.buildContext, this.headers, this.tableData,
      this.gridList, this.feedBack);

  pdfPreview() async {
    var pdf = pw.Document();
    var dashBoardProvider = Provider.of<DashBoardProvider>(
        navigatorKey.currentContext!,
        listen: false);

    final ttf = await Provider.of<CommonProvider>(buildContext, listen: false)
        .getPdfFontFamily();

    final mgramSevaLogo = await PdfUtils.mgramSevaLogo;
    final digitLogo = await PdfUtils.powerdByDigit;

    var icons =
        pw.Font.ttf(await rootBundle.load('assets/icons/fonts/PdfIcons.ttf'));

    String billDescription = '';
    String recordsCount =
        '${ApplicationLocalizations.of(buildContext).translate(i18.dashboard.NUMBER_OF_RECORDS)}';
    recordsCount = recordsCount.replaceAll('{n}', '${tableData.length}');

    if (dashBoardProvider.selectedDashboardType == DashBoardType.Expenditure) {
      billDescription =
          '${ApplicationLocalizations.of(buildContext).translate(i18.dashboard.EXPENDITURE_DESC)}';
      billDescription = billDescription.replaceAll('{Pending Or Paid}',
          '${ApplicationLocalizations.of(buildContext).translate(dashBoardProvider.selectedTab)}');
      billDescription = billDescription.replaceAll('{text}',
          '${dashBoardProvider.searchController.text.trim().isEmpty ? '-' : dashBoardProvider.searchController.text.trim()}');
      billDescription = billDescription.replaceAll(
          '{Time period}',
          DateFormats.getMonthAndYear(
              dashBoardProvider.selectedMonth, buildContext));
    } else {
      billDescription =
          '${ApplicationLocalizations.of(buildContext).translate(i18.dashboard.COLLECTION_DESC)}';
      billDescription = billDescription.replaceAll(
          '{Residential or Commercial}',
          '${ApplicationLocalizations.of(buildContext).translate(dashBoardProvider.selectedTab)}');
      billDescription = billDescription.replaceAll('{text}',
          '${dashBoardProvider.searchController.text.trim().isEmpty ? '-' : dashBoardProvider.searchController.text.trim()}');
    }

    pdf.addPage(pw.MultiPage(
        maxPages: Constants.MAX_PDF_PAGES,
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.symmetric(horizontal: 16, vertical: 25),
        footer: (_) => PdfUtils.pdfFooter(digitLogo),
        build: (pw.Context context) {
          return [
            PdfUtils.buildAppBar(buildContext, mgramSevaLogo, icons, ttf),
            _buildDashboardView(buildContext, feedBack, icons, ttf),
            _buildGridView(gridList, buildContext, ttf),
            pw.Container(
                margin: pw.EdgeInsets.only(top: 14, bottom: 3),
                child: pw.Text(
                    '${ApplicationLocalizations.of(buildContext).translate(dashBoardProvider.selectedDashboardType == DashBoardType.Expenditure ? i18.dashboard.EXPENDITURE_BILLS : i18.dashboard.CONSUMER_RECORDS)}',
                    style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        font: ttf))),
            pw.Padding(
                padding: pw.EdgeInsets.only(top: 8, bottom: 20),
                child: pw.Text(
                  billDescription,
                  style: pw.TextStyle(
                    font: ttf,
                    fontStyle: pw.FontStyle.italic,
                    fontSize: 10,
                    color: PdfColor.fromHex('#474747'),
                  ),
                )),
            pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: pw.EdgeInsets.only(bottom: 10),
                child: pw.Text(
                  recordsCount,
                  style: pw.TextStyle(
                      font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 10),
                )),
            _buildTable(ttf),
          ];
        }));

    var localizedText =
        '${ApplicationLocalizations.of(buildContext).translate(i18.dashboard.MONTHLY_REPORT_MESSAGE)}';
    localizedText = localizedText.replaceAll(
        '{Month-Year}',
        DateFormats.getMonthAndYear(
            dashBoardProvider.selectedMonth, buildContext));

    Provider.of<CommonProvider>(buildContext, listen: false)
        .sharePdfOnWhatsApp(buildContext, pdf, 'dashboard', localizedText);
  }

  pw.Widget _buildGridView(
      List<Metric> gridList, BuildContext context, pw.Font font) {
    var dashBoardProvider = Provider.of<DashBoardProvider>(
        navigatorKey.currentContext!,
        listen: false);

    var crossAxisCount = 3;
    var incrementer = 3;
    return gridList.isEmpty
        ? pw.Container()
        : pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#fafafa'),
                ),
                width: 200,
                alignment: pw.Alignment.centerLeft,
                padding: pw.EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                margin: pw.EdgeInsets.only(top: 8, bottom: 3),
                child: pw.Text(
                    '${ApplicationLocalizations.of(context).translate('${dashBoardProvider.selectedDashboardType == DashBoardType.Expenditure ? i18.dashboard.EXPENDITURE : i18.dashboard.COLLECTIONS}')}',
                    style: pw.TextStyle(
                        fontSize: 14,
                        font: font,
                        fontWeight: pw.FontWeight.bold))),
            pw.Container(
                height: ((gridList.length / 3).ceil()) * 60,
                color: PdfColor.fromHex('#fafafa'),
                child: pw.GridView(
                    crossAxisCount: crossAxisCount,
                    children: List.generate(gridList.length, (index) {
                      var item = gridList[index];
                      if (incrementer == index) {
                        incrementer += crossAxisCount;
                      }
                      return pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              left: pw.BorderSide(
                                  width: index == (incrementer - crossAxisCount)
                                      ? 0
                                      : 1.0,
                                  color: index == (incrementer - crossAxisCount)
                                      ? PdfColor.fromHex('#FFFFFF')
                                      : PdfColor.fromHex('#808080')),
                              bottom: pw.BorderSide(
                                  width: index <
                                          gridList.length -
                                              (gridList.length %
                                                          crossAxisCount ==
                                                      0
                                                  ? crossAxisCount
                                                  : gridList.length %
                                                      crossAxisCount)
                                      ? 1.0
                                      : 0,
                                  color: index <
                                          gridList.length -
                                              (gridList.length %
                                                          crossAxisCount ==
                                                      0
                                                  ? crossAxisCount
                                                  : gridList.length %
                                                      crossAxisCount)
                                      ? PdfColor.fromHex('#808080')
                                      : PdfColor.fromHex('#FFFFFF')),
                            ),
                          ),
                          alignment: pw.Alignment.center,
                          padding: pw.EdgeInsets.symmetric(
                              vertical: 3, horizontal: 16),
                          child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.center,
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  '${item.type == 'amount' ? '₹' : ''}${ApplicationLocalizations.of(context).translate('${item.label}')}',
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    font: font,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  ApplicationLocalizations.of(context)
                                      .translate('${item.value}'),
                                  textAlign: pw.TextAlign.center,
                                  style: pw.TextStyle(fontSize: 12, font: font),
                                )
                              ]));
                    })))
          ]);
  }

  pw.Widget _buildDashboardView(
      BuildContext context, Map feedBack, pw.Font icons, pw.Font font) {
    var dashBoardProvider = Provider.of<DashBoardProvider>(
        navigatorKey.currentContext!,
        listen: false);

    return pw.Container(
        color: PdfColor.fromHex('#fafafa'),
        padding: pw.EdgeInsets.symmetric(vertical: 3, horizontal: 8),
        child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
          pw.Padding(
              padding: pw.EdgeInsets.symmetric(vertical: 8),
              child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        '${ApplicationLocalizations.of(context).translate(i18.dashboard.DASHBOARD)}',
                        style: pw.TextStyle(
                            fontSize: 32,
                            font: font,
                            fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                        DateFormats.getMonthAndYear(
                            dashBoardProvider.selectedMonth, context),
                        style: pw.TextStyle(
                            font: font,
                            fontSize: 12,
                            color: PdfColor.fromHex('#F47738')))
                  ])),
          if (feedBack.isNotEmpty)
            _buildRatingView(context, feedBack, icons, font)
        ]));
  }

  pw.Widget _buildRatingView(
      BuildContext context, Map feedBack, pw.Font icons, pw.Font font) {
    var dashBoardProvider = Provider.of<DashBoardProvider>(
        navigatorKey.currentContext!,
        listen: false);
    Map feedBackDetails = Map.from(feedBack);
    feedBackDetails.remove('count');

    var localizationLabel =
        '${ApplicationLocalizations.of(context).translate(i18.dashboard.USER_GAVE_FEEDBACK)}';
    localizationLabel = localizationLabel.replaceAll(
        '{n}', (feedBack['count'] ?? 0).toString());
    localizationLabel = localizationLabel
        .replaceAll(
            '{date}',
            DateFormats.getMonthAndYear(
                dashBoardProvider.selectedMonth, context))
        .toString();

    return pw.Padding(
        padding: pw.EdgeInsets.symmetric(horizontal: 10),
        child: pw.Wrap(children: [
          pw.Container(
              height: 60,
              child: pw.GridView(
                crossAxisCount: 3,
                // childAspectRatio: 1.2,
                children: List.generate(
                  feedBackDetails.keys.length,
                  (index) => pw.Container(
                      decoration: pw.BoxDecoration(
                        // color: PdfColor.fromHex('#00703C'),
                        border: index == 0
                            ? null
                            : pw.Border(
                                left: pw.BorderSide(
                                width: 1.0, /*color: Colors.grey*/
                              )),
                        // color: Colors.white,
                      ),
                      padding: pw.EdgeInsets.all(12),
                      child: pw.Center(
                        child: pw.Column(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            crossAxisAlignment: pw.CrossAxisAlignment.center,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.center,
                                children: [
                                  pw.Text(
                                    feedBackDetails.values
                                        .toList()[index]
                                        .toString(),
                                    textAlign: pw.TextAlign.center,
                                    style: pw.TextStyle(
                                      fontSize: 16,
                                      font: font,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Icon(pw.IconData(0xe801),
                                      color: PdfColor.fromHex('#F47738'),
                                      font: icons),
                                ],
                              ),
                              pw.Expanded(
                                child: pw.Padding(
                                  padding: const pw.EdgeInsets.only(top: 5.0),
                                  child: pw.Text(
                                      '${ApplicationLocalizations.of(context).translate('DASHBOARD_${feedBackDetails.keys.toList()[index].toString()}')}',
                                      textAlign: pw.TextAlign.center,
                                      style: pw.TextStyle(
                                          font: font, fontSize: 12)),
                                ),
                              )
                            ]),
                      )),
                ).toList(),
              )),
          pw.Padding(
              padding: pw.EdgeInsets.only(top: 10, bottom: 5),
              child: pw.Text(
                "$localizationLabel",
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColor.fromHex('#0B0C0C'),
                    font: font),
              ))
        ]));
  }

  pw.Table _buildTable(pw.Font ttf) {
    return pw.Table.fromTextArray(
        headers: headers,
        headerStyle: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold),
        cellPadding: pw.EdgeInsets.symmetric(vertical: 10),
        defaultColumnWidth: pw.FlexColumnWidth(4.0),
        cellStyle: pw.TextStyle(
          font: ttf,
          fontSize: 12,
          fontWeight: pw.FontWeight.normal,
        ),
        cellAlignment: pw.Alignment.center,
        data: tableData,
        oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromHex('#EEEEEE'))
        //headerDecoration: pw.BoxDecoration(color: PdfColor.fromRYB(0.98, 0.60, 0.01))
        );
  }
}
