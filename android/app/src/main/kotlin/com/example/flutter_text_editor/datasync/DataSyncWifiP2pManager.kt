package com.example.flutter_text_editor.datasync

import android.annotation.SuppressLint
import android.content.Context
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pManager
import android.os.Looper
import android.widget.Toast
import com.example.flutter_text_editor.MainApplication
import java.util.concurrent.ConcurrentHashMap


object DataSyncWifiP2pManager {
    // 维护的设备列表。device.deviceAddress -> WifiP2pDevice
    private val deviceMap = ConcurrentHashMap<String, WifiP2pDevice>()
    private var wifiP2pManager: WifiP2pManager? = null
    private var wifiP2pChannel: WifiP2pManager.Channel? = null

    @SuppressLint("NewApi", "WifiManagerLeak")
    fun init(): Boolean {
        val context = MainApplication.appContext

        // Device capability definition check
        if (!context.packageManager.hasSystemFeature(PackageManager.FEATURE_WIFI_DIRECT)) {
            return false
        }
        // Hardware capability check
        val wifiManager =
            MainApplication.appContext.getSystemService(Context.WIFI_SERVICE) as? WifiManager
                ?: return false
        if (!wifiManager.isP2pSupported) {
            return false
        }
        wifiP2pManager = MainApplication.appContext.getSystemService(Context.WIFI_P2P_SERVICE) as? WifiP2pManager
            ?: return false
        wifiP2pChannel = wifiP2pManager?.initialize(context, Looper.getMainLooper(), null)
            ?: return false

        return true
    }

    fun release() {
        wifiP2pManager = null
        wifiP2pChannel = null
    }

    fun getDetails(deviceAddress: String?): String {
        deviceAddress ?: return ""
        val device = deviceMap[deviceAddress] ?: return ""
        return device.toString()
    }

    @SuppressLint("NewApi")
    fun connect(deviceAddress: String?, onResult: (Boolean) -> Unit) {
        deviceAddress ?: return onResult(false)

        val manager = wifiP2pManager ?: return onResult(false)
        val channel = wifiP2pChannel ?: return onResult(false)

        val config = WifiP2pConfig()
        config.deviceAddress = deviceAddress
        config.wps.setup = WpsInfo.PBC

        manager.connect(channel, config, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                // WiFiDirectBroadcastReceiver will notify us. Ignore for now.
                onResult(true)
            }
            override fun onFailure(reason: Int) {
                // 连接失败。
                onResult(false)
            }
        })
    }

    @SuppressLint("NewApi")
    fun disconnect(onResult: (Boolean) -> Unit) {
        val manager = wifiP2pManager ?: return onResult(false)
        val channel = wifiP2pChannel ?: return onResult(false)

        manager.removeGroup(channel, object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                // WiFiDirectBroadcastReceiver will notify us. Ignore for now.
                onResult(true)
            }
            override fun onFailure(reason: Int) {
                // 连接失败。
                onResult(false)
            }
        });
    }
}