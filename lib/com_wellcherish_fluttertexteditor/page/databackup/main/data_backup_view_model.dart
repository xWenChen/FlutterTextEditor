
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/file/editor_file_utils.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';

import 'backup_operation_info.dart';

class DataBackupViewModel extends BaseViewModel {
  static final _tag = "DataBackupViewModel";

  bool canPop = true;

  // 分批加载的文本列表。
  MutableState<List<BackupOperationInfo>> supportOperationList = MutableState(<BackupOperationInfo>[]);

  MutableState<BackupOperationInfo> selectedOperation = MutableState(BackupOperationInfo());

  MutableState<OperationState> operationState = MutableState(OperationState.idle);

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

  void updateProgress(int newProgress) {
    int value = newProgress;
    if (value < 0) {
      value = 0;
    } else if (value > 100) {
      value = 100;
    }
    operationProgress.value = value;
  }

// ---------------- DataBackupViewModel 内部方法 ----------------

  Future<void> syncData() async {
    updateProgress(0);
    operationState.value = OperationState.waitBackup;

    // 1. 指定你需要读取和打包的目录 (App 的文档目录)
    Directory? appDocDir = await EditorFileUtils.documentDir;
    if (appDocDir == null) {
      operationState.value = OperationState.fileSystemError;
      return;
    }

    Directory targetDir = Directory(appDocDir.path); // 目标文件夹

    operationState.value = OperationState.inBackup;
    // 2. 使用 ZipFileEncoder 进行目录打包压缩
    Uint8List? zipBytes = await saveToZip(targetDir);

    if (zipBytes != null) {
      // 3. 唤起系统文件管理器导出保存
      await exportZipToPublicDirectory(
        zipBytes,
        "backup_${DateTime.now().millisecondsSinceEpoch}",
      );
    } else {
      // 压缩失败
      operationState.value = OperationState.fileSystemError;
    }
  }

  /// 使用 ZipFileEncoder 压缩源目录 [sourceDir] 并返回 Zip 字节数据
  Future<Uint8List?> saveToZip(Directory sourceDir) async {
    File? tempZipFile;
    try {
      if (!await sourceDir.exists()) {
        return null;
      }

      // 创建临时压缩包文件路径
      final tempDir = Directory.systemTemp;
      tempZipFile = File('${tempDir.path}/temp_backup_${DateTime.now().millisecondsSinceEpoch}.zip');

      // 使用官方 ZipFileEncoder 压缩整个目录（自动保留完整子目录及空文件夹结构）
      final encoder = ZipFileEncoder();
      encoder.create(tempZipFile.path);
      await encoder.addDirectory(sourceDir);
      encoder.close();

      // 读取压缩好的 zip 字节数据
      final zipBytes = await tempZipFile.readAsBytes();
      return zipBytes;
    } catch (e, stackTrace) {
      print("❌ Zip 压缩失败: $e");
      print(stackTrace);
      return null;
    } finally {
      // 压缩过程最多占 90%。
      updateProgress(90);
    }
  }

  /// 将 [zipFile] 解压并还原原始结构到目标目录 [targetDir]
  Future<bool> restoreFromZip(File zipFile, Directory targetDir) async {
    try {
      if (!await zipFile.exists()) {
        return false;
      }

      // 1. 读取并解码 ZIP 文件
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 2. 遍历 ZIP 包内的每个文件/文件夹
      for (final file in archive) {
        final filename = file.name; // 保存时的相对路径
        final outputPath = '${targetDir.path}/$filename';

        if (file.isFile) {
          // 如果是文件，确保父级文件夹存在
          final outFile = File(outputPath);
          await outFile.parent.create(recursive: true);

          // 写入文件数据
          final data = file.content as List<int>;
          await outFile.writeAsBytes(data);
        } else {
          // 如果是文件夹 entry，直接创建目录
          await Directory(outputPath).create(recursive: true);
        }
      }

      return true;
    } catch (e, stackTrace) {
      print("❌ 解压还原失败: $e");
      return false;
    }
  }

  /// 唤起系统文件管理器，将 zip 文件保存到用户指定位置
  Future<void> exportZipToPublicDirectory(Uint8List zipBytes, String zipName) async {
    try {
      // 调用系统文件保存界面（SAF），免权限写入公共目录
      String? path = await FileSaver.instance.saveAs(
        name: zipName,
        bytes: zipBytes,
        ext: 'zip',
        mimeType: MimeType.zip,
      );

      if (path != null && path.isNotEmpty) {
        // 用户确认并保存成功
        operationProgress.value = 100;
        operationState.value = OperationState.endBackup;
      } else {
        // 用户在系统弹窗中点击了取消
        print("用户取消了文件保存");
        operationState.value = OperationState.idle;
      }
    } catch (e, stackTrace) {
      print("❌ 保存导出文件失败: $e");
      operationState.value = OperationState.fileSystemError;
    }
  }
}