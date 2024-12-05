class LedgerReport {
  final List<LedgerData>? ledgerReport;
  final String? tenantName;
  final String? financialYear;
  final LeadgeResponseInfo? responseInfo;

  LedgerReport({
    this.ledgerReport,
    this.tenantName,
    this.financialYear,
    this.responseInfo,
  });

  factory LedgerReport.fromJson(Map<String, dynamic> json) {
    return LedgerReport(
      ledgerReport: (json['ledgerReport'] as List<dynamic>?)
          ?.map((e) => LedgerData.fromJson(e))
          .toList(),
      tenantName: json['tenantName'] as String?,
      financialYear: json['financialYear'] as String?,
      responseInfo: LeadgeResponseInfo.fromJson(json['responseInfo']),
    );
  }
}

class LedgerData {
  final Map<String, MonthData>? months;
  LedgerData({this.months});
  factory LedgerData.fromJson(Map<String, dynamic> json) {
    final monthData = <String, MonthData>{};
    json.forEach((key, value) {
      monthData[key] = MonthData.fromJson(value);
    });
    return LedgerData(months: monthData);
  }
}

class MonthData {
  final LeadgerDemand? demand;
  final List<LeadgerPayment>? payment;
  final num? totalPaymentInMonth;
  final num? totalBalanceLeftInMonth;

  MonthData(
      {this.demand,
      this.payment,
      this.totalPaymentInMonth,
      this.totalBalanceLeftInMonth});

  factory MonthData.fromJson(Map<String, dynamic> json) {
    return MonthData(
      demand: LeadgerDemand.fromJson(json['demand']),
      payment: (json['payment'] as List<dynamic>?)
          ?.map((e) => LeadgerPayment.fromJson(e))
          .toList(),
      totalPaymentInMonth: json['totalPaymentInMonth'] as num?,
      totalBalanceLeftInMonth: json['totalBalanceLeftInMonth'] as num?,
    );
  }
}

class LeadgerDemand {
  final String? consumerName;
  final String? connectionNo;
  final String? oldConnectionNo;
  final String? userId;
  final String? month;
  final int? demandGenerationDate;
  final String? code;
  final num? monthlyCharges;
  final num? penalty;
  final num? totalForCurrentMonth;
  final num? previousMonthBalance;
  final num? totalDues;
  final int? dueDateOfPayment;
  final int? penaltyAppliedOnDate;

  LeadgerDemand({
    this.consumerName = "",
    this.connectionNo,
    this.oldConnectionNo = "",
    this.userId = "",
    this.month,
    this.demandGenerationDate,
    this.code = "",
    this.monthlyCharges,
    this.penalty,
    this.totalForCurrentMonth,
    this.previousMonthBalance,
    this.totalDues,
    this.dueDateOfPayment,
    this.penaltyAppliedOnDate,
  });

  factory LeadgerDemand.fromJson(Map<String, dynamic> json) {
    return LeadgerDemand(
      consumerName: json['consumerName'] as String?,
      connectionNo: json['connectionNo'] as String?,
      oldConnectionNo: json['oldConnectionNo'] as String?,
      userId: json['userId'] as String?,
      month: json['month'] as String?,
      demandGenerationDate: json['demandGenerationDate'] as int?,
      code: json['code'] as String?,
      monthlyCharges: json['monthlyCharges'] as num?,
      penalty: json['penalty'] as num?,
      totalForCurrentMonth: json['totalForCurrentMonth'] as num?,
      previousMonthBalance: json['previousMonthBalance'] as num?,
      totalDues: json['totalDues'] as num?,
      dueDateOfPayment: json['dueDateOfPayment'] as int?,
      penaltyAppliedOnDate: json['penaltyAppliedOnDate'] as int?,
    );
  }
}

class LeadgerPayment {
  final dynamic paymentCollectionDate;
  final String? receiptNo;
  final num? amountPaid;
  final num? balanceLeft;

  LeadgerPayment({
    this.paymentCollectionDate,
    this.receiptNo,
    this.amountPaid,
    this.balanceLeft,
  });

  factory LeadgerPayment.fromJson(Map<String, dynamic> json) {
    return LeadgerPayment(
      paymentCollectionDate: json['paymentCollectionDate'],
      receiptNo: json['receiptNo'] as String?,
      amountPaid: json['amountPaid'] as num?,
      balanceLeft: json['balanceLeft'] as num?,
    );
  }
}

class LeadgeResponseInfo {
  final String? apiId;
  final String? ver;
  final dynamic ts;
  final String? resMsgId;
  final String? msgId;
  final String? status;

  LeadgeResponseInfo({
    this.apiId,
    this.ver,
    this.ts,
    this.resMsgId,
    this.msgId,
    this.status,
  });

  factory LeadgeResponseInfo.fromJson(Map<String, dynamic> json) {
    return LeadgeResponseInfo(
      apiId: json['apiId'] as String?,
      ver: json['ver'] as String?,
      ts: json['ts'],
      resMsgId: json['resMsgId'] as String?,
      msgId: json['msgId'] as String?,
      status: json['status'] as String?,
    );
  }
}
