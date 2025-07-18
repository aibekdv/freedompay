# FreedomPay Flutter Plugin

Flutter плагин для интеграции с платежной системой FreedomPay (PayBox SDK). Поддерживает платежи на Android и iOS платформах.

## Возможности

- ✅ Обработка платежей через PayBox SDK
- ✅ Поддержка Android и iOS
- ✅ Тестовый и продакшн режимы
- ✅ Настройка региона (KG, RU, UZ)
- ✅ Настройка валюты
- ✅ Обработка результатов платежей
- ✅ Отмена платежей пользователем

## Установка

Добавьте в `pubspec.yaml`:

```yaml
dependencies:
  freedompay: 0.0.1
```

## Настройка

### Android

1. **Добавьте PayBox SDK в ваш проект**

Добавьте в `android/app/build.gradle` в секцию `dependencies`:

```gradle
dependencies {
    implementation 'money.paybox:paybox-android-sdk:1.0.9'
    // ...другие зависимости
}
```

2. **Настройте репозиторий**

В `android/build.gradle` (корневой файл проекта) добавьте:

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }
    }
}
```

3. **Минимальные требования**

Убедитесь что `minSdkVersion` в `android/app/build.gradle` равен 21 или выше:

```gradle
android {
    compileSdkVersion flutter.compileSdkVersion
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

4. **Разрешения**

Добавьте разрешения в `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### iOS

1. **Добавьте PayBox SDK в ваш проект**

Добавьте в `ios/Podfile`:

```ruby
platform :ios, '11.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  # Добавьте PayBox SDK
  pod 'PayBoxSdk', :git => 'https://github.com/PayBox/SDK_iOS-input-.git', :submodules => true
  
  target 'RunnerTests' do
    inherit! :search_paths
  end
end
```

После добавления выполните:

```bash
cd ios
pod install
```

2. **Настройте Info.plist**

Убедитесь что `ios/Runner/Info.plist` содержит:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

3. **Минимальная версия iOS: 11.0**

## Использование

### Базовый пример

```dart
import 'package:freedompay/freedompay.dart';

// Инициируем платеж
final transactionId = await Freedompay.startPayment(
  merchantId: 'YOUR_MERCHANT_ID',
  secretKey: 'YOUR_SECRET_KEY',
  amount: 100.0,
  description: 'Оплата за товар',
  orderId: 'order_123',
  testMode: true, // false для продакшн
);

if (transactionId != null) {
  print('Платеж успешен! ID транзакции: $transactionId');
} else {
  print('Платеж отменен пользователем');
}
```

### Полный пример с обработкой ошибок

```dart
import 'package:flutter/material.dart';
import 'package:freedompay/freedompay.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _result = 'Нет платежей';

  Future<void> _startPayment() async {
    setState(() {
      _result = 'Обработка платежа...';
    });

    try {
      final transactionId = await Freedompay.startPayment(
        merchantId: 'YOUR_MERCHANT_ID',
        secretKey: 'YOUR_SECRET_KEY',
        amount: 100.0,
        description: 'Оплата за подписку',
        orderId: 'order_${DateTime.now().millisecondsSinceEpoch}',
        testMode: true,
        region: 'KG',
        currencyCode: 'KGS',
        title: 'Оплата подписки',
      );

      setState(() {
        if (transactionId != null) {
          _result = 'Платеж успешен! ID: $transactionId';
        } else {
          _result = 'Платеж отменен пользователем';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Ошибка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('FreedomPay')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_result, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startPayment,
              child: Text('Начать платеж'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## API Справочник

### Freedompay.startPayment()

Основной метод для инициации платежа.

#### Параметры

| Параметр | Тип | Обязательный | Описание |
|----------|-----|-------------|----------|
| `merchantId` | `String` | ✅ | ID мерчанта в системе PayBox |
| `secretKey` | `String` | ✅ | Секретный ключ мерчанта |
| `amount` | `double` | ✅ | Сумма платежа |
| `description` | `String` | ✅ | Описание платежа |
| `orderId` | `String` | ✅ | Уникальный ID заказа |
| `testMode` | `bool` | ❌ | Тестовый режим (по умолчанию: `false`) |
| `region` | `String` | ❌ | Регион: 'KG', 'RU', 'UZ' (по умолчанию: 'KG') |
| `currencyCode` | `String` | ❌ | Код валюты (по умолчанию: 'KGS') |
| `title` | `String` | ❌ | Заголовок экрана оплаты (по умолчанию: 'Payment') |

#### Возвращаемое значение

- `Future<String?>` - ID транзакции при успешной оплате, `null` при отмене

#### Исключения

- `PlatformException` - При ошибках на нативной стороне
- `Exception` - При других ошибках

## Коды валют

| Регион | Код валюты | Описание |
|--------|------------|----------|
| KG | KGS | Киргизский сом |
| RU | RUB | Российский рубль |
| UZ | UZS | Узбекский сум |

## Обработка ошибок

Плагин может генерировать следующие ошибки:

- `INVALID_ARGUMENTS` - Некорректные параметры
- `PAYMENT_FAILED` - Ошибка при обработке платежа
- `NO_ROOT` - Не найден корневой контроллер (iOS)
- `CANCELLED` - Платеж отменен пользователем

## Безопасность

1. **Никогда не храните секретные ключи в коде приложения**
2. Используйте серверную интеграцию для критичных операций
3. Валидируйте результаты платежей на сервере
4. Используйте HTTPS для всех API вызовов

## Лицензия

MIT License

### Используемые SDK

Этот плагин использует следующие SDK:

- **Android**: PayBox Android SDK (https://github.com/PayBox/SDK_Android) под лицензией MIT
- **iOS**: PayBoxSdk (https://github.com/PayBox/SDK_iOS-input-) под лицензией MIT

## Поддержка

Если у вас есть вопросы или проблемы, создайте issue в GitHub репозитории.

---

Made with ❤️ by NeoSoft

