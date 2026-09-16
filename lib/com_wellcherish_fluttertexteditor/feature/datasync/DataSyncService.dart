import 'package:flutter/services.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';

class DataSyncService {
  static const String _tag = "DataSyncService";

  static const String channelName = "com.wellcherish.flutter.texteditor/datasync";

  // 1. 私有构造函数，防止外部直接构造实例
  DataSyncService._internal();

  // 2. 静态私有实例
  static final DataSyncService _instance = DataSyncService._internal();

  // 3. 工厂构造函数，每次调用都返回同一个实例
  factory DataSyncService() => _instance;

  // 4. 定义统一的 MethodChannel（使用 static final 保证全局唯一）
  late MethodChannel _channel = MethodChannel(channelName);

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