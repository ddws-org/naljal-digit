class CollectionReportData {
  String? tenantName;
  String? consumerName;
  String? connectionNo;
  String? oldConnectionNo;
  String? userId;
  String? paymentMode;
  double? paymentAmount;

  CollectionReportData(
      {this.tenantName,
        this.consumerName,
        this.connectionNo,
        this.oldConnectionNo,
        this.userId,
        this.paymentMode,
        this.paymentAmount});

  CollectionReportData.fromJson(Map<String, dynamic> json) {
    tenantName = json['tenantName'];
    consumerName = json['consumerName'];
    connectionNo = json['connectionNo'];
    oldConnectionNo = json['oldConnectionNo'];
    userId = json['userId'];
    paymentMode = json['paymentMode'];
    paymentAmount = json['paymentAmount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tenantName'] = this.tenantName;
    data['consumerName'] = this.consumerName;
    data['connectionNo'] = this.connectionNo;
    data['oldConnectionNo'] = this.oldConnectionNo;
    data['userId'] = this.userId;
    data['paymentMode'] = this.paymentMode;
    data['paymentAmount'] = this.paymentAmount;
    return data;
  }
}