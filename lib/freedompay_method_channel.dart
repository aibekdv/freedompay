import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'freedompay_platform_interface.dart';

/// An implementation of [FreedompayPlatform] that uses method channels.
class MethodChannelFreedompay extends FreedompayPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('freedompay');

  @override
  Future<String?> startPayment({
    required String merchantId,
    required String secretKey,
    required double amount,
    required String description,
    required String orderId,
    bool testMode = false,
    String region = 'KG',
    String currencyCode = 'KGS',
    String title = 'Payment',
  }) async {
    final result = await methodChannel.invokeMethod<String>('startPayment', {
      'merchantId': merchantId,
      'secretKey': secretKey,
      'amount': amount,
      'description': description,
      'orderId': orderId,
      'testMode': testMode,
      'region': region,
      'currencyCode': currencyCode,
      'title': title,
    });

    return result;
  }
}
