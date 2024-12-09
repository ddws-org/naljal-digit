import 'package:mgramseva/model/localization/language.dart';

class PenaltyModule {
  final dynamic responseInfo;
  final MdmsResPenalty? mdmsRes;

  PenaltyModule({this.responseInfo, this.mdmsRes});

  factory PenaltyModule.fromJson(Map<String, dynamic> json) {
    return PenaltyModule(
      responseInfo: json['ResponseInfo'],
      mdmsRes: json['MdmsRes'] != null
          ? MdmsResPenalty.fromJson(json['MdmsRes'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ResponseInfo': responseInfo,
      'MdmsRes': mdmsRes?.toJson(),
    };
  }
}

class MdmsResPenalty {
  final WsServicesCalculation wsServicesCalculation;

  MdmsResPenalty({required this.wsServicesCalculation});

  factory MdmsResPenalty.fromJson(Map<String, dynamic> json) {
    return MdmsResPenalty(
      wsServicesCalculation: WsServicesCalculation.fromJson(
          json['ws-services-calculation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ws-services-calculation': wsServicesCalculation.toJson(),
    };
  }
}

class WsServicesCalculation {
  final List<PenaltyObj> penalty;

  WsServicesCalculation({required this.penalty});

  factory WsServicesCalculation.fromJson(Map<String, dynamic> json) {
    return WsServicesCalculation(
      penalty: (json['Penalty'] as List<dynamic>)
          .map((item) => PenaltyObj.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Penalty': penalty.map((item) => item.toJson()).toList(),
    };
  }
}

class PenaltyObj {
  final double rate;
  final String type;
  final double? amount;
  final String fromFY;
  final String subType;
  final double? minAmount;
  final double? flatAmount;
  final String startingDay;
  final int applicableAfterDays;

  PenaltyObj({
    required this.rate,
    required this.type,
    this.amount,
    required this.fromFY,
    required this.subType,
    this.minAmount,
    this.flatAmount,
    required this.startingDay,
    required this.applicableAfterDays,
  });

  factory PenaltyObj.fromJson(Map<String, dynamic> json) {
    return PenaltyObj(
      rate: (json['rate'] as num).toDouble(),
      type: json['type'] as String,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      fromFY: json['fromFY'] as String,
      subType: json['subType'] as String,
      minAmount: json['minAmount'] != null
          ? (json['minAmount'] as num).toDouble()
          : null,
      flatAmount: json['flatAmount'] != null
          ? (json['flatAmount'] as num).toDouble()
          : null,
      startingDay: json['startingDay'] as String,
      applicableAfterDays: json['applicableAfterDays'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rate': rate,
      'type': type,
      'amount': amount,
      'fromFY': fromFY,
      'subType': subType,
      'minAmount': minAmount,
      'flatAmount': flatAmount,
      'startingDay': startingDay,
      'applicableAfterDays': applicableAfterDays,
    };
  }
}
