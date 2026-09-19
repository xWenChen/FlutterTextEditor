import 'package:flutter/services.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/data_sync_wifi_p2p_device.dart';

typedef DeviceUpdateCallback = Future<bool> Function(Map<String, DataSyncWifiP2pDevice> deviceMap);

class DataSyncService {
  static const String _tag = "DataSyncService";

  static const String channelName = "com.wellcherish.flutter.texteditor/datasync";

  // 1. 定义统一的 MethodChannel（使用 static final 保证全局唯一）
  late MethodChannel _channel = MethodChannel(channelName);

  List<DeviceUpdateCallback> deviceUpdateCallbackList = List<DeviceUpdateCallback>.empty(growable: true);

  // 2. 私有构造函数，防止外部直接构造实例
  DataSyncService._internal() {
    // 监听 Android 侧发起的调用。
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'updateDeviceMap':
        // 获取 Android 传递过来的参数
          final Map<String, String> deviceMap = call.arguments as Map<String, String>;
          updateDeviceMap(deviceMap);
        default:
          throw MissingPluginException('未实现的 Dart 方法: ${call.method}');
      }
    });
  }

  // 3. 静态私有实例
  static final DataSyncService _instance = DataSyncService._internal();

  // 4. 工厂构造函数，每次调用都返回同一个实例
  factory DataSyncService() => _instance;

  /// 获取设备的具体信息。
  Future<String?> getDetails(String deviceAddress) async {
    // 传递 Map，包含不同数据类型
    Map<String, dynamic> params = {
      'deviceAddress': deviceAddress,
    };

    return await invokePlatformMethod("getDetails", params);
  }

  Future<bool> connect(String deviceAddress) async {
    // 传递 Map，包含不同数据类型
    Map<String, dynamic> params = {
      'deviceAddress': deviceAddress,
    };

    return await invokePlatformMethod("connect", params) ?? false;
  }

  Future<bool> disconnect() async {
    return await invokePlatformMethod("disconnect") ?? false;
  }

  Future<bool> updateDeviceMap(Map<String, String> rawMap) async {
    // 执行 Flutter 侧的能力（如刷新UI、弹窗、播放声音等）
    final deviceMap = rawMap.map((key, value) {
      return MapEntry(
          key,
          DataSyncWifiP2pDevice.fromJsonString(value)
      );
    });

    deviceUpdateCallbackList.forEach((callback) => callback(deviceMap));

    // 给 Android 侧返回处理结果
    return true;
  }

  /// 通用的原生方法调用封装（可扩展）
  Future<T?> invokePlatformMethod<T>(String method, [dynamic arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      ZLog.e(_tag, "", e);
      return null;
    }
  }
}