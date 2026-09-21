package com.example.flutter_text_editor.datasync

import android.annotation.SuppressLint
import android.net.wifi.p2p.WifiP2pDevice
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

object DataSyncMethodChannel {
    private const val channelName = "com.wellcherish.flutter.texteditor/datasync"

    private var channel: MethodChannel? = null

    fun register(flutterEngine: FlutterEngine) {
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        )
        channel?.setMethodCallHandler { call, result ->
            when(call.method) {
                "init" -> {
                    DataSyncWifiP2pManager.init()
                    result.success(true)
                }
                "release" -> {
                    DataSyncWifiP2pManager.release()
                    result.success(true)
                }
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

    fun unregister(flutterEngine: FlutterEngine) {
        channel?.setMethodCallHandler(null)
    }

    @SuppressLint("NewApi")
    fun updateDeviceMap(deviceMap: Map<String, WifiP2pDevice>) {
        val resultMap = mutableMapOf<String, String>()

        for ((address, device) in deviceMap) {
            // 构建内层的 JSON 对象
            resultMap[address] = JSONObject().apply {
                put("deviceName", device.deviceName)
                put("deviceAddress", device.deviceAddress)
                put("deviceStatus", device.status)
                put("detailDesc", device.toString())
                put("deviceType", device.primaryDeviceType)
            }.toString()
        }
        channel?.invokeMethod("updateDeviceMap", resultMap)
    }
}