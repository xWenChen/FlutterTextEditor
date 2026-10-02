package com.example.flutter_text_editor.datasync

import android.annotation.SuppressLint
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.pm.ServiceInfo
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkerParameters
import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.File
import java.io.InputStream
import java.io.OutputStream
import java.net.InetSocketAddress
import java.net.ServerSocket
import java.net.Socket
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream

/**
 * Wi-Fi P2P Socket 数据传输方案 (发送端 vs 接收端)
 *
 * 本套方案使用 [androidx.work.WorkManager] 搭配 [androidx.work.ForegroundInfo] 实现后台持续传输，
 * 避免在传输大文件或长时间同步时被系统杀死，并会在通知栏显示前台服务通知告知用户。
 *
 * ### 关键代码与角色职责对比：
 *
 * | 维度 | 发送端 (Client) | 接收端 (Server) |
 * | :--- | :--- | :--- |
 * | **核心 Worker 类** | `DataTransferWorker` | `DataReceiveWorker` |
 * | **底层网络 API** | [java.net.Socket] | [java.net.ServerSocket] |
 * | **建链与阻塞点** | `Socket(ip, port)` <br> *(主动向指定 IP/端口发起 TCP 连接)* | `ServerSocket(port).accept()` <br> *(开启端口监听，阻塞等待 Client 连接)* |
 * | **数据流方向** | 从文件/内存 **读取** $\to$ **写入** `socket.getOutputStream()` | 从 `clientSocket.getInputStream()` **读取** $\to$ **写入** 本地文件 |
 * | **触发前提条件** | 已从 `requestConnectionInfo` 拿到远端 `serverIp` | 组网建立完成后（通常为 Group Owner/GO），率先启动监听 |
 *
 * ---
 *
 * ### 示例代码片段：
 *
 * #### 1. 发送端核心逻辑 (Client)
 * ```kotlin
 * class DataTransferWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
 *     override suspend fun doWork(): Result {
 *         setForeground(getForegroundInfo()) // 1. 挂载前台服务通知
 *         val serverIp = inputData.getString("SERVER_IP") ?: return Result.failure()
 *
 *         // 2. 发起连接并写入数据
 *         Socket(serverIp, 8888).use { socket ->
 *             val output = socket.getOutputStream()
 *             file.inputStream().use { input -> input.copyTo(output) }
 *         }
 *         return Result.success()
 *     }
 * }
 * ```
 *
 * #### 2. 接收端核心逻辑 (Server)
 * ```kotlin
 * class DataReceiveWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
 *     override suspend fun doWork(): Result {
 *         setForeground(getForegroundInfo()) // 1. 挂载前台服务通知
 *         val saveFile = File(inputData.getString("SAVE_PATH") ?: return Result.failure())
 *
 *         // 2. 监听端口并接收数据
 *         ServerSocket(8888).use { server ->
 *             server.soTimeout = 60_000 // 避免无限期挂起
 *             server.accept().use { client ->
 *                 val input = client.getInputStream()
 *                 saveFile.outputStream().use { output -> input.copyTo(output) }
 *             }
 *         }
 *         return Result.success()
 *     }
 * }
 * ```
 */

/**
 * 数据传输 Worker
 *
 * 维度拆分说明：
 * 1. 角色维度 ([useServerSocket]):
 *    - true  -> GO (Group Owner，开启 [ServerSocket] 监听端口)
 *    - false -> GC (Group Client，开启 [Socket] 主动连接 GO)
 *
 * 2. 业务维度 ([needSendData]):
 *    - true  -> 发送数据 (旧机，打包目录为 Zip 流发送)
 *    - false -> 接收数据 (新机，解压 Zip 流还原为目录)
 */
