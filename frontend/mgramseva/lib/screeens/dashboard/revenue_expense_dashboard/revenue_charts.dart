import 'package:flutter/material.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:mgramseva/providers/revenue_dashboard_provider.dart';
import 'package:mgramseva/utils/localization/application_localizations.dart';
import 'package:mgramseva/utils/common_widgets.dart';
import 'package:mgramseva/utils/loaders.dart';
import 'package:mgramseva/utils/models.dart';
import 'package:provider/provider.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';

import '../../../utils/date_formats.dart';
import 'custom_label_widget/custom_tooltip_label_render.dart';

class RevenueCharts extends StatefulWidget {
  final bool isFromScreenshot;
  const RevenueCharts(this.isFromScreenshot, {Key? key}) : super(key: key);

  @override
  _RevenueChartsState createState() => _RevenueChartsState();
}

class _RevenueChartsState extends State<RevenueCharts> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  LayoutBuilder(
            builder: (context, constraints) => Container(
            color: Color.fromRGBO(238, 238, 238, 1),
            child: constraints.maxWidth > 760 ?  _buildDesktopView() : _buildMobileView(),
          ),
    );
  }


  Widget _buildMobileView() {
    return _buildChartWithCardView(
      Consumer<RevenueDashboard>(
          builder : (_, revenueProvider, child) =>
              getGraphView(revenueProvider.selectedIndex)
      ),
      _buildActions()
    );
  }
  
  
  Widget _buildDesktopView(){
    var revenueProvider = Provider.of<RevenueDashboard>(context, listen: false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Stacked Graph not implemented due to Backend API response finalization is pending
        // Expanded(child: _buildChartWithCardView(_buildStackedCharts(), _buildButton(revenueProvider.getTabs(context).first))),
        // SizedBox(width: 8),
        Expanded(child: _buildChartWithCardView(_buildLineCharts(true), _buildButton(revenueProvider.getTabs(context).last))),
      ],
    );
  }

  Widget _buildChartWithCardView(Widget chart, Widget action){
    return Card(
      margin: EdgeInsets.all(0.0),
      child: Padding(
        padding: EdgeInsets.all(widget.isFromScreenshot ? 5 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: widget.isFromScreenshot ? 5 : 16),
              child: Text('${ApplicationLocalizations.of(context).translate(i18.dashboard.REVENUE_EXPENDITURE_TREND)}',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700
                ),
              ),
            ),
            action,
            chart
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Consumer<RevenueDashboard>(
      builder : (_, revenueProvider, child) {
        var tabs = revenueProvider.getTabs(context);
        return Wrap(
            spacing: 10,
            children: List.generate(tabs.length, (index) => _buildButton(tabs[index], index, revenueProvider.setSelectedTab))
        );
      },
    );
  }

  Widget _buildStackedCharts(){
    var height = 250.0;
    // var expense = [
    //   Legend('Electricity', Color.fromRGBO(19, 216, 204, 1)),
    //   Legend('Salaries', Color.fromRGBO(47, 197, 229, 1)),
    //   Legend('Operations', Color.fromRGBO(251, 192, 45, 1)),
    //   Legend('Others', Color.fromRGBO(244, 119, 56, 1)),
    // ];

    return Consumer<RevenueDashboard>(
        builder : (_, revenueProvider, child) {
          return revenueProvider.revenueDataHolder.stackLoader ? Loaders
              .circularLoader(height: height) : (revenueProvider.revenueDataHolder
              .stackedBar?.graphData == null
              ? CommonWidgets.buildEmptyMessage(i18.dashboard.NO_RECORDS_MSG, context)
              : Column(children: [
            Container(
                height: height,
                child: StackedBarChart(
                    revenueProvider.revenueDataHolder.stackedBar!.graphData!)),
            Container(
              padding: const EdgeInsets.only(top: 8),
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStackedLegends(i18.dashboard.REVENUE, revenueProvider.revenueDataHolder.revenueLabels),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: VerticalDivider(
                      color: Colors.grey, width: 2, thickness: 2,),
                  ),
                  Expanded(child: _buildStackedLegends(
                      i18.dashboard.EXPENDITURE, revenueProvider.revenueDataHolder.expenseLabels))
                ],
              ),
            )
          ]));
        }
    );
  }

  Widget _buildStackedLegends(String label, List<Legend> legends){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children : [
        Padding(
          padding: const EdgeInsets.symmetric(vertical : 8.0),
          child: Text('${ApplicationLocalizations.of(context).translate(label)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700
          ),
          ),
        ),
        Expanded(
          child: Wrap(
            direction: Axis.vertical,
            spacing: 8,
            runSpacing: 10,
            children: legends.map((e) => _buildLegend(e.label,  HexColor(e.hexColor))).toList()
          ),
        )
      ]
    );
  }


  Widget _buildLineCharts([bool isDeskTopView = false]){
    var height = 250.0;
    return Consumer<RevenueDashboard>(
      builder : (_, revenue, child) =>
      revenue.revenueDataHolder.trendLineLoader ? Loaders.circularLoader(height: height) :  (revenue.revenueDataHolder.graphData == null || revenue.revenueDataHolder.graphData!.isEmpty)
          ? CommonWidgets.buildEmptyMessage(i18.dashboard.NO_RECORDS_MSG, context)
          : Column(children : [
        LayoutBuilder(
          builder: (_, constraints) => Container(
              height: height,
            child : SimpleLineChart(revenue.revenueDataHolder.graphData!, constraints, animate: false)),
        ),
      Container(
          padding:  EdgeInsets.only(top : widget.isFromScreenshot ? 5 : 16.0),
          // height: isDeskTopView ? 90 : null,
          alignment: isDeskTopView ? Alignment.center : null,
          child: Wrap(
            spacing: 20,
            children: [
              _buildLegend(i18.dashboard.REVENUE, Color.fromRGBO(64, 106, 187, 1)),
              _buildLegend(i18.dashboard.EXPENDITURE, Color.fromRGBO(255, 0, 0, 1)),
            ],
          ),
      )
      ])
    );
  }

  Widget getGraphView(int index){
    return _buildLineCharts();
    // switch(index){
    //   case 0 :
    //    return _buildStackedCharts();
    //   case 1 :
    //     return _buildLineCharts();
    //   default :
    //     return Container();
    // }
  }

  Widget _buildLegend(String label, Color color){
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          height: 12,
          width: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle
          ),
        ),
        Text('${ApplicationLocalizations.of(context).translate(label)}',
        style: TextStyle(
          fontSize: 12,
          color: Color.fromRGBO(11, 12, 12, 1)
        ),
        )
      ],
    );
  }

  Widget _buildButton(String label, [int? index, Function(int)? callBack]){
    // var revenueProvider = Provider.of<RevenueDashboard>(context, listen: false);

    return Container(height: 10,);
    //   OutlinedButton(
    //   onPressed: () => callBack != null && index != null ? callBack(index) : (){},
    // style: OutlinedButton.styleFrom(
    // side: BorderSide(width: 1.0, color: (revenueProvider.selectedIndex == index) || index == null ? Theme.of(context).primaryColor : Color.fromRGBO(238, 238, 238, 1)),
    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.0)),
    // padding: EdgeInsets.symmetric(horizontal: 8, vertical: 9)
    // ),
    //   child: Text("${ApplicationLocalizations.of(context).translate(label)}",
    //   style: TextStyle(
    //     color: (revenueProvider.selectedIndex == index) || index == null ? Theme.of(context).primaryColor : Color.fromRGBO(80, 90, 95, 1),
    //     fontSize: 14
    //   ),
    //   ),
    // );
  }
}



