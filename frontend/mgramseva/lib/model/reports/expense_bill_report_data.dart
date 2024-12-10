class ExpenseBillReportData {
  String? typeOfExpense;
  String? vendorName;
  int? amount;
  int? billDate;
  int? taxPeriodFrom;
  int? taxPeriodTo;
  String? applicationStatus;
  int? paidDate;
  String? filestoreid;
  int? lastModifiedTime;
  String? lastModifiedByUuid;
  String? lastModifiedBy;
  String? tenantId;

  ExpenseBillReportData(
      {this.typeOfExpense,
        this.vendorName,
        this.amount,
        this.billDate,
        this.taxPeriodFrom,
        this.taxPeriodTo,
        this.applicationStatus,
        this.paidDate,
        this.filestoreid,
        this.lastModifiedTime,
        this.lastModifiedByUuid,
        this.lastModifiedBy,
        this.tenantId});

  ExpenseBillReportData.fromJson(Map<String, dynamic> json) {
    typeOfExpense = json['typeOfExpense'];
    vendorName = json['vendorName'];
    amount = json['amount'];
    billDate = json['billDate'];
    taxPeriodFrom = json['taxPeriodFrom'];
    taxPeriodTo = json['taxPeriodTo'];
    applicationStatus = json['applicationStatus'];
    paidDate = json['paidDate']??0;
    filestoreid = json['filestoreid'];
    lastModifiedTime = json['lastModifiedTime']??0;
    lastModifiedByUuid = json['lastModifiedByUuid'];
    lastModifiedBy = json['lastModifiedBy']??'-';
    tenantId = json['tenantId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typeOfExpense'] = this.typeOfExpense;
    data['vendorName'] = this.vendorName;
    data['amount'] = this.amount;
    data['billDate'] = this.billDate;
    data['taxPeriodFrom'] = this.taxPeriodFrom;
    data['taxPeriodTo'] = this.taxPeriodTo;
    data['applicationStatus'] = this.applicationStatus;
    data['paidDate'] = this.paidDate;
    data['filestoreid'] = this.filestoreid;
    data['lastModifiedTime'] = this.lastModifiedTime;
    data['lastModifiedByUuid'] = this.lastModifiedByUuid;
    data['lastModifiedBy'] = this.lastModifiedBy;
    data['tenantId'] = this.tenantId;
    return data;
  }
}