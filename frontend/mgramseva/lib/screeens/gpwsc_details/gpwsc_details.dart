import 'package:flutter/material.dart';
import 'package:mgramseva/screeens/gpwsc_details/gpwsc_rate_card.dart';
import 'package:provider/provider.dart';

import '../../providers/ifix_hierarchy_provider.dart';
import '../../utils/global_variables.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/drawer_wrapper.dart';
import '../../widgets/home_back.dart';
import '../../widgets/side_bar.dart';
import '../../widgets/footer.dart';
import 'gpwsc_boundary_detail_card.dart';

class GPWSCDetails extends StatefulWidget {
  const GPWSCDetails({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _GpwscDetails();
  }
}

class _GpwscDetails extends State<GPWSCDetails>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();
  var takeScreenShot = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => afterViewBuild());
  }

  afterViewBuild() {
    var departmentProvider = Provider.of<IfixHierarchyProvider>(
        navigatorKey.currentContext!,
        listen: false);
    departmentProvider.getDepartments();
    departmentProvider.getBillingSlabs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      drawer: DrawerWrapper(
    Drawer(child: SideBar()),
      ),
      backgroundColor: Color.fromRGBO(238, 238, 238, 1),
      body: LayoutBuilder(
    builder: (context, constraints) => Container(
      alignment: Alignment.center,
      margin: constraints.maxWidth < 760
          ? null
          : EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HomeBack(),
            ],
          ),
          Container(
            color: Color.fromRGBO(238, 238, 238, 1),
            padding: EdgeInsets.only(left: 8, right: 8),
            height: constraints.maxHeight - 50,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  GPWSCBoundaryDetailCard(),
                  SizedBox(
                    height: 10,
                  ),
                  GPWSCRateCard(rateType: "Non_Metered"),
                  SizedBox(
                    height: 10,
                  ),
                  GPWSCRateCard(rateType: "Metered"),
                  Footer()
                ],
              ),
            ),
          ),
        ],
      ),
    ),
      ),
    );
  }
}
