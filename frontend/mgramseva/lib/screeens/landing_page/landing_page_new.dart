import 'package:flutter/material.dart';
import 'package:mgramseva/screeens/landing_page/AppHeader.dart';
import 'package:mgramseva/screeens/landing_page/stateSelect.dart';

class LandingPageNew extends StatefulWidget {
  @override
  _LandingPageNewState createState() => _LandingPageNewState();
}

class _LandingPageNewState extends State<LandingPageNew> {
  bool? expanded = false;
  int selectedId = -1;
  double? card_Height = 200;
  String typedText = '';
  String? text =
      "To meet JJM objectives, ‘Nal Jal Seva’ an IT Platform for the Operation and Maintenance of Drinking Water Supply Schemes for GPs/VWSCs has been developed by DDWS. ";

  @override
  void initState() {
    //_numberFocus.addListener(_onFocusChange);
    super.initState();
  }

  /*@override
    dispose() {
      //_numberFocus.removeListener(_onFocusChange);
      super.dispose();
    }*/

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        Image.asset(
          'assets/png/bg_mgramseva.png',
          // Replace with the path to your image asset
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
        ),
        SingleChildScrollView(
          child: Column(
              children: [
                AppHeader(),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text("Jal Jeevan Mission-Nal Jal Seva",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                Text(
                  "Operation & Maintenance of rural water supply schemes",
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),

                //about us container
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    width: 380,
                    /*height: card_Height,*/
                    child: Padding(
                      padding: EdgeInsets.only(left: 5, right: 5),
                      child: Card(
                        color: Color(0xfffa7a39),
                        elevation: 4.0, // Adds a shadow to the card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 10),
                            child: Text("About us",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.only(left: 10, right: 10, top: 4),
                              child: Text(
                                text.toString(),
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white),
                              )),
                          GestureDetector(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10, top: 10, bottom: 10),
                                child: Align(
                                  child: Text(
                                      expanded == false
                                          ? "Read More >>"
                                          : "Less More <<",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                  alignment: Alignment.topLeft,
                                ),
                              ),
                              onTap: () {
                                expanded = !expanded!;
                                if (expanded == true)
                                  text =
                                      "To meet JJM objectives, ‘Nal Jal Seva’ an IT Platform for the Operation and Maintenance of Drinking Water Supply Schemes for GPs/VWSCs has been developed by DDWS. This platform aims to provide ease of record-keeping, maintain a consumer database, monitor user charge collection, and offer a common system for benchmarking VWSCs' operations. The proposed functionalities include an intuitive interface for VWSCs at the village level and dashboards for administrators at different state jurisdictional levels.";
                                else
                                  text =
                                      "To meet JJM objectives, ‘Nal Jal Seva’ an IT Platform for the Operation and Maintenance of Drinking Water Supply Schemes for GPs/VWSCs has been developed by DDWS.";

                              setState(() {});
                            })
                      ]),
                    ),
                  ),
                ),
              ),

              //list container
              StateContainerWidget(),
                Container(
                  padding: EdgeInsets.all(25),
                  child: Image(
                      width: MediaQuery.of(context).size.width>760?MediaQuery.of(context).size.width * 0.15:MediaQuery.of(context).size.width * 0.5,
                      fit: BoxFit.fill,
                      image: AssetImage('assets/png/nic-footer.png')),
                )
            ],
          ),
        ),
      ]),
    );
  }
}
