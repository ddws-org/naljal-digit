

import '../localization/language.dart';

class PaymentType {
  dynamic responseInfo;
  MdmsRes? mdmsRes;

  PaymentType({this.responseInfo, this.mdmsRes});

  PaymentType.fromJson(Map<String, dynamic> json) {
    responseInfo = json['ResponseInfo'];
    mdmsRes =
    json['MdmsRes'] != null ? new MdmsRes.fromJson(json['MdmsRes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ResponseInfo'] = this.responseInfo;
    if (this.mdmsRes != null) {
      data['MdmsRes'] = this.mdmsRes?.toJson();
    }
    return data;
  }
}
