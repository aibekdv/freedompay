import 'freedompay_platform_interface.dart';

class Freedompay {
  static Future<String?> startPayment({
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
    return FreedompayPlatform.instance.startPayment(
      merchantId: merchantId,
      secretKey: secretKey,
      amount: amount,
      description: description,
      orderId: orderId,
      testMode: testMode,
      region: region,
      currencyCode: currencyCode,
      title: title,
    );
  }
}
