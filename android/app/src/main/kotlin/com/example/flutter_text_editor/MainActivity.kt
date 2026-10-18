package com.example.flutter_text_editor

import android.net.wifi.p2p.WifiP2pDeviceList
import com.example.flutter_text_editor.databackup.DataBackupBasicMessageChannel
import com.example.flutter_text_editor.datasync.DataSyncMethodChannel
import com.example.flutter_text_editor.datasync.DataSyncWifiP2pManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.io.File
import android.content.Intent
import android.net.Uri
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    companion object {
        private const val REQUEST_CODE_CREATE_ZIP = 1001
    }

    private var pendingZipFile: File? = null
    private var pendingReplyCallback: ((Boolean, String) -> Unit)? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        DataSyncWifiP2pManager.getActivity = { this }
        DataBackupBasicMessageChannel.getActivity = { this }

        // 注册通道
        DataSyncMethodChannel.register(flutterEngine)
        DataBackupBasicMessageChannel.register(flutterEngine)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        // 1. 清理未完成的临时文件及回调，防止内存泄漏或残留垃圾
        pendingZipFile?.delete()
        pendingZipFile = null
        pendingReplyCallback = null

        // 2. 解除 Activity 引用与注销通道
        DataSyncWifiP2pManager.getActivity = { null }
        DataBackupBasicMessageChannel.getActivity = { null }
        DataSyncMethodChannel.unregister(flutterEngine)
        DataBackupBasicMessageChannel.unregister(flutterEngine)

        super.cleanUpFlutterEngine(flutterEngine)
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String?>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        DataSyncWifiP2pManager.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    /**
     * 3. 供 DataBackupBasicMessageChannel 单例调用的方法：拉起系统文件管理器
     */
    fun startSaveZipProcess(zipFile: File, callback: (Boolean, String) -> Unit) {
        pendingZipFile = zipFile
        pendingReplyCallback = callback

        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "application/zip"
            putExtra(Intent.EXTRA_TITLE, "backup_${System.currentTimeMillis()}.zip")
        }
        startActivityForResult(intent, REQUEST_CODE_CREATE_ZIP)
    }

    /**
     * 4. 传统回调：接收系统文件管理器返回的结果
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_CREATE_ZIP) {
            val zipFile = pendingZipFile
            val callback = pendingReplyCallback

            if (resultCode == RESULT_OK && data != null && data.data != null && zipFile != null) {
                val uri: Uri = data.data!!

                // 异步将临时 Zip 文件写入用户选定的目标 Uri
                lifecycleScope.launch(Dispatchers.IO) {
                    try {
                        contentResolver.openOutputStream(uri)?.use { outputStream ->
                            FileInputStream(zipFile).use { inputStream ->
                                inputStream.copyTo(outputStream)
                            }
                        }
                        zipFile.delete() // 成功后清理缓存临时文件
                        withContext(Dispatchers.Main) {
                            callback?.invoke(true, "保存成功")
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            callback?.invoke(false, "写入失败: ${e.message}")
                        }
                    } finally {
                        pendingZipFile = null
                        pendingReplyCallback = null
                    }
                }
            } else {
                // 用户取消或未选择目录
                zipFile?.delete()
                callback?.invoke(false, "用户取消保存")
                pendingZipFile = null
                pendingReplyCallback = null
            }
        }
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