import 'package:flutter/material.dart';
import 'package:freedompay/freedompay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreedomPay Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _result = 'No payment done yet';

  Future<void> _startPayment() async {
    const merchantId = 'YOUR_MERCHANT_ID';
    const secretKey = 'YOUR_SECRET_KEY';
    const amount = 1.0;
    const description = 'Оплата за подписку 30 дней';
    const orderId = 'order_001';

    setState(() {
      _result = 'Starting payment...';
    });

    try {
      final transactionId = await Freedompay.startPayment(
        merchantId: merchantId,
        secretKey: secretKey,
        amount: amount,
        description: description,
        orderId: orderId,
        title: description,
      );

      setState(() {
        if (transactionId != null) {
          _result = 'Оплата успешна! Транзакция: $transactionId';
        } else {
          _result = 'Оплата отменена пользователем.';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Ошибка при оплате: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FreedomPay Example')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(child: Text(_result, style: const TextStyle(fontSize: 18))),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _startPayment,
                child: const Text('Начать оплату'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
