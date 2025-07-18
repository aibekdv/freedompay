import Flutter
import UIKit
import PayBoxSdk

/// Flutter плагин для интеграции с PayBox SDK на iOS
public class FreedompayPlugin: NSObject, FlutterPlugin {
  var paymentViewController: UIViewController?
  var resultCallback: FlutterResult?

  /// Регистрация плагина с Flutter
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "freedompay", binaryMessenger: registrar.messenger())
    let instance = FreedompayPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// Обработка вызовов методов из Flutter
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any] else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments not found", details: nil))
      return
    }

    if call.method == "startPayment" {
      startPayment(args: args, result: result)
    } else {
      result(FlutterMethodNotImplemented)
    }
  }
  
  /// Запуск процесса оплаты
  private func startPayment(args: [String: Any], result: @escaping FlutterResult) {
      // Получаем корневой контроллер для презентации
      guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
          result(FlutterError(code: "NO_ROOT", message: "RootViewController not found", details: nil))
          return
      }

      self.resultCallback = result

      // Создаем контроллер оплаты
      let paymentVC = PaymentViewController()
      paymentVC.arguments = args
      
      // Обработчик завершения оплаты
      paymentVC.onFinish = { paymentId, error in
          if let paymentId = paymentId {
              result(paymentId)
          } else {
              result(FlutterError(code: "PAYMENT_FAILED", message: error ?? "Unknown error", details: nil))
          }
      }

      // Презентация контроллера оплаты
      let navController = UINavigationController(rootViewController: paymentVC)
      navController.modalPresentationStyle = .fullScreen

      rootViewController.present(navController, animated: true, completion: nil)
  }

}
