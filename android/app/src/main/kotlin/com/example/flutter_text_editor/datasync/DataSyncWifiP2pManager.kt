package com.example.flutter_text_editor.datasync

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.content.Context
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.wifi.WifiManager
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pDeviceList
import android.net.wifi.p2p.WifiP2pInfo
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build
import android.os.Looper
import androidx.core.app.ActivityCompat
import com.example.flutter_text_editor.MainActivity
import com.example.flutter_text_editor.MainApplication
import io.flutter.embedding.android.FlutterActivity
import org.json.JSONObject
import java.util.concurrent.ConcurrentHashMap


object DataSyncWifiP2pManager {
    const val PERMISSION_REQUEST_CODE = 1001

    // 维护的设备列表。device.deviceAddress -> WifiP2pDevice
    private val deviceMap = ConcurrentHashMap<String, WifiP2pDevice>()
    private var wifiP2pManager: WifiP2pManager? = null
    private var wifiP2pChannel: WifiP2pManager.Channel? = null

    var getActivity: (() -> MainActivity?) = { null }

    // 1. 获取当前系统版本下所需的 Wi-Fi P2P 权限列表
    private val requiredPermission: String = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        // Android 13+ 需要 NEARBY_WIFI_DEVICES
        // 在 AndroidManifest.xml 中配置了 neverForLocation 标志，Android 13+ 在进行 Wi-Fi P2P 搜索和连接时确实不需要 ACCESS_FINE_LOCATION 权限。
        Manifest.permission.NEARBY_WIFI_DEVICES
    } else {
        // Android 12 及以下版本需要 ACCESS_FINE_LOCATION
        Manifest.permission.ACCESS_FINE_LOCATION
    }

    var isWifiP2pEnabled = false
    var info: WifiP2pInfo? = null

    private var receiver: WiFiDirectBroadcastReceiver? = null

        /**
     * 1. 检查权限。
     * 2. 初始化实例。
     * 3. 注册广播接收器。
     *
     * 代码执行流程：
     *
     * 1、权限OK：init -> checkPermission -> ok -> continueInit。
     *
     * 2、权限不OK：init -> checkPermission -> requestPermissions -> onRequestPermissionsResult -> continueInit。
     * */
    @AccessedByFlutter
    fun init() {
        val activity = getActivity() ?: return
        if (!checkPermission(activity)) {
            // 等待授权。
            return
        }
        continueInit(activity)
    }

    /**
     * 2. 初始化实例。
     * 3. 注册广播接收器。
     * */
    fun continueInit(activity: Activity): Boolean {
        if (!initP2pManager(activity)) {
            return false
        }
        return registerReceiver()
    }

    @SuppressLint("NewApi", "WifiManagerLeak")
    private fun initP2pManager(activity: Activity): Boolean {

        // Device capability definition check
        if (!activity.packageManager.hasSystemFeature(PackageManager.FEATURE_WIFI_DIRECT)) {
            return false
        }
        // Hardware capability check
        val wifiManager = activity.getSystemService(Context.WIFI_SERVICE) as? WifiManager
                ?: return false
        if (!wifiManager.isP2pSupported) {
            return false
        }
        wifiP2pManager =
            MainApplication.appContext.getSystemService(Context.WIFI_P2P_SERVICE) as? WifiP2pManager
                ?: return false
        wifiP2pChannel = wifiP2pManager?.initialize(activity, Looper.getMainLooper(), null)
            ?: return false

        return true
    }

    @AccessedByFlutter
    fun release() {
        wifiP2pManager = null
        wifiP2pChannel = null
        deviceMap.clear()
        unregisterReceiver()
    }

    @AccessedByFlutter
    fun getDetails(deviceAddress: String?): String {
        deviceAddress ?: return ""
        val device = deviceMap[deviceAddress] ?: return ""
        return device.toString()
    }

    @SuppressLint("NewApi")
    @AccessedByFlutter
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
    @AccessedByFlutter
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

    private fun checkPermission(activity: FlutterActivity): Boolean {
        // 2. 注册权限请求回调 (ActivityResult Launcher)
        val result = ActivityCompat.checkSelfPermission(activity, requiredPermission)
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true
        }
        ActivityCompat.requestPermissions(activity, arrayOf(requiredPermission), PERMISSION_REQUEST_CODE)
        return false
    }

    fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String?>, grantResults: IntArray) {
        if (requestCode != PERMISSION_REQUEST_CODE) {
            return
        }
        if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            // 用户同意了权限
            getActivity()?.let { continueInit(it) }
        } else {
            // 用户拒绝了权限
        }
    }

    @SuppressLint("NewApi")
    private fun registerReceiver(): Boolean {
        val intentFilter = IntentFilter().apply {
            addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
            addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
        }
        return getActivity()?.let { activity ->
            WiFiDirectBroadcastReceiver(wifiP2pManager, wifiP2pChannel, activity).let {
                receiver = it
                activity.registerReceiver(receiver, intentFilter)
            }
            true
        } ?: false
    }

    private fun unregisterReceiver(): Boolean {
        getActivity()?.unregisterReceiver(receiver)
        return true
    }

    @SuppressLint("NewApi")
    fun replacePeerList(peerList: WifiP2pDeviceList?) {
        peerList?.deviceList?.let { deviceList ->
            deviceMap.clear()
            deviceList.forEach { device ->
                deviceMap[device.deviceAddress] = device
            }
        }

        DataSyncMethodChannel.updateDeviceMap(deviceMap)
    }

    @SuppressLint("NewApi")
    fun updateThisDevice(device: WifiP2pDevice?) {
        device ?: return
        deviceMap[device.deviceAddress] = device
        DataSyncMethodChannel.updateDeviceMap(deviceMap)
    }

    @SuppressLint("NewApi")
    fun WifiP2pDevice?.deviceStatusDesc(): String {
        this ?: return "deviceNull"
        return when (status) {
            WifiP2pDevice.AVAILABLE -> "Available"
            WifiP2pDevice.INVITED -> "Invited"
            WifiP2pDevice.CONNECTED -> "Connected"
            WifiP2pDevice.FAILED -> "Failed"
            WifiP2pDevice.UNAVAILABLE -> "Unavailable"
            else -> "Unknown"
        }
    }
}