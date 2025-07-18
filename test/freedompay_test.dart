import 'package:flutter_test/flutter_test.dart';
import 'package:freedompay/freedompay.dart';
import 'package:freedompay/freedompay_platform_interface.dart';
import 'package:freedompay/freedompay_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFreedompayPlatform
    with MockPlatformInterfaceMixin
    implements FreedompayPlatform {
  
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
    return 'mock_payment_result';
  }
}

void main() {
  final FreedompayPlatform initialPlatform = FreedompayPlatform.instance;

  test('$MethodChannelFreedompay is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFreedompay>());
  });

  test('startPayment', () async {
    MockFreedompayPlatform fakePlatform = MockFreedompayPlatform();
    FreedompayPlatform.instance = fakePlatform;

    final result = await Freedompay.startPayment(
      merchantId: 'test_merchant',
      secretKey: 'test_secret',
      amount: 100.0,
      description: 'Test payment',
      orderId: 'order_123',
    );

    expect(result, 'mock_payment_result');
  });

  test('startPayment with all parameters', () async {
    MockFreedompayPlatform fakePlatform = MockFreedompayPlatform();
    FreedompayPlatform.instance = fakePlatform;

    final result = await Freedompay.startPayment(
      merchantId: 'test_merchant',
      secretKey: 'test_secret',
      amount: 250.50,
      description: 'Test payment with all params',
      orderId: 'order_456',
      testMode: true,
      region: 'KZ',
      currencyCode: 'KZT',
      title: 'Custom Payment',
    );

    expect(result, 'mock_payment_result');
  });

  test('startPayment with default parameters', () async {
    MockFreedompayPlatform fakePlatform = MockFreedompayPlatform();
    FreedompayPlatform.instance = fakePlatform;

    final result = await Freedompay.startPayment(
      merchantId: 'test_merchant',
      secretKey: 'test_secret',
      amount: 100.0,
      description: 'Test payment',
      orderId: 'order_789',
    );

    expect(result, 'mock_payment_result');
  });
}
