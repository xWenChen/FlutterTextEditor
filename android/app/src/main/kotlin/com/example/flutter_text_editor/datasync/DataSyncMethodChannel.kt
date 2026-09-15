package com.example.flutter_text_editor.datasync

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object DataSyncMethodChannel {
    const val channelName = "com.wellcherish.flutter.texteditor/datasync"

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when(call.method) {
                "getDetails" -> {
                    val deviceAddress = call.argument<String>("deviceAddress")
                    val detail = DataSyncManager.getDetails(deviceAddress)
                    if (detail.isEmpty()) {
                        result.error("-1", "empty device Address", null)
                    } else {
                        result.success(detail)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}