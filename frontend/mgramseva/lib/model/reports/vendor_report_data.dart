class VendorReportData {
  String? tenantId;
  String? vendorName;
  String? mobileNo;
  String? typeOfExpense;
  String? billId;
  String? ownerUuid;

  VendorReportData(
      {this.tenantId,
        this.vendorName,
        this.mobileNo,
        this.typeOfExpense,
        this.billId,
        this.ownerUuid});

  VendorReportData.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenantId'];
    vendorName = json['vendor_name'];
    mobileNo = json['mobile_no'];
    typeOfExpense = json['type_of_expense'];
    billId = json['bill_id'];
    ownerUuid = json['owner_uuid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tenantId'] = this.tenantId;
    data['vendor_name'] = this.vendorName;
    data['mobile_no'] = this.mobileNo;
    data['type_of_expense'] = this.typeOfExpense;
    data['bill_id'] = this.billId;
    data['owner_uuid'] = this.ownerUuid;
    return data;
  }
}