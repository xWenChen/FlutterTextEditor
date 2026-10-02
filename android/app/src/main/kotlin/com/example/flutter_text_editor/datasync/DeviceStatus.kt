package com.example.flutter_text_editor.datasync

import android.net.wifi.p2p.WifiP2pDevice

data class DeviceInfo(
    var device: WifiP2pDevice? = null,
    var connectStatus: DeviceStatus = DeviceStatus.Null,
) {
    fun reset() {
        device = null
        connectStatus = DeviceStatus.Null
    }
}

enum class DeviceStatus {
    Null,
    Idle,
    Connecting,
    Connected,
}