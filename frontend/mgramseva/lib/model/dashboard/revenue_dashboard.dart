import 'package:json_annotation/json_annotation.dart';

part 'revenue_dashboard.g.dart';

@JsonSerializable()
class Revenue {
  @JsonKey(name: "month")
  int? month;

  @JsonKey(name: "demand")
  String? demand;

  @JsonKey(name: "pendingCollection")
  String? pendingCollection;

  @JsonKey(name: "arrears")
  String? arrears;

  @JsonKey(name: "actualCollection")
  String? actualCollection;

  Revenue();

  factory Revenue.fromJson(Map<String, dynamic> json) =>
      _$RevenueFromJson(json);
}

@JsonSerializable()
class Expense {
  @JsonKey(name: "month")
  int? month;

  @JsonKey(name: "totalExpenditure")
  String? totalExpenditure;

  @JsonKey(name: "amountUnpaid")
  String? amountUnpaid;

  @JsonKey(name: "amountPaid")
  String?  amountPaid;

  Expense();

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);
}


class TotalDetails {
  num surplus;
  num demand;
  num arrears ;
  num pendingCollection;
  num actualCollection;
  num totalExpenditure;
  num amountUnpaid;
  num amountPaid;
  TotalDetails({this.surplus = 0, this.demand = 0, this.arrears = 0,
  this.pendingCollection = 0, this.actualCollection = 0, this.totalExpenditure = 0, this.amountUnpaid = 0, this.amountPaid = 0});
}
