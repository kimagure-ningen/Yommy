package com.example.yommy

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.yommy/share"
    private var sharedUrl: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent) {
        when (intent.action) {
            Intent.ACTION_SEND -> {
                if (intent.type == "text/plain") {
                    intent.getStringExtra(Intent.EXTRA_TEXT)?.let { text ->
                        sharedUrl = extractUrl(text)
                    }
                }
            }
            Intent.ACTION_VIEW -> {
                intent.dataString?.let { url ->
                    sharedUrl = url
                }
            }
        }
    }

    private fun extractUrl(text: String): String? {
        // URLを抽出（テキスト全体がURLか、テキスト内のURLを検出）
        val urlPattern = Regex("https?://[\\w\\-._~:/?#\\[\\]@!$&'()*+,;=%]+")
        val match = urlPattern.find(text)
        return match?.value ?: if (text.startsWith("http")) text else null
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getSharedUrl" -> {
                        result.success(sharedUrl)
                        sharedUrl = null  // 一度取得したらクリア
                    }
                    else -> result.notImplemented()
                }
            }
    }
}