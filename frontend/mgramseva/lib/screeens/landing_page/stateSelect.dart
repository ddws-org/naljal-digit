import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mgramseva/screeens/landing_page/appstate.dart';
import 'package:mgramseva/screeens/select_language/select_language.dart';

import 'State.dart';

class ToggleItem {
  String text;
  bool isSelected = true;
  int? selectedId;

  ToggleItem(this.text, this.isSelected, this.selectedId);

  void toggleColor() {
    isSelected = !isSelected;
  }
}

class StateContainerWidget extends StatefulWidget {
  late final Function(String, int) onUpdateText;

  ToggleItem? selectedItem;
  String typedText = '';
  int selectedId = -1;

  //will used in future
/*  var state = [
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
  ];*/
  final List<ToggleItem> items = [
    ToggleItem('KARNATAKA', false, 0),
    ToggleItem('ASSAM', false, 1),
    ToggleItem('GUJRAT', false, 2)
  ];

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    //throw UnimplementedError();
    return ItemState();
  }
}

class ItemState extends State {
  String typedText = '';
  int selectedId = -1;
  List<States>? states;

  void shuffeling() {
    for (int i = 0; i < states!.length; i++) {
      var newVar = typedText;
      typedText = typedText.toLowerCase();

      if (states!.elementAt(i).stateName.toLowerCase().contains(typedText)) {
        typedText = states!.elementAt(i).stateName;

        states?[i].stateName = states![0].stateName;
        states?[0].stateName = typedText;
        //state.shuffle();
        break;
      }
    }

    setState(() {});
  }

  fetchData() async {
    final response = await http.get(
        Uri.parse('https://mocki.io/v1/fc9f2da5-c25f-4022-9152-85a8e1bb8ef3'));

    if (response.statusCode == 200) {
      states = statesFromJson(response.body);
      setState(() {});
    } else {
      Text(
        'failed to load data',
        style: TextStyle(color: Colors.red),
      );
      throw Exception('Failed to load data');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: 370,
      height: 390,
      child: Expanded(
        child: Card(
          elevation: 4.0, // Adds a shadow to the card
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(children: [
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 5),
              child: Container(
                height: 60,
                padding: EdgeInsets.only(top: 10, bottom: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                child: TextFormField(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                      hintText: 'Search State',
                      //labelText:  _isTyping ? null : 'Search State',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      typedText = value;
                      shuffeling();
                    }),
              ),
            ),
            Column(children: [
              Container(
                width: 300,
                height: 260,
                child: ListView.builder(
                    itemCount: /*state.length*/ states?.length ?? 0,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (states?.elementAt(index).stateName == 'Karnatka')
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => NewMyAppState()));
                          else {
                            final snackBar = SnackBar(
                              content: Text('work in progress'),
                              duration: Duration(
                                  seconds: 3), // You can customize the duration
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side:
                                BorderSide(color: Color(0xff6f93ef), width: 1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Container(
                            width: 300,
                            height: 50,
                            color: Color(0xa3f8e1d5),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                states!.elementAt(index).stateName,
                                //*item.text*//*state[index],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.0,
                                    color: Colors.black,
                                    letterSpacing: 1.0),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
              )
            ]),
          ]),
        ),
      ),
    );
  }
}
