package com.example.dongastonn

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.telephony.SmsManager

class MainActivity: FlutterActivity() {
    private val CHANNEL = "send_sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "send") {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")
                sendSMS(phoneNumber, message)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun sendSMS(phoneNumber: String?, message: String?) {
        val smsManager = SmsManager.getDefault()
        smsManager.sendTextMessage(phoneNumber, null, message, null, null)
    }
}