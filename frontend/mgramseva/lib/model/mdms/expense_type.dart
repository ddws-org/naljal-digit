import 'package:json_annotation/json_annotation.dart';

part 'expense_type.g.dart';

@JsonSerializable()
class Expense {

  @JsonKey(name: "ExpenseType")
  List<ExpenseType>? expenseList;

  Expense();

  factory Expense.fromJson(Map<String, dynamic> json) =>
      _$ExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}

@JsonSerializable()
class ExpenseType {

  @JsonKey(name: "name")
  String? name;

  @JsonKey(name: "code")
  String? code;

  @JsonKey(name: "taxHeadCode")
  String? taxHeadCode;

  @JsonKey(name: "active")
  bool? isActive;

  ExpenseType();

  factory ExpenseType.fromJson(Map<String, dynamic> json) =>
      _$ExpenseTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseTypeToJson(this);
}


