package com.example.flutter_text_editor.databackup

import androidx.lifecycle.lifecycleScope
import com.example.flutter_text_editor.MainActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.StandardMessageCodec
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

object DataBackupBasicMessageChannel {
    private const val channelName = "com.wellcherish.flutter.texteditor/databackup"

    private var channel: BasicMessageChannel<Any?>? = null

    // 持有获取 MainActivity 的闭包
    var getActivity: (() -> MainActivity?) = { null }

    fun register(flutterEngine: FlutterEngine) {
        channel = BasicMessageChannel<Any?>(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
            StandardMessageCodec(),
        )
        channel?.setMessageHandler { message, reply ->
            if (message is Map<*, *>) {
                val method = message["method"]
                if (method == "dataBackup") {
                    val srcDir = message["srcDir"] as? String
                    backupData(channel, reply, srcDir)
                }
            }
        }
    }

    fun unregister(flutterEngine: FlutterEngine) {
        channel?.setMessageHandler(null)
        channel = null
    }

    private fun backupData(
        channel: BasicMessageChannel<Any?>?,
        reply: BasicMessageChannel.Reply<Any?>,
        srcPath: String?,
    ) {
        val activity = getActivity()
        if (srcPath.isNullOrBlank() || activity == null) {
            reply.reply(mapOf("code" to -1, "msg" to "路径无效或 Activity 未绑定"))
            return
        }

        val srcDir = File(srcPath)
        if (!srcDir.exists() || !srcDir.isDirectory) {
            reply.reply(mapOf("code" to -1, "msg" to "源目录不存在或不是文件夹"))
            return
        }

        // 启动协程在后台执行压缩
        activity.lifecycleScope.launch(Dispatchers.IO) {
            try {
                // 1. 在应用缓存目录下创建临时 Zip 文件
                val tempZipFile = File(activity.cacheDir, "backup_${System.currentTimeMillis()}.zip")

                // 2. 执行压缩并实时上报进度
                zipFolder(srcDir, tempZipFile) { percent ->
                    val progressData = mapOf("code" to 0, "type" to "progress", "percent" to percent)
                    activity.runOnUiThread {
                        channel?.send(progressData) { _ ->
                            // 可选：处理 Flutter 对进度消息的响应
                        }
                    }
                }

                // 3. 压缩完成后，回到主线程触发 MainActivity 的 SAF 文件保存弹窗
                withContext(Dispatchers.Main) {
                    activity.startSaveZipProcess(tempZipFile) { success, resultMsg ->
                        if (success) {
                            // 最终结果通过最开始的 reply 返回给 Flutter
                            reply.reply(mapOf("code" to 0, "msg" to resultMsg))
                        } else {
                            reply.reply(mapOf("code" to -2, "msg" to resultMsg))
                        }
                    }
                }
            } catch (e: Exception) {
                e.printStackTrace()
                withContext(Dispatchers.Main) {
                    reply.reply(mapOf("code" to -3, "msg" to e.message))
                }
            }
        }
    }

    fun zipFolder(sourceFolder: File, targetZipFile: File, onProgress: ((Int) -> Unit)? = null) {
        if (!sourceFolder.exists() || !sourceFolder.isDirectory) return

        FileOutputStream(targetZipFile).use { fos ->
            ZipOutputStream(fos).use { zos ->
                val files = getAllFiles(sourceFolder)
                val totalFiles = files.size
                var processed = 0

                for (file in files) {
                    val relativePath = sourceFolder.toURI().relativize(file.toURI()).path
                    val zipEntry = ZipEntry(relativePath)
                    zos.putNextEntry(zipEntry)

                    FileInputStream(file).use { fis ->
                        fis.copyTo(zos)
                    }
                    zos.closeEntry()

                    processed++
                    onProgress?.invoke((processed * 100 / totalFiles))
                }
            }
        }
    }

    private fun getAllFiles(folder: File): List<File> {
        val fileList = mutableListOf<File>()
        folder.listFiles()?.forEach { file ->
            if (file.isDirectory) {
                fileList.addAll(getAllFiles(file))
            } else {
                fileList.add(file)
            }
        }
        return fileList
    }
}