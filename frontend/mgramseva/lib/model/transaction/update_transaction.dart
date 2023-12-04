import 'package:json_annotation/json_annotation.dart';
import 'package:mgramseva/model/transaction/transaction.dart';

part 'update_transaction.g.dart';

@JsonSerializable()
class UpdateTransactionDetails {
  @JsonKey(name: "Transaction")
  List<Transaction>? transaction;

  UpdateTransactionDetails();

  factory UpdateTransactionDetails.fromJson(Map<String, dynamic> json) =>
      _$UpdateTransactionDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateTransactionDetailsToJson(this);
}
