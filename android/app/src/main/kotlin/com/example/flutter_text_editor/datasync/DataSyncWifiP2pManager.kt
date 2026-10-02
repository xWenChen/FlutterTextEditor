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
import androidx.work.Constraints
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.workDataOf
import com.example.flutter_text_editor.MainActivity
import com.example.flutter_text_editor.MainApplication
import io.flutter.embedding.android.FlutterActivity
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicBoolean


object DataSyncWifiP2pManager {
    const val PERMISSION_REQUEST_CODE = 1001

    private val thisDevice = DeviceInfo()
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

    var isWifiP2pEnabled = AtomicBoolean(false)

    var info: WifiP2pInfo? = null

    private var receiver: WiFiDirectBroadcastReceiver? = null

    private var destroyed = false

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
        destroyed = false
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
    @SuppressLint("NewApi", "MissingPermission")
    fun continueInit(activity: Activity): Boolean {
        if (!initP2pManager(activity)) {
            return false
        }
        if (!registerReceiver()) {
            return false
        }
        // 此处的回调不可信。设备发现后，框架层会发送 WIFI_P2P_PEERS_CHANGED_ACTION 广播。
        // 1、注意：其他设备需要打开定位权限。
        // 2、打开另一台手机的：设置 -> Wi-Fi -> 高级设置/更多设置 -> Wi-Fi 直连 (Wi-Fi Direct)，停留在该页面。
        wifiP2pManager?.discoverPeers(wifiP2pChannel, object : WifiP2pManager.ActionListener {
            override fun onFailure(reason: Int) {
                val result = false
            }

            override fun onSuccess() {
                val result = false
            }
        })
        return true
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
        destroyed = true
        thisDevice.reset()
    }

    @AccessedByFlutter
    fun getDetails(deviceAddress: String?): String {
        deviceAddress ?: return ""
        val device = deviceMap[deviceAddress] ?: return ""
        return device.toString()
    }

    @SuppressLint("NewApi", "MissingPermission")
    @AccessedByFlutter
    fun connect(deviceAddress: String?, onResult: (Boolean) -> Unit) {
        deviceAddress ?: return onResult(false)

        val manager = wifiP2pManager ?: return onResult(false)
        val channel = wifiP2pChannel ?: return onResult(false)

        val config = WifiP2pConfig()
        config.deviceAddress = deviceAddress
        config.wps.setup = WpsInfo.PBC

        thisDevice.connectStatus = DeviceStatus.Connecting
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

    /**
     * removeGroup会销毁整个组，影响其他设备的连接。单个设备的断开，需要在Socket层面实现。
     * */
    @SuppressLint("NewApi")
    @AccessedByFlutter
    fun disconnectAll(onResult: (Boolean) -> Unit) {
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
        if (destroyed) {
            return
        }
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
                unregisterReceiver()
                receiver = it
                activity.registerReceiver(it, intentFilter)
            }
            true
        } ?: false
    }

    private fun unregisterReceiver(): Boolean {
        receiver?.let {
            getActivity()?.unregisterReceiver(it) ?: return false
        } ?: return false
        receiver = null
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
        thisDevice.device = device
    }

    @SuppressLint("NewApi")
    fun updateThisDeviceStatus(status: DeviceStatus) {
        thisDevice.connectStatus = status
    }

    /**
     * 启动数据传输 Worker
     *
     * @param context 上下文
     * @param useServerSocket 是否使用 ServerSocket（true: GO 设备，false: GC 设备）
     * @param needSendData 是否发送数据（true: 发送端/旧机，false: 接收端/新机）
     * @param filePath 发送时为源目录/文件路径，接收时为目标保存目录路径
     * @param serverIp 目标 Server IP（GC 模式下必填，通常为 "192.168.49.1"；GO 模式下可省略）
     * @param port Socket 监听/连接端口
     */
    fun startTransferWork(
        useServerSocket: Boolean,
        needSendData: Boolean,
        filePath: String,
        serverIp: String = DataTransferWorker.DEFAULT_GO_IP,
        port: Int = DataTransferWorker.DEFAULT_PORT
    ) {
        val context = getActivity() ?: return

        // 1. 构建传递给 Worker 的 inputData 参数
        val inputData = workDataOf(
            DataTransferWorker.PARAM_USE_SERVER_SOCKET to useServerSocket,
            DataTransferWorker.PARAM_NEED_SEND_DATA to needSendData,
            DataTransferWorker.PARAM_FILE_PATH to filePath,
            DataTransferWorker.PARAM_SERVER_IP to serverIp,
            DataTransferWorker.PARAM_PORT to port
        )

        // 2. 约束条件（要求设备当前网络处于连接状态，Wi-Fi P2P 组网完成后自动满足）
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        // 3. 构建 OneTimeWorkRequest
        val transferRequest = OneTimeWorkRequestBuilder<DataTransferWorker>()
            .setInputData(inputData)
            .setConstraints(constraints)
            .build()

        // 4. 提交给 WorkManager 执行
        WorkManager.getInstance(context).enqueue(transferRequest)
    }
}