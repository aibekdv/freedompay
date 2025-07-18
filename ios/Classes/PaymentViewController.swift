import UIKit
import PayBoxSdk

class PaymentViewController: UIViewController, WebDelegate {

    var arguments: [String: Any] = [:]
    var onFinish: ((_ paymentId: String?, _ error: String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Настраиваем заголовок
        let title = arguments["title"] as? String ?? "Оплата"
        self.title = title

        // Кнопка назад в навигации
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )
        navigationItem.leftBarButtonItem = backButton

        // Создаём PaymentView и добавляем на экран
        let paymentView = PaymentView(frame: self.view.bounds)
        paymentView.delegate = self
        paymentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(paymentView)

        // Проверяем параметры
        guard
            let merchantIdStr = arguments["merchantId"] as? String,
            let merchantId = Int(merchantIdStr),
            let secretKey = arguments["secretKey"] as? String,
            let amountDouble = arguments["amount"] as? Double,
            let description = arguments["description"] as? String,
            let orderId = arguments["orderId"] as? String
        else {
            showErrorDialog(message: "Некорректные параметры")
            return
        }

        let amount = Float(amountDouble)
        let regionStr = (arguments["region"] as? String ?? "KG").uppercased()
        let currencyCode = arguments["currencyCode"] as? String ?? "KGS"
        let testMode = arguments["testMode"] as? Bool ?? true

        // Инициализация SDK
        let sdk = PayboxSdk.initialize(merchantId: merchantId, secretKey: secretKey)
        sdk.setPaymentView(paymentView: paymentView)
        sdk.config().testMode(enabled: testMode)
        sdk.config().setCurrencyCode(code: currencyCode)

        // Настройка региона
        let region: Region = {
            switch regionStr {
            case "RU": return .RU
            case "UZ": return .UZ
            case "KG": return .KG
            default: return .DEFAULT
            }
        }()
        sdk.config().setRegion(region: region)

        // Создаём платеж
        sdk.createPayment(amount: amount, description: description, orderId: orderId, userId: "", extraParams: [:]) { payment, error in
            DispatchQueue.main.async {
                if let payment = payment {
                    let paymentIdString = payment.paymentId.map { String($0) } ?? "unknown_id"
                    self.onFinish?(paymentIdString, nil)
                    self.dismiss(animated: true)
                } else {
                    if let error = error {
                        self.showErrorDialog(message: String(describing: error))
                    } else {
                        self.showErrorDialog(message: "Ошибка при оплате")
                    }
                }
            }
        }
    }

    // Кнопка назад в навбаре
    @objc func handleBack() {
        self.onFinish?(nil, "Отменено пользователем")
        self.dismiss(animated: true)
    }


    // Показать диалог ошибки и закрыть экран по ОК
    func showErrorDialog(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.onFinish?(nil, message)
            self.dismiss(animated: true)
        }))
        self.present(alert, animated: true)
    }

    // MARK: - WebDelegate
    func loadStarted() {}

    func loadFinished() {}
}
