package kg.neosoft.freedompay

import android.app.Activity
import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

/**
 * Flutter плагин для интеграции с PayBox SDK на Android
 */
class FreedompayPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null
    private var resultCallback: MethodChannel.Result? = null

    // Инициализация плагина при подключении к Flutter движку
    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "freedompay")
        channel.setMethodCallHandler(this)
    }

    // Обработка вызовов методов из Flutter
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "startPayment") {
            // Извлекаем параметры платежа
            val merchantId = call.argument<String>("merchantId") ?: ""
            val secretKey = call.argument<String>("secretKey") ?: ""
            val amount = call.argument<Double>("amount") ?: 0.0
            val description = call.argument<String>("description") ?: ""
            val orderId = call.argument<String>("orderId") ?: ""
            val testMode = call.argument<Boolean>("testMode") ?: false
            val regionStr = call.argument<String>("region") ?: "KG"
            val currencyCode = call.argument<String>("currencyCode") ?: "KGS"
            val title = call.argument<String>("title") ?: "Payment"

            resultCallback = result

            // Создаем Intent для запуска активности платежа
            val intent = Intent(activity, PaymentActivity::class.java).apply {
                putExtra("merchantId", merchantId)
                putExtra("secretKey", secretKey)
                putExtra("amount", amount.toFloat())
                putExtra("description", description)
                putExtra("orderId", orderId)
                putExtra("testMode", testMode)
                putExtra("region", regionStr)
                putExtra("currencyCode", currencyCode)
                putExtra("title", title)
            }

            // Запускаем активность платежа
            activity?.startActivityForResult(intent, 2025)
        } else {
            result.notImplemented()
        }
    }

    // Обработка результата платежа
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == 2025) {
            if (resultCode == Activity.RESULT_OK) {
                // Успешный платеж - получаем ID транзакции
                val extras = data?.extras
                val paymentIdObj = extras?.get("payment_id")
                val paymentId = when (paymentIdObj) {
                    is String -> paymentIdObj
                    is Int -> paymentIdObj.toString()
                    else -> null
                }
                if (paymentId != null) {
                    resultCallback?.success(paymentId)
                } else {
                    resultCallback?.error("PAYMENT_FAILED", "Payment ID is null or invalid type", null)
                }
            } else {
                // Ошибка или отмена платежа
                val error = data?.getStringExtra("payment_error") ?: "User cancelled"
                resultCallback?.error("PAYMENT_FAILED", error, null)
            }
            resultCallback = null
            return true
        }
        return false
    }

    // Подключение к активности
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    // Очистка при отключении от Flutter движка
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
