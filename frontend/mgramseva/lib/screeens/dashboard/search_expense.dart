import 'package:flutter/material.dart';
import 'package:mgramseva/model/common/metric.dart';
import 'package:mgramseva/providers/dashboard_provider.dart';
import 'package:mgramseva/screeens/dashboard/IndividualTab.dart';
import 'package:mgramseva/utils/constants/i18_key_constants.dart';
import 'package:mgramseva/utils/testing_keys/testing_keys.dart';

import 'package:mgramseva/utils/models.dart';
import 'package:mgramseva/widgets/list_label_text.dart';
import 'package:mgramseva/widgets/text_field_builder.dart';
import 'package:mgramseva/widgets/footer.dart';
import 'package:mgramseva/widgets/grid_view_builder.dart';
import 'package:mgramseva/widgets/tab_button.dart';
import 'package:provider/provider.dart';

class SearchExpenseDashboard extends StatefulWidget {
  final DashBoardType dashBoardType;
   SearchExpenseDashboard({Key? key, required this.dashBoardType}) : super(key: key);

  @override
  _SearchExpenseDashboardState createState() => _SearchExpenseDashboardState();
}

class _SearchExpenseDashboardState extends State<SearchExpenseDashboard> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
    super.initState();
  }

  afterViewBuild(){
    var dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    dashBoardProvider.onChangeOfMainTab(context, widget.dashBoardType);
  }

  @override
  Widget build(BuildContext context) {
    var dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    return  Column(
        children: [
          Visibility(
              visible: dashBoardProvider.selectedMonth.dateType == DateType.MONTH && dashBoardProvider.metricInformation != null,
              child: GridViewBuilder(gridList:  dashBoardProvider.metricInformation ?? <Metric>[], physics: NeverScrollableScrollPhysics())
          ),
          ListLabelText(widget.dashBoardType == DashBoardType.collections ?  i18.dashboard.SEARCH_CONSUMER_RECORDS : i18.dashboard.SEARCH_EXPENSE_BILL,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          BuildTextField(
            '',
            dashBoardProvider.searchController,
            inputBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
            ),
            prefixIcon: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.search_sharp)),
            isFilled: true,
            placeHolder: widget.dashBoardType == DashBoardType.collections ? i18.dashboard.SEARCH_NAME_CONNECTION : i18.dashboard.SEARCH_BY_BILL_OR_VENDOR,
            onChange: (val) => dashBoardProvider.onSearch(val, context),
            key: Keys.dashboard.DASHBOARD_SEARCH,
          ),
          _buildTabView(),
          Footer()
        ]
    );
  }

  Widget _buildTabView() {
    return Consumer<DashBoardProvider>(
      builder: (_, dashBoardProvider, child)
    {
      var tabList = dashBoardProvider.selectedDashboardType == DashBoardType.Expenditure ? dashBoardProvider.getExpenseTabList(context) : dashBoardProvider.getCollectionsTabList(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         SingleChildScrollView(
           scrollDirection: Axis.horizontal,
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
               children: List.generate(tabList.length, (index) => Padding(
                   key: Key(index.toString()),
                   padding: EdgeInsets.only(top: 16.0, right: 8.0, bottom: 16.0), child: TabButton(tabList[index], isSelected: dashBoardProvider.isTabSelected(index), onPressed: () => dashBoardProvider.onChangeOfChildTab(context, index))))           ),
         ),
          IndividualTab()
        ],
      );
      });
  }

}
