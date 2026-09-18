package com.example.flutter_text_editor

import android.net.wifi.p2p.WifiP2pDeviceList
import com.example.flutter_text_editor.datasync.DataSyncMethodChannel
import com.example.flutter_text_editor.datasync.DataSyncWifiP2pManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        DataSyncWifiP2pManager.getActivity = { this }
        // 注册MethodChannel
        DataSyncMethodChannel.register(flutterEngine)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        DataSyncWifiP2pManager.getActivity = { null }
        DataSyncMethodChannel.unregister(flutterEngine)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String?>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        DataSyncWifiP2pManager.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    fun resetData() {
        /*if (fragmentList != null) {
            fragmentList.clearPeers();
        }
        if (fragmentDetails != null) {
            fragmentDetails.resetViews();
        }*/
    }

    fun replacePeerList(peerList: WifiP2pDeviceList?) {
        DataSyncWifiP2pManager.replacePeerList(peerList)
    }
}
