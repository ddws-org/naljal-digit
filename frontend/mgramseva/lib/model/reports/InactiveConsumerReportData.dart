class InactiveConsumerReportData {
  String? tenantName;
  String? connectionNo;
  String? status;
  num? inactiveDate;
  String? inactivatedByUuid;
  String? inactivatedByName;

  InactiveConsumerReportData(this.tenantName, this.connectionNo, this.status,
      this.inactiveDate, this.inactivatedByUuid, this.inactivatedByName);

  InactiveConsumerReportData.fromJson(Map<String, dynamic> json) {
    tenantName = json['tenantName']??'';
    connectionNo = json['connectionno']??'-';
    status = json['status']??'-';
    inactiveDate = json['inactiveDate'];
    inactivatedByUuid = json['inactivatedByUuid']??'-';
    inactivatedByName = json['inactivatedByName']??'-';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tenantName'] = this.tenantName;
    data['connectionno'] = this.connectionNo;
    data['status'] = this.status;
    data['inactiveDate'] = this.inactiveDate;
    data['inactivatedByUuid'] = this.inactivatedByUuid;
    data['inactivatedByName'] = this.inactivatedByName;
    return data;
  }
}