package kg.neosoft.freedompay

import kotlinx.coroutines.*
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.content.Intent
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.widget.Toolbar
import money.paybox.payboxsdk.PayboxSdk
import money.paybox.payboxsdk.interfaces.WebListener
import money.paybox.payboxsdk.models.Payment
import money.paybox.payboxsdk.models.Error
import money.paybox.payboxsdk.view.PaymentView
import money.paybox.payboxsdk.config.Region
import kg.neosoft.freedompay.R

import android.graphics.Color
import androidx.core.view.WindowInsetsControllerCompat

/**
 * Активность для обработки платежей через PayBox SDK
 */
class PaymentActivity : AppCompatActivity() {

    private val job = Job()
    private val scope = CoroutineScope(Dispatchers.Main + job)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_payment)

        // Настройка статус бара
        window.statusBarColor = Color.WHITE
        val windowInsetsController = WindowInsetsControllerCompat(window, window.decorView)
        windowInsetsController.isAppearanceLightStatusBars = true

        // Настройка тулбара
        val toolbar = findViewById<Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)

        val title = intent.getStringExtra("title") ?: "Payment"
        supportActionBar?.title = title
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.setDisplayShowTitleEnabled(true)

        // Обработчик кнопки "Назад"
        toolbar.setNavigationOnClickListener {
            finish()
        }

        val paymentView = findViewById<PaymentView>(R.id.paymentView)

        // Извлечение параметров платежа из Intent
        val merchantIdStr = intent.getStringExtra("merchantId") ?: "0"
        val merchantId = merchantIdStr.toIntOrNull() ?: 0
        val secretKey = intent.getStringExtra("secretKey") ?: ""
        val amount = intent.getFloatExtra("amount", 0f)
        val description = intent.getStringExtra("description") ?: ""
        val orderId = intent.getStringExtra("orderId") ?: ""

        val testMode = intent.getBooleanExtra("testMode", false)
        val regionStr = intent.getStringExtra("region") ?: "DEFAULT"
        val currencyCode = intent.getStringExtra("currencyCode") ?: "KGS"

        // Определение региона для PayBox SDK
        val region = when (regionStr.uppercase()) {
            "KG" -> Region.KG
            "RU" -> Region.RU
            "UZ" -> Region.UZ
            "DEFAULT" -> Region.DEFAULT
            else -> Region.DEFAULT
        }

        // Инициализация и настройка PayBox SDK
        scope.launch {
            val sdk = withContext(Dispatchers.IO) {
                PayboxSdk.initialize(merchantId, secretKey)
            } ?: run {
                finish()
                return@launch
            }

            // Настройка SDK
            sdk.setPaymentView(paymentView)
            sdk.config().testMode(testMode)
            sdk.config().setRegion(region)
            sdk.config().setCurrencyCode(currencyCode)

            // Настройка слушателя веб-событий
            paymentView.listener = object : WebListener {
                override fun onLoadStarted() {}
                override fun onLoadFinished() {}
            }

            // Создание и обработка платежа
            sdk.createPayment(
                amount,
                description,
                orderId,
                "", // userId
                hashMapOf()
            ) { payment: Payment?, error: Error? ->

                if (payment != null) {
                    // Успешный платеж - возвращаем результат
                    val resultIntent = Intent()
                    resultIntent.putExtra("payment_id", payment.paymentId ?: "unknown_id")
                    setResult(RESULT_OK, resultIntent)
                    finish()
                } else {
                    // Ошибка платежа - показываем диалог
                    val message = error?.toString() ?: "Unknown error"

                    runOnUiThread {
                        AlertDialog.Builder(this@PaymentActivity)
                            .setTitle("Ошибка оплаты")
                            .setMessage(message)
                            .setPositiveButton("ОК") { dialog, _ ->
                                dialog.dismiss()
                                finish()
                            }
                            .setCancelable(false)
                            .show()
                    }
                }
            }
        }
    }

    // Очистка ресурсов при уничтожении активности
    override fun onDestroy() {
        super.onDestroy()
        job.cancel()
    }
}
