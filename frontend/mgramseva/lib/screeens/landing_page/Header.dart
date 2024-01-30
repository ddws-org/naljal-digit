import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mgramseva/screeens/landing_page/AppHeader.dart';
import 'package:mgramseva/screeens/landing_page/stateSelect.dart';

import '../../env/app_config.dart';
import '../../main.dart';
import '../../utils/constants.dart';

class HeaderAll extends State<MyApp> {
  bool? expanded = false;
  int selectedId = -1;
  double? card_Height = 200;
  bool _isTyping = false;
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

  var state = [
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
  ];

/*  final List<ToggleItem> items =
  [ToggleItem('KARNATAKA', false),ToggleItem('ASSAM', false),ToggleItem('GUJRAT', false)];
  //['KARNATAKA', 'ASSAM', 'GUJRAT', 'STATE', 'STATE'];*/

  void shuffeling() {
    for (int i = 0; i < state.length; i++) {
      var newVar = typedText;
      typedText = typedText.toLowerCase();

      if (state.elementAt(i).toLowerCase().contains(typedText)) {
        typedText = state.elementAt(i);

        state[i] = state[0];
        state[0] = typedText;
        //items.insert(i, typedText);
        //items[i].text = typedText;
        break;
      }
    }
    //items.shuffle();
    setState(() {});
  }

  void shuffleList() {
    for (int i = 0; i < state.length; i++) {
      if (state.elementAt(i).contains(typedText)) {
        typedText = state.elementAt(i);

        state[i] = state[0];
        state[0] = typedText;
        //items.insert(i, typedText);
        //items[i].text = typedText;
        break;
      }
    }

    //items.shuffle();
    setState(() {});
  }

  dynamic updateText(String newText, int selectedId) {
    this.selectedId = selectedId;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return
        /*GestureDetector( behavior: HitTestBehavior.opaque,child:*/
        MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(children: [
          Image.asset(
            'assets/png/bg_mgramseva.png',
            // Replace with the path to your image asset
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                /* Padding(
                  padding: const EdgeInsets.only(top: 35.0),
                  child: Container(
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Image.asset("assets/png/svgg.png"),
                        ),
                        Column(
                          children: [
                            Text(
                              'NAL JAL SEVA',
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Image.asset("assets/png/swach-bharat.png"),
                        ),
                      ],
                    ),
                  ),
                ),*/
                AppHeader(),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Jal Jeevan Mission-Nal Jal Seva",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                Text(
                  "Operation & Maintenance of rural water supply schemes",
                  style: TextStyle(color: Colors.black),
                ),

                //about us container
                Container(
                  width: 380,
                  /*height: card_Height,*/
                  child: Padding(
                    padding: EdgeInsets.only(left: 5, right: 5),
                    child: Card(
                      elevation: 4.0, // Adds a shadow to the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("About us",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Image.network(
                                '$apiBaseUrl${Constants.NATIONAL_EMBLEM_INDIA}',
                                height: 36,
                                width: 36,
                              )
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              text.toString(),
                              style: TextStyle(fontSize: 12),
                            )),
                        GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 10, top: 10, bottom: 10),
                              child: Align(
                                child: Text(
                                    expanded == false
                                        ? "Read More>>"
                                        : "Less More<<",
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 12)),
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

                //list container
                StateContainerWidget(),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Image.network(
                "$apiBaseUrl${Constants.NALJAL_FOOTER_ENDPOINT}",
              ),
            ),
          )
        ]),
      ),
    );
  }
}