class DataTransferWorker(
    private val context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    // 从 inputData 中提取标志位参数（提供安全默认值）
    private val useServerSocket: Boolean
        get() = inputData.getBoolean(PARAM_USE_SERVER_SOCKET, false)

    private val needSendData: Boolean
        get() = inputData.getBoolean(PARAM_NEED_SEND_DATA, false)

    override suspend fun doWork(): Result {
        // 1. 开启前台服务，向用户展示“正在发送/接收数据”通知
        try {
            setForeground(getForegroundInfo())
        } catch (e: Exception) {
            return Result.failure()
        }

        // 2. 执行网络 Socket 传输逻辑
        return try {
            transferFile()
            Result.success()
        } catch (e: Exception) {
            e.printStackTrace()
            Result.retry() // 传输失败时支持按指数退避策略自动重试
        }
    }

    private suspend fun transferFile() {
        if (useServerSocket) {
            startServerSocket()
        } else {
            startSocket()
        }
    }

    /**
     * GO 使用 ServerSocket
     */
    private suspend fun startServerSocket() {
        val port = inputData.getInt(PARAM_PORT, DEFAULT_PORT)
        val filePath = inputData.getString(PARAM_FILE_PATH) ?: throw IllegalArgumentException("Missing PARAM_FILE_PATH")
        val targetFile = File(filePath)

        ServerSocket(port).use { serverSocket ->
            serverSocket.soTimeout = SOCKET_TIMEOUT_MS
            serverSocket.accept().use { clientSocket ->
                if (needSendData) {
                    // GO 作为发送端 (旧机)
                    clientSocket.getOutputStream().use { outputStream ->
                        sendDirectoryAsZip(outputStream, targetFile)
                    }
                } else {
                    // GO 作为接收端 (新机)
                    clientSocket.getInputStream().use { inputStream ->
                        receiveZipToDirectory(inputStream, targetFile)
                    }
                }
            }
        }
    }

    /**
     * GC 使用 Socket
     */
    private suspend fun startSocket() {
        val serverIp = inputData.getString(PARAM_SERVER_IP) ?: DEFAULT_GO_IP
        val port = inputData.getInt(PARAM_PORT, DEFAULT_PORT)
        val filePath = inputData.getString(PARAM_FILE_PATH) ?: throw IllegalArgumentException("Missing PARAM_FILE_PATH")
        val targetFile = File(filePath)

        Socket().use { socket ->
            socket.connect(InetSocketAddress(serverIp, port), SOCKET_TIMEOUT_MS) // 建联阶段的超时。
            // 2. 基础稳定性配置（防卡死与底层保活）
            socket.soTimeout = SOCKET_TIMEOUT_MS // 数据读写阶段的超市
            socket.keepAlive = true              // 开启 TCP 层保活

            if (needSendData) {
                // GC 作为发送端 (旧机)
                socket.getOutputStream().use { outputStream ->
                    sendDirectoryAsZip(outputStream, targetFile)
                }
            } else {
                // GC 作为接收端 (新机)
                socket.getInputStream().use { inputStream ->
                    receiveZipToDirectory(inputStream, targetFile)
                }
            }
        }
    }

    /**
     * 将文件/目录打包为 Zip 流发送
     */
    @SuppressLint("NewApi")
    private suspend fun sendDirectoryAsZip(outputStream: OutputStream, sourceFile: File) {
        val buffer = ByteArray(BUFFER_SIZE)
        ZipOutputStream(BufferedOutputStream(outputStream)).use { zipOut ->
            val basePath = sourceFile.toPath()

            sourceFile.walkTopDown().forEach { file ->
                val relativePath = basePath.relativize(file.toPath()).toString()
                if (relativePath.isEmpty()) return@forEach

                if (file.isDirectory) {
                    zipOut.putNextEntry(ZipEntry("$relativePath$PATH_SEPARATOR"))
                    zipOut.closeEntry()
                } else {
                    zipOut.putNextEntry(ZipEntry(relativePath))
                    file.inputStream().buffered().use { input ->
                        var bytesRead: Int
                        while (input.read(buffer).also { bytesRead = it } != -1) {
                            zipOut.write(buffer, 0, bytesRead)
                        }
                    }
                    zipOut.closeEntry()
                }
            }
            zipOut.flush()
        }
    }

    /**
     * 从接收到的 Zip 流中解压还原目录/文件
     */
    private suspend fun receiveZipToDirectory(inputStream: InputStream, targetDir: File) {
        val buffer = ByteArray(BUFFER_SIZE)
        if (!targetDir.exists()) {
            targetDir.mkdirs()
        }

        ZipInputStream(BufferedInputStream(inputStream)).use { zipIn ->
            var entry: ZipEntry? = zipIn.nextEntry

            while (entry != null) {
                val newFile = File(targetDir, entry.name)

                // 安全校验：防止 Zip Slip 漏洞
                if (!newFile.canonicalPath.startsWith(targetDir.canonicalPath)) {
                    throw SecurityException("Illegal zip entry path: ${entry.name}")
                }

                if (entry.isDirectory) {
                    newFile.mkdirs()
                } else {
                    newFile.parentFile?.mkdirs()
                    newFile.outputStream().buffered().use { fileOut ->
                        var bytesRead: Int
                        while (zipIn.read(buffer).also { bytesRead = it } != -1) {
                            fileOut.write(buffer, 0, bytesRead)
                        }
                    }
                }
                zipIn.closeEntry()
                entry = zipIn.nextEntry
            }
        }
    }

    override suspend fun getForegroundInfo(): ForegroundInfo {

        val sendData = needSendData

        val channelId = if (sendData) SEND_CHANNEL_ID else RECEIVE_CHANNEL_ID
        val channelName = if (sendData) SEND_CHANNEL_NAME else RECEIVE_CHANNEL_NAME
        val notificationId = if (sendData) SEND_NOTIFICATION_ID else RECEIVE_NOTIFICATION_ID
        val title = if (sendData) NOTIFICATION_TITLE_SEND else NOTIFICATION_TITLE_RECEIVE
        val content = if (sendData) NOTIFICATION_CONTENT_SEND else NOTIFICATION_CONTENT_RECEIVE
        val icon = if (sendData) android.R.drawable.stat_sys_upload else android.R.drawable.stat_sys_download

        createNotificationChannel(context, channelId, channelName)

        val notification = NotificationCompat.Builder(context, channelId)
            .setContentTitle(title)
            .setContentText(content)
            .setSmallIcon(icon)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ForegroundInfo(
                notificationId,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            ForegroundInfo(notificationId, notification)
        }
    }

    private fun createNotificationChannel(context: Context, id: String, name: String) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channel = NotificationChannel(
                id, name, NotificationManager.IMPORTANCE_LOW
            )
            manager.createNotificationChannel(channel)
        }
    }

    companion object {
        private const val SEND_NOTIFICATION_ID = 1001
        private const val RECEIVE_NOTIFICATION_ID = 1002
        private const val SEND_CHANNEL_ID = "send_channel"
        private const val RECEIVE_CHANNEL_ID = "receive_channel"

        private const val SEND_CHANNEL_NAME = "数据发送服务"
        private const val RECEIVE_CHANNEL_NAME = "数据接收服务"

        private const val NOTIFICATION_TITLE_SEND = "正在发送数据"
        private const val NOTIFICATION_CONTENT_SEND = "正在将数据传输至新设备，请勿关闭应用..."

        private const val NOTIFICATION_TITLE_RECEIVE = "正在接收数据"
        private const val NOTIFICATION_CONTENT_RECEIVE = "正在从旧设备接收数据，请勿关闭应用..."

        private const val PATH_SEPARATOR = "/"
        private const val BUFFER_SIZE = 32 * 1024 // 32KB Buffer
        private const val SOCKET_TIMEOUT_MS = 60_000 // 60秒建链/读取超时

        const val PARAM_USE_SERVER_SOCKET = "USE_SERVER_SOCKET"
        const val PARAM_NEED_SEND_DATA = "NEED_SEND_DATA"

        const val PARAM_SERVER_IP = "SERVER_IP"
        const val PARAM_FILE_PATH = "FILE_PATH"
        const val PARAM_PORT = "PORT"

        const val DEFAULT_PORT = 4868
        const val DEFAULT_GO_IP = "192.168.49.1"
    }
}