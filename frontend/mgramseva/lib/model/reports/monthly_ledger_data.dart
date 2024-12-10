class MonthReport {
  final List<MonthReportData>? monthReport;
  final String? tenantName;
  final String? monthPeriod;
  final ResponseInfo? responseInfo;

  MonthReport({
    this.monthReport,
    this.tenantName,
    this.monthPeriod,
    this.responseInfo,
  });

  factory MonthReport.fromJson(Map<String, dynamic> json) {
    return MonthReport(
      monthReport: (json['monthReport'] as List<dynamic>?)
          ?.map((e) => MonthReportData.fromJson(e))
          .toList(),
      tenantName: json['tenantName'] as String?,
      monthPeriod: json['monthPeriod'] as String?,
      responseInfo: json['responseInfo'] != null
          ? ResponseInfo.fromJson(json['responseInfo'])
          : null,
    );
  }
}

class MonthReportData {
  final String? tenantName;
  final String? connectionNo;
  final String? oldConnectionNo;
  final int? consumerCreatedOnDate;
  final String? consumerName;
  final String? userId;
  final int? demandGenerationDate;
  final double? penalty;
  final double? demandAmount;
  final double? advance;
  final double? arrears;
  final double? totalAmount;
  final double? amountPaid;
  final int? paidDate;
  final double? remainingAmount;

  MonthReportData({
    this.tenantName,
    this.connectionNo,
    this.oldConnectionNo,
    this.consumerCreatedOnDate,
    this.consumerName,
    this.userId,
    this.demandGenerationDate,
    this.penalty,
    this.demandAmount,
    this.advance,
    this.arrears,
    this.totalAmount,
    this.amountPaid,
    this.paidDate,
    this.remainingAmount,
  });

  factory MonthReportData.fromJson(Map<String, dynamic> json) {
    return MonthReportData(
      tenantName: json['tenantName'] as String?,
      connectionNo: json['connectionNo'] as String?,
      oldConnectionNo: json['oldConnectionNo'] as String?,
      consumerCreatedOnDate: json['consumerCreatedOnDate'] as int?,
      consumerName: json['consumerName'] as String?,
      userId: json['userId'] as String?,
      demandGenerationDate: json['demandGenerationDate'] as int?,
      penalty: (json['penalty'] as num?)?.toDouble(),
      demandAmount: (json['demandAmount'] as num?)?.toDouble(),
      advance: (json['advance'] as num?)?.toDouble(),
      arrears: (json['arrears'] as num?)?.toDouble(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      amountPaid: (json['amountPaid'] as num?)?.toDouble(),
      paidDate: json['paidDate'] as int?,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble(),
    );
  }
}

class ResponseInfo {
  final String apiId;
  final String ver;
  final dynamic ts;
  final String resMsgId;
  final String msgId;
  final String status;

  ResponseInfo({
    required this.apiId,
    required this.ver,
    required this.ts,
    required this.resMsgId,
    required this.msgId,
    required this.status,
  });

  factory ResponseInfo.fromJson(Map<String, dynamic> json) {
    return ResponseInfo(
      apiId: json['apiId'],
      ver: json['ver'],
      ts: json['ts'],
      resMsgId: json['resMsgId'],
      msgId: json['msgId'],
      status: json['status'],
    );
  }
}
