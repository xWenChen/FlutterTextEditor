package com.example.flutter_text_editor.datasync

import android.annotation.SuppressLint
import android.net.wifi.p2p.WifiP2pDevice
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

object DataSyncMethodChannel {
    private const val channelName = "com.wellcherish.flutter.texteditor/datasync"

    private var channel: MethodChannel? = null

    fun register(flutterEngine: FlutterEngine) {
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        )
        channel?.setMethodCallHandler { call, result ->
            when(call.method) {
                "init" -> {
                    DataSyncWifiP2pManager.init()
                    result.success(true)
                }
                "release" -> {
                    DataSyncWifiP2pManager.release()
                    result.success(true)
                }
                "getDetails" -> {
                    val deviceAddress = call.argument<String>("deviceAddress")
                    val detail = DataSyncWifiP2pManager.getDetails(deviceAddress)
                    if (detail.isEmpty()) {
                        result.error("-1", "empty device Address", null)
                    } else {
                        result.success(detail)
                    }
                }
                "connect" -> {
                    val deviceAddress = call.argument<String>("deviceAddress")
                    DataSyncWifiP2pManager.connect(deviceAddress) { success ->
                        if (success) {
                            result.success(true)
                        } else {
                            result.error("-1", "connect error", null)
                        }
                    }
                }
                "disconnect" -> {
                    DataSyncWifiP2pManager.disconnect { success ->
                        if (success) {
                            result.success(true)
                        } else {
                            result.error("-1", "disconnect error", null)
                        }
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    fun unregister(flutterEngine: FlutterEngine) {
        channel?.setMethodCallHandler(null)
    }

    @SuppressLint("NewApi")
    fun updateDeviceMap(deviceMap: Map<String, WifiP2pDevice>) {
        val resultMap = mutableMapOf<String, Any>()

        for ((address, device) in deviceMap) {
            // 构建内层的 JSON 对象
            resultMap[address] = JSONObject().apply {
                // 1. 公开字段 (Standard Public APIs)
                put("deviceName", device.deviceName.orEmpty())
                put("deviceAddress", device.deviceAddress.orEmpty())
                put("primaryDeviceType", device.primaryDeviceType.orEmpty())
                put("secondaryDeviceType", device.secondaryDeviceType.orEmpty())
                put("deviceStatus", device.status)
                put("ipAddress", device.ipAddress?.toString().orEmpty())
                // wfdInfo (Wi-Fi Display 信息)
                put("wfdInfo", device.wfdInfo?.toString().orEmpty())

                // ------------通过方法获取到的信息。-------------
                put("isGroupOwner", device.isGroupOwner)
                putWpsInfo(device)
                put("vendorElements", device.vendorElements.toString())
            }.toString()
        }
        channel?.invokeMethod("updateDeviceMap", resultMap)
    }

    @SuppressLint("NewApi")
    private fun JSONObject.putWpsInfo(device: WifiP2pDevice) {
        // 检查该 P2P 对等设备是否支持“屏幕显示 PIN 码（Display PIN）”这种 WPS 配对连接模式。
        put("wpsDisplaySupported", device.wpsDisplaySupported())
        // 检查目标对等设备是否支持通过“键盘/输入框（Keypad）”输入 PIN 码来进行 WPS（Wi-Fi 保护设置）配对连接。
        put("wpsKeypadSupported", device.wpsKeypadSupported())
        // 检查目标对等设备是否支持“PBC（Push Button Configuration，按键一键连接）”这种 WPS 配对模式。
        put("wpsPbcSupported", device.wpsPbcSupported())
        /**
         * 检查当前设备是否支持“机会性引导配对（Opportunistic Bootstrapping）”模式。
         *
         * **机会性模式（Opportunistic Mode）：**
         * 一种无需用户交互（无须手动输入 PIN 码或扫描二维码）的自动化 Wi-Fi Direct R2/R3 配对机制。
         * 设备间会在无线信道中基于密码学协议自动建立密钥协商。
         *
         * **常用场景：**
         * - 自动化/静默极速连接（如物联网设备、近场静默互传）。
         * - 在建立连接前进行能力校验，若返回 `false` 则回退到 PIN 码或 QR 码扫码交互。
         *
         * @return `true` 表示支持无感/静默引导配对，`false` 表示不支持或需要显式交互。
         */
        put(
            "isOpportunisticBootstrappingMethodSupported",
            device.isOpportunisticBootstrappingMethodSupported
        )
        /**
         * 检查当前设备是否支持“密码显示（Passphrase Display）”引导配对模式。
         *
         * **密码显示模式（Passphrase Display Mode）：**
         * 一种 Wi-Fi Direct R2/R3 配对引导机制。发起连接时，本端或对端设备会在屏幕上
         * 动态显示一串纯文本密码（Passphrase / Passcode），需要用户在另一端设备上手动输入该密码以完成身份校验。
         *
         * **与传统 WPS Display 的区别：**
         * - WPS Display：通常显示的是 8 位数字 PIN 码（基于 WPS 协议）。
         * - Passphrase Display：属于新一代 Wi-Fi Direct 配对协议，生成的密码具备更高的密码学安全性（如支持字母+数字组合），专门用于 R2/R3 框架下的安全握手。
         *
         * **典型应用场景：**
         * - 在连接前进行能力协商：若返回 `true`，App 可触发“显示密码弹窗”并指导用户在对端设备输入。
         * - 结合 [isPassphraseKeypadBootstrappingMethodSupported] 使用，判断对端是负责“显示密码”还是“输入密码”。
         *
         * @return `true` 表示设备具备在屏幕上展示配对密码的能力，`false` 表示不支持。
         */
        put(
            "isPassphraseDisplayBootstrappingMethodSupported",
            device.isPassphraseDisplayBootstrappingMethodSupported
        )
        /**
         * 检查当前设备是否支持“密码键盘输入（Passphrase Keypad）”引导配对模式。
         *
         * **密码键盘输入模式（Passphrase Keypad Mode）：**
         * 一种 Wi-Fi Direct R2/R3 配对引导机制。发起连接时，本端设备会弹出一个密码输入框或键盘，
         * 提示用户手动输入在对端设备（如电视、打印机或另一台手机）屏幕上显示的连接密码（Passphrase）。
         *
         * **与 Passphrase Display 的协作：**
         * - [isPassphraseDisplayBootstrappingMethodSupported]：表示设备负责**“显示”**密码。
         * - [isPassphraseKeypadBootstrappingMethodSupported]：表示设备负责**“输入”**密码。
         *
         * **典型应用场景：**
         * - 交互选择：发起连接前调用此方法，若返回 `true`，App 可以引导用户：“请在当前设备上输入对端显示的密码”。
         * - 安全鉴权：相比于无感连接（Opportunistic），此方式通过人工二次确认，可有效防止中间人攻击（MITM）。
         *
         * @return `true` 表示设备具备弹框/提供界面供用户输入密码的能力，`false` 表示不支持。
         */
        put(
            "isPassphraseKeypadBootstrappingMethodSupported",
            device.isPassphraseKeypadBootstrappingMethodSupported
        )
        /**
         * 检查当前设备是否支持“PIN 码显示（PIN Code Display）”引导配对模式。
         *
         * **PIN 码显示模式（PIN Code Display Mode）：**
         * 一种 Wi-Fi Direct R2/R3 配对引导机制。发起连接时，本端或对端设备会在屏幕上
         * 动态显示一串纯数字 PIN 码（如 `87654321`），提示用户在另一端设备（Keypad 端）上手动输入该数字以完成身份校验。
         *
         * **与 Passphrase Display 的区别：**
         * - PIN Code Display：生成的验证码为**纯数字**（通常为 4 位或 8 位数字），适用于简易 UI 或带有数字键盘的设备。
         * - Passphrase Display：生成的密码通常为**字母+数字组合**的复杂字符串，安全强度更高。
         *
         * **与传统 WPS Display 的区别：**
         * 属于新一代 Wi-Fi Direct R2/R3 框架下的 Bootstrapping 引导协商 API，相比传统 WPS 协议具备更完善的安全握手逻辑。
         *
         * **典型应用场景：**
         * - 在连接前进行能力协商：若返回 `true`，App 可触发“显示 8 位数字 PIN 码”的弹窗，并提示用户在对端设备上输入。
         *
         * @return `true` 表示设备具备在屏幕上展示数字 PIN 码的能力，`false` 表示不支持。
         */
        put(
            "isPinCodeDisplayBootstrappingMethodSupported",
            device.isPinCodeDisplayBootstrappingMethodSupported
        )
        /**
         * 检查当前设备是否支持“数字 PIN 码键盘输入（PIN Code Keypad）”引导配对模式。
         *
         * **PIN 码键盘输入模式（PIN Code Keypad Mode）：**
         * 一种 Wi-Fi Direct R2/R3 配对引导机制。发起连接时，本端设备会弹出一个数字键盘或输入框，
         * 提示用户手动输入在对端设备屏幕上显示的纯数字 PIN 码（如 `12345678`）。
         *
         * **与 PinCodeDisplay 的协作：**
         * - [isPinCodeDisplayBootstrappingMethodSupported]：表示设备负责**“显示”**数字 PIN 码。
         * - [isPinCodeKeypadBootstrappingMethodSupported]：表示设备负责提供数字键盘供用户**“输入”** PIN 码。
         *
         * **与 Passphrase Keypad 的区别：**
         * - PIN Code Keypad：仅需输入**纯数字**（通常为 4 位或 8 位），界面交互更简单，适合带数字按键的设备。
         * - Passphrase Keypad：需要输入**字母+数字组合**的复杂文本密码。
         *
         * **典型应用场景：**
         * - 连接能力校验：在发起连接前判断对端是否支持输入 PIN 码。若返回 `true`，可弹出数字键盘输入框并完成身份校验。
         *
         * @return `true` 表示设备具备弹出数字键盘供用户输入 PIN 码的能力，`false` 表示不支持。
         */
        put(
            "isPinCodeKeypadBootstrappingMethodSupported",
            device.isPinCodeKeypadBootstrappingMethodSupported
        )
        /**
         * 检查当前设备是否支持 Wi-Fi Direct “服务发现（Service Discovery）”机制。
         *
         * **服务发现（Service Discovery）机制：**
         * 允许设备在**不需要建立 P2P 连接（未联网）**的前提下，通过近场无线广播向周边设备
         * 宣发或查询特定的应用服务（如 Bonjour/DNS-SD、UPnP 或自定义 App 局域网服务）。
         *
         * **典型应用场景：**
         * - 过滤对等设备：在调用 `WifiP2pManager.discoverServices()` 搜索周边特定服务前，
         *   先调用此方法，过滤掉不支持服务发现的设备，提升搜索与连接效率。
         * - 应用互传/设备发现：例如“近场文件互传 App”可利用此机制判断对方是否也安装了同款 App 并在广播服务。
         *
         * @return `true` 表示设备支持应用层服务发现，`false` 表示不支持（仅支持基础 Wi-Fi Direct 设备扫描）。
         */
        put(
            "isServiceDiscoveryCapable",
            device.isServiceDiscoveryCapable
        )
    }
}