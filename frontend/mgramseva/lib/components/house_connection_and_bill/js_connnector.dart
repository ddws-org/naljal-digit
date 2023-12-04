@JS()
library jsconnector;

import 'dart:typed_data';

import 'package:js/js.dart';

@JS('onButtonClick')
external void onButtonClick(Uint8List value, String logo);

@JS('onCollectPayment')
external void onCollectPayment(
    String txURL,
    String checksum,
    String messageType,
    String merchantId,
    String serviceId,
    String orderId,
    String customerId,
    String transactionAmount,
    String currencyCode,
    String requestDateTime,
    String successUrl,
    String failUrl,
    String additionalField1,
    String additionalField2,
    String additionalField3,
    String additionalField4,
    String additionalField5);
