// To parse this JSON data, do
//
//     final states = statesFromJson(jsonString);

import 'dart:convert';

List<States>  statesFromJson(String str) =>
    List<States>.from(json.decode(str).map((x) => States.fromJson(x)));

String statesToJson(List<States> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class States {
  String stateCode;
  String stateName;
  String baseUrl;

  States({
    required this.stateCode,
    required this.stateName,
    required this.baseUrl,
  });

  factory States.fromJson(Map<String, dynamic> json) => States(
        stateCode: json["state_code"],
        stateName: json["state_name"],
        baseUrl: json["base_url"],
      );

  Map<String, dynamic> toJson() => {
        "state_code": stateCode,
        "state_name": stateName,
        "base_url": baseUrl,
      };
}
