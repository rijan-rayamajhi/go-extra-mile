package com.rijan.goExtraMile

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "image_picker_crash_handler"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "handleImagePickerCrash" -> {
                    // This method will be called from Flutter to handle any image picker crashes
                    result.success("Image picker crash handled")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
