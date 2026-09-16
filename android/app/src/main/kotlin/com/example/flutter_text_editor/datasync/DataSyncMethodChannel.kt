package com.example.flutter_text_editor.datasync

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

object DataSyncMethodChannel {
    private const val channelName = "com.wellcherish.flutter.texteditor/datasync"

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when(call.method) {
                "getDetails" -> {
                    val deviceAddress = call.argument<String>("deviceAddress")
                    val detail = DataSyncWifiP2pManager.getDetails(deviceAddress)
                    if (detail.isEmpty()) {
                        result.error("-1", "empty device Address", null)
                    } else {
                        result.success(detail)
                    }
                }
                "connect" -> {
                    val deviceAddress = call.argument<String>("deviceAddress")
                    DataSyncWifiP2pManager.connect(deviceAddress) { success ->
                        if (success) {
                            result.success(true)
                        } else {
                            result.error("-1", "connect error", null)
                        }
                    }
                }
                "disconnect" -> {
                    DataSyncWifiP2pManager.disconnect { success ->
                        if (success) {
                            result.success(true)
                        } else {
                            result.error("-1", "disconnect error", null)
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}