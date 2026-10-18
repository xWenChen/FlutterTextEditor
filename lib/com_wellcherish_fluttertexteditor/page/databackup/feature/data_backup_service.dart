import 'package:flutter/services.dart';

/// 定义进度回调类型
typedef BackupProgressCallback = void Function(int percent);

class DataBackupService {
  static const String _tag = "DataBackupService";

  // 必须与 Android 端的 channelName 完全一致
  static const String channelName = "com.wellcherish.flutter.texteditor/databackup";

  // 1. 定义统一的 BasicMessageChannel（使用 static final 保证全局唯一）
  final BasicMessageChannel<dynamic> _channel = const BasicMessageChannel(channelName, StandardMessageCodec());

  // 进度回调列表
  final List<BackupProgressCallback> _progressCallbackList = List<BackupProgressCallback>.empty(growable: true);

  // 2. 私有构造函数，防止外部直接构造实例
  DataBackupService._internal() {
    // 监听 Android 侧主动发来的消息（例如进度更新）
    // 注意：这里只需要一个参数 message，不要写 reply
    _channel.setMessageHandler((dynamic message) async {
      if (message is Map) {
        final String? type = message['type'] as String?;
        if (type == 'progress') {
          final int percent = message['percent'] as int? ?? 0;
          _notifyProgress(percent);
        }
      }

      // 直接 return，返回的内容会自动作为 reply 回复给 Android 侧
      return "Flutter received progress";
    });
  }

  // 3. 静态私有实例
  static final DataBackupService _instance = DataBackupService._internal();

  // 4. 工厂构造函数，每次调用都返回同一个实例
  factory DataBackupService() => _instance;

  /// 注册进度回调
  void registerProgressCallback(BackupProgressCallback? callback) {
    if (callback == null) return;
    _progressCallbackList.add(callback);
  }

  /// 注销进度回调
  void unregisterProgressCallback(BackupProgressCallback? callback) {
    if (callback == null) return;
    _progressCallbackList.remove(callback);
  }

  /// 内部通知所有进度监听者
  void _notifyProgress(int percent) {
    for (var callback in _progressCallbackList) {
      callback(percent);
    }
  }

  /// 发起数据备份任务
  /// [srcDir] 需要备份的源目录绝对路径
  /// 返回一个 Map，包含 code 和 msg (例如: {"code": 0, "msg": "保存成功"})
  Future<Map<String, dynamic>> startBackup(String srcDir) async {
    if (srcDir.isEmpty) {
      return {"code": -1, "msg": "源目录路径不能为空"};
    }

    try {
      print("$_tag: 发起备份请求, 目录: $srcDir");

      // 传递 Map 参数，并等待 Android 端的最终 reply 结果
      Map<String, dynamic> params = {
        "method": "dataBackup",
        "srcDir": srcDir,
      };

      final dynamic response = await _channel.send(params);

      if (response is Map) {
        return {
          "code": response["code"] ?? -1,
          "msg": response["msg"] ?? "未知错误",
        };
      } else {
        return {"code": -1, "msg": "返回数据格式异常"};
      }
    } catch (e) {
      print("$_tag: 备份调用异常: $e");
      return {"code": -99, "msg": "异常: $e"};
    }
  }

  /// 释放资源（如果需要重置监听）
  void release() {
    _channel.setMessageHandler(null);
    _progressCallbackList.clear();
  }
}