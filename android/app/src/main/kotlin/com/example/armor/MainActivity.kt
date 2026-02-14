package com.example.armor

import android.media.MediaScannerConnection
import android.net.Uri
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.example.armor/media_scanner"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scanFile" -> {
                    val path = call.argument<String>("path")
                    if (path != null) {
                        scanMediaFile(path, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is required", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun scanMediaFile(filePath: String, result: MethodChannel.Result) {
        MediaScannerConnection.scanFile(
            this,
            arrayOf(filePath),
            null
        ) { path, uri ->
            runOnUiThread {
                if (uri != null) {
                    result.success("File scanned successfully: $path")
                } else {
                    result.error("SCAN_FAILED", "Failed to scan file", null)
                }
            }
        }
    }
}
