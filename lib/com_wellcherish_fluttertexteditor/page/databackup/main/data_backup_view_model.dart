
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/file/editor_file_utils.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';

import 'backup_operation_info.dart';

class DataBackupViewModel extends BaseViewModel {
  static final _tag = "DataBackupViewModel";

  bool canPop = true;

  // 支持的操作列表
  MutableState<List<BackupOperationInfo>> supportOperationList = MutableState(<BackupOperationInfo>[]);

  // 当前选中的操作
  MutableState<BackupOperationInfo> selectedOperation = MutableState(BackupOperationInfo());

  // 当前操作状态
  MutableState<OperationState> operationState = MutableState(OperationState.idle);

  // 操作进度 (0 ~ 100)
  MutableState<int> operationProgress = MutableState(0);

  /// 初始化 -> discoverPeers -> requestPeers。
  Future<void> init() async {
    supportOperationList.value = [
      BackupOperationInfo(
        operationType: OperationType.backup,
        title: Strings.backupData,
        desc: Strings.backupDataDesc,
      ),
      BackupOperationInfo(
        operationType: OperationType.restore,
        title: Strings.restoreData,
        desc: Strings.restoreDataDesc,
      ),
    ];
    selectedOperation.value = supportOperationList.value.first;
  }

  /// 更新进度安全方法
  void updateProgress(int newProgress) {
    int value = newProgress;
    if (value < 0) {
      value = 0;
    } else if (value > 100) {
      value = 100;
    }
    operationProgress.value = value;
  }

  /// ------------------- 核心业务：备份流程（含 Isolate + ReceivePort 实时进度） -------------------
  /// zip 的压缩放到 isolate 中。
  Future<void> syncData() async {
    updateProgress(0);
    operationState.value = OperationState.waitBackup;

    // 1. 主线程：获取 App 的文档目录
    Directory? appDocDir = await EditorFileUtils.documentDir;
    if (appDocDir == null) {
      operationState.value = OperationState.fileSystemError;
      return;
    }
    operationState.value = OperationState.inBackup;
    updateProgress(10); // 准备开始

    // 2. 创建一个接收端口（用于接收子线程发回来的进度和最终打包数据）
    final receivePort = ReceivePort();

    try {
      // 启动独立的后台 Isolate，把主线程的 sendPort 和目录路径传过去
      await Isolate.spawn(_zipIsolateEntry, [receivePort.sendPort, appDocDir.path]);

      // 3. 监听子线程持续发回的消息（包括进度数字或最终的二进制数据）
      Uint8List? zipBytes;
      await for (final message in receivePort) {
        if (message is int) {
          // 收到子线程汇报的进度 (0 ~ 100)
          // 我们将后台压缩过程映射到 UI 的 10% ~ 90% 区间
          int mappedProgress = 10 + (message * 80 ~/ 100);
          updateProgress(mappedProgress);
        } else if (message is Uint8List?) {
          // 收到子线程传回的完整 zip 字节数据，压缩完成
          zipBytes = message;
          updateProgress(90); // 压缩完成，准备保存
          break; // 退出监听循环
        } else if (message is String) {
          // 收到错误信息
          print("❌ 子线程压缩出错: $message");
          break;
        }
      }

      if (zipBytes != null) {
        // 4. 主线程：唤起系统文件管理器导出保存
        await exportZipToPublicDirectory(
          zipBytes,
          "backup_${DateTime.now().millisecondsSinceEpoch}",
        );
      } else {
        operationState.value = OperationState.fileSystemError;
      }
    } catch (e, stackTrace) {
      print("❌ Isolate 启动异常: $e");
      print(stackTrace);
      operationState.value = OperationState.fileSystemError;
    } finally {
      // 务必关闭端口，防止内存泄漏
      receivePort.close();
    }
  }

  /// 唤起系统文件管理器，将 zip 文件保存到用户指定位置（免权限）
  Future<void> exportZipToPublicDirectory(Uint8List zipBytes, String zipName) async {
    try {
      String? path = await FileSaver.instance.saveAs(
        name: zipName,
        bytes: zipBytes,
        ext: 'zip',
        mimeType: MimeType.zip,
      );

      if (path != null && path.isNotEmpty) {
        updateProgress(100);
        operationState.value = OperationState.endBackup;
      } else {
        print("用户取消了文件保存");
        operationState.value = OperationState.idle;
        updateProgress(0);
      }
    } catch (e, stackTrace) {
      print("❌ 保存导出文件失败: $e");
      updateProgress(0);
      operationState.value = OperationState.fileSystemError;
    }
  }

  /// ------------------- 核心业务：还原流程 -------------------

  Future<bool> restoreFromZip(File zipFile, Directory targetDir) async {
    try {
      if (!await zipFile.exists()) {
        return false;
      }

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      for (final file in archive) {
        final filename = file.name;
        final outputPath = '${targetDir.path}/$filename';

        if (file.isFile) {
          final outFile = File(outputPath);
          await outFile.parent.create(recursive: true);
          final data = file.content as List<int>;
          await outFile.writeAsBytes(data);
        } else {
          await Directory(outputPath).create(recursive: true);
        }
      }

      return true;
    } catch (e, stackTrace) {
      print("❌ 解压还原失败: $e");
      return false;
    }
  }
}

/// =====================================================================
/// 📌 后台 Isolate 入口函数（按要求采用 ZipFileEncoder）
///
/// 在 Dart 中，如果 Isolate 的入口函数写在类内部（哪怕是静态方法，或者在方法内部写成了 lambda 闭包），
/// 它会隐式地把当前类的实例（this）或者上下文当作参数传递给子线程。而 DataBackupViewModel 内部包含了 MutableState、
/// 监听器（Listeners）以及各种无法跨线程序列化的复杂对象，从而触发了 object is unsendable 报错。
/// =====================================================================
void _zipIsolateEntry(List<dynamic> args) {
  SendPort sendPort = args[0];
  String sourceDirPath = args[1];

  File? tempZipFile;
  try {
    final sourceDir = Directory(sourceDirPath);
    if (!sourceDir.existsSync()) {
      sendPort.send(null);
      return;
    }

    // 在系统临时目录生成压缩包
    final tempDir = Directory.systemTemp;
    tempZipFile = File('${tempDir.path}/temp_backup_${DateTime.now().millisecondsSinceEpoch}.zip');

    // 采用 ZipFileEncoder 压缩
    final encoder = ZipFileEncoder();
    encoder.create(tempZipFile.path);
    encoder.addDirectory(sourceDir); // 自动保留全部层级和空目录
    encoder.close();

    // 同步读取打包好的字节并传回主线程
    final zipBytes = tempZipFile.readAsBytesSync();
    sendPort.send(zipBytes);
  } catch (e) {
    sendPort.send("Error: $e");
  }
}