class StackedBarChart extends StatelessWidget {
  final dynamic seriesList;
  final bool? animate;

  StackedBarChart(this.seriesList, {this.animate});


  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      defaultRenderer: new charts.BarRendererConfig(
        groupingType: charts.BarGroupingType.groupedStacked,
        maxBarWidthPx: 8,
          cornerStrategy: const charts.ConstCornerStrategy(30),
      ),
    );
  }
}


class SimpleLineChart extends StatelessWidget {
  final dynamic seriesList;
  final bool? animate;
  final BoxConstraints constraints;

  SimpleLineChart(this.seriesList, this.constraints, {this.animate});


  @override
  Widget build(BuildContext context) {
    var revenueDashboard = Provider.of<RevenueDashboard>(context, listen: false);
    var xAxis , pointColor;
    final customTickFormatter =
    charts.BasicNumericTickFormatterSpec((num? value) {

     var dateList =  revenueDashboard.revenueDataHolder.revenueTrendLine?.map((e) => e.month).toList() ?? [];
      var index = value?.toInt() ?? 0;
     if(index < dateList.length){
       var filteredMonth = DateFormats.getMonth(
           DateFormats.getFormattedDateToDateTime(
               DateFormats.timeStampToDate(dateList[index]))!);
           // dateList[index].toString().split('-').first;
       return ApplicationLocalizations.of(context).translate(filteredMonth);
     }else{
       return "";
     }
    });

    final customYAxisTickFormatter =
    charts.BasicNumericTickFormatterSpec((num? value) {
      ToolTipMgr.setMaxValue(value ?? 0);
      return '₹ ${value?.toInt()}';

    });

    return new charts.LineChart(seriesList,
          animate: animate,
        defaultRenderer: charts.LineRendererConfig(includePoints: true, ),
      selectionModels: [
        charts.SelectionModelConfig(
            changedListener: (charts.SelectionModel model) {
              if(model.hasAnySelection) {
                xAxis = model.selectedSeries.first
                    .measureFn(model.selectedDatum.first.index)
                    .toString();
                pointColor = model.selectedSeries.first.colorFn!(model.selectedDatum.first.index)!.hexString;
                ToolTipMgr.setTitle({
                  'xAxis': '$xAxis',
                  'pointColor': '$pointColor'
                });
              }
            }
        ),
      ],
      behaviors: [
        charts.SlidingViewport(),
        charts.PanAndZoomBehavior(),
        charts.SelectNearest(
          eventTrigger: charts.SelectionTrigger.tap,
        ),
        charts.LinePointHighlighter(
          radiusPaddingPx: 3.0,
          showVerticalFollowLine:
          charts.LinePointHighlighterFollowLineType.nearest,
          showHorizontalFollowLine: charts.LinePointHighlighterFollowLineType.nearest,
          symbolRenderer: CustomTooltipLabelRenderer(),
        ),
      ],
        domainAxis: charts.NumericAxisSpec(
          tickProviderSpec:
          charts.BasicNumericTickProviderSpec(desiredTickCount: 1),
          tickFormatterSpec: customTickFormatter,
            viewport: constraints.maxWidth > 760 ? null : ((revenueDashboard.revenueDataHolder.revenueTrendLine?.length ?? 0) > 6 ? ( charts.NumericExtents(0.0, 5.0)) : null),
          renderSpec: charts.SmallTickRendererSpec(
              minimumPaddingBetweenLabelsPx: 0,
              // Tick and Label styling here.
              labelStyle: new charts.TextStyleSpec(
              fontSize: 12, // size in Pts.
              color: charts.MaterialPalette.black),
          ),
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
        tickFormatterSpec: customYAxisTickFormatter,
        showAxisLine: true
      ),
    );
  }

}
