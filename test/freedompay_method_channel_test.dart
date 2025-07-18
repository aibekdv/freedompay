import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:freedompay/freedompay_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFreedompay platform = MethodChannelFreedompay();
  const MethodChannel channel = MethodChannel('freedompay');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'startPayment') {
          final arguments = methodCall.arguments as Map<Object?, Object?>;
          // Проверим, что все необходимые параметры переданы
          expect(arguments.containsKey('merchantId'), true);
          expect(arguments.containsKey('secretKey'), true);
          expect(arguments.containsKey('amount'), true);
          expect(arguments.containsKey('description'), true);
          expect(arguments.containsKey('orderId'), true);
          
          // Возвращаем мок результат
          return 'payment_success';
        }
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('startPayment with required parameters', () async {
    final result = await platform.startPayment(
      merchantId: 'test_merchant',
      secretKey: 'test_secret',
      amount: 100.0,
      description: 'Test payment',
      orderId: 'order_123',
    );
    
    expect(result, 'payment_success');
  });

  test('startPayment with all parameters', () async {
    final result = await platform.startPayment(
      merchantId: 'test_merchant',
      secretKey: 'test_secret',
      amount: 250.50,
      description: 'Test payment with all params',
      orderId: 'order_456',
      testMode: true,
      region: 'KZ',
      currencyCode: 'KZT',
      title: 'Custom Payment Title',
    );
    
    expect(result, 'payment_success');
  });

  test('startPayment with default parameters', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'startPayment') {
          final arguments = methodCall.arguments as Map<Object?, Object?>;
          
          // Проверим значения по умолчанию
          expect(arguments['testMode'], false);
          expect(arguments['region'], 'KG');
          expect(arguments['currencyCode'], 'KGS');
          expect(arguments['title'], 'Payment');
          
          return 'payment_success';
        }
        return '42';
      },
    );

    final result = await platform.startPayment(
      merchantId: 'test_merchant',
      secretKey: 'test_secret',
      amount: 100.0,
      description: 'Test payment',
      orderId: 'order_789',
    );
    
    expect(result, 'payment_success');
  });
}
