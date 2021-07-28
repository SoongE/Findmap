package com.example.share // com.example.share는 앱에 맞게 수정해줘야 함

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var sharedData: String = ""

    override fun onCreate(
            savedInstanceState: Bundle?
    ) {
        super.onCreate(savedInstanceState)
        handleIntent()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger,
                "com.example.share").setMethodCallHandler { call, result ->
            if (call.method == "getSharedData") {
                handleIntent()
                result.success(sharedData)
                sharedData = ""
            }
        }
    }


    private fun handleIntent() {
        // intent is a property of this activity
        // Only process the intent if it's a send intent and it's of type 'text'
        if (intent?.action == Intent.ACTION_SEND) {
            if (intent.type == "text/plain") {
                intent.getStringExtra(Intent.EXTRA_TEXT)?.let { intentData ->
                    sharedData = intentData
                }
            }
        }
    }
}
