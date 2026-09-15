package com.example.flutter_text_editor.datasync

import android.R
import android.net.wifi.p2p.WifiP2pDevice
import android.view.View
import android.widget.TextView
import java.util.concurrent.ConcurrentHashMap


object DataSyncManager {
    // 维护的设备列表。device.deviceAddress -> WifiP2pDevice
    val deviceMap = ConcurrentHashMap<String, WifiP2pDevice>()

    fun getDetails(deviceAddress: String?): String {
        deviceAddress ?: return ""
        val device = deviceMap[deviceAddress] ?: return ""
        return device.toString()
    }
}