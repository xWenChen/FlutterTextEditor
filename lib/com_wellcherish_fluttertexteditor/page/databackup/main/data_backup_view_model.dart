
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/file/editor_file_utils.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> syncData() async {
    // 1. 检查权限
    await requestStoragePermission();

    // 2. 指定你需要读取和打包的目录 (假设是 App 的文档目录)
    Directory? appDocDir = await EditorFileUtils.documentDir;
    if (appDocDir == null) {
      return;
    }

    Directory targetDir = Directory('${appDocDir.path}'); // 目标文件夹

    // 3. 读取并压缩
    List<int>? zipBytes = await saveToZip(targetDir);

    if (zipBytes != null) {
      // 4. 保存到系统公共目录
      await exportZipToPublicDirectory(zipBytes, "backup_${DateTime.now().millisecondsSinceEpoch}");
    }
  }

  /// 将源目录 [sourceDir] 压缩并返回 Zip 字节数据（完整保留子目录及空文件夹结构）
  Future<List<int>?> saveToZip(Directory sourceDir) async {
    if (!await sourceDir.exists()) {
      return null;
    }

    final archive = Archive();

    // recursive: true 递归获取所有子文件夹和文件
    final List<FileSystemEntity> entities = sourceDir.listSync(recursive: true);

    for (final entity in entities) {
      // 1. 计算相对路径，并统一替换 Windows 路径分隔符 '\\' 为 '/'
      String relativePath = entity.path.substring(sourceDir.path.length + 1);
      relativePath = relativePath.replaceAll('\\', '/');

      if (entity is File) {
        // 2. 处理文件
        final bytes = await entity.readAsBytes();
        final archiveFile = ArchiveFile(relativePath, bytes.length, bytes);
        archive.addFile(archiveFile);
      } else if (entity is Directory) {
        // 3. 处理子目录（含空文件夹）：路径末尾必须带 '/'，数据内容传 null 即可
        if (!relativePath.endsWith('/')) {
          relativePath += '/';
        }
        final archiveFile = ArchiveFile(relativePath, 0, null);
        archive.addFile(archiveFile);
      }
    }

    // 使用 ZipEncoder 进行编码
    final zipEncoder = ZipEncoder();
    return zipEncoder.encode(archive);
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
        final filename = file.name; // 这里获取到的就是保存时的相对路径
        final outputPath = '${targetDir.path}/$filename';

        if (file.isFile) {
          // 如果是文件，确保其所在的父级文件夹存在
          final outFile = File(outputPath);
          await outFile.parent.create(recursive: true);

          // 写入文件数据
          final data = file.content as List<int>;
          await outFile.writeAsBytes(data);
        } else {
          // 如果是单纯的空文件夹 entry，直接创建
          await Directory(outputPath).create(recursive: true);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// zip 文件保存到系统公共目录。
  Future<void> exportZipToPublicDirectory(List<int> zipBytes, String zipName) async {
    try {
      final Uint8List bytes = Uint8List.fromList(zipBytes);

      // 保存到系统公共下载目录 (Downloads)
      String? path = await FileSaver.instance.saveFile(
        name: zipName, // 文件名（无需加 .zip 后缀，参数 ext 会自动拼接）
        bytes: bytes,
        ext: 'zip',
        mimeType: MimeType.zip,
      );
    } catch (e) {
      // 打印异常。
    }
  }

  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      return status.isGranted;
    }
    return true;
  }
}