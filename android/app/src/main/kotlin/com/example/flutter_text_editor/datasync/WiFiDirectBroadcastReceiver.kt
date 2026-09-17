package com.example.flutter_text_editor.datasync

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build
import androidx.annotation.RequiresApi
import androidx.core.content.IntentCompat
import com.example.flutter_text_editor.MainActivity

/**
 * A BroadcastReceiver that notifies of important wifi p2p events.
 */
class WiFiDirectBroadcastReceiver(
    private val manager: WifiP2pManager?,
    private val channel: WifiP2pManager.Channel?,
    private val activity: MainActivity?
) : BroadcastReceiver() {

    @RequiresApi(Build.VERSION_CODES.ICE_CREAM_SANDWICH)
    override fun onReceive(context: Context?, intent: Intent?) {
        val action = intent?.action ?: return
        when (action) {
            WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION -> {
                // UI update to indicate wifi p2p status.
                val state = intent.getIntExtra(WifiP2pManager.EXTRA_WIFI_STATE, -1)
                if (state == WifiP2pManager.WIFI_P2P_STATE_ENABLED) {
                    // Wifi Direct mode is enabled
                    DataSyncWifiP2pManager.isWifiP2pEnabled = true
                } else {
                    DataSyncWifiP2pManager.isWifiP2pEnabled = false
                    activity?.resetData()
                }
            }
            WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION -> {
                // request available peers from the wifi p2p manager. This is an
                // asynchronous call and the calling activity is notified with a
                // callback on PeerListListener.onPeersAvailable()
                // 刷新设备列表。
                manager?.requestPeers(channel) {
                    activity?.replacePeerList(it)
                }
            }
            WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION -> {
                if (manager == null) {
                    return;
                }
                // 直接请求连接信息，无需关心 NetworkInfo
                // we are connected with the other device, request connection info to find group owner IP
                // call WifiP2pManager.ConnectionInfoListener.onConnectionInfoAvailable(info)
                manager.requestConnectionInfo(channel) { info ->
                    if (info.groupFormed) {
                        // ✅ 已连接：组已形成，可获取 Group Owner IP 属性
                        DataSyncWifiP2pManager.info = info
                        val groupOwnerIP = info.groupOwnerAddress.hostAddress
                        // After the group negotiation, we assign the group owner as the file
                        // server. The file server is single threaded, single connection server
                        // socket.
                        /*if (info.isGroupOwner) {
                            // todo 重新尝试传输。
                            new FileServerAsyncTask(getActivity(), mContentView.findViewById(R.id.status_text))
                            .execute();
                        }*/
                    } else {
                        // ❌ 已断开：组未形成或已解散
                        activity?.resetData()
                    }
                }
            }
            WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION -> {
                // 设备发生变化。
                val device = IntentCompat.getParcelableExtra(
                    intent,
                    WifiP2pManager.EXTRA_WIFI_P2P_DEVICE,
                    WifiP2pDevice::class.java
                )
                DataSyncWifiP2pManager.updateThisDevice(device)
            }
        }
    }
}
