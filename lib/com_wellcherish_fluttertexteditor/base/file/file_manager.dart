import 'dart:async';
import 'dart:io';

import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/file_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/string_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';

class FileManager {
  static final String _tag = "FileManager";
  // 单例
  static final FileManager instance = FileManager();
  factory FileManager() => instance;
  FileManager.internal();

  // 关键：为每个路径维护一个 Future，充当“任务队列”的尾巴
  final Map<String, Future<void>> _writeQueues = {};

  /// 多读：直接读取，不阻塞
  Future<String?> readFileByPath(String? path) async {
    if (path.isNullOrEmpty) {
      ZLog.e(_tag, "readFileByFile path empty.");
      return null;
    }
    try {
      final file = File(path!);
      return await readFileByFile(file);
    } catch (e, stackTrace) {
      ZLog.e(_tag, "readFileByPath error, $path", e, stackTrace);
      return null;
    }
  }

  /// 多读：直接读取，不阻塞
  Future<String?> readFileByFile(File? file) async {
    if (file == null) {
      ZLog.e(_tag, "readFileByFile file=null");
      return null;
    }
    try {
      if (!await file.exists()) {
        ZLog.w(_tag, "readFile, file not exist, ${file.absolutePath}");
        return null;
      }
      // 这里的 readAsString 默认是字符流处理，且支持并发读取
      return await file.readAsString();
    } catch (e, stackTrace) {
      ZLog.e(_tag, "readFileByFile error, ${file.absolutePath}", e, stackTrace);
      return null;
    }
  }

  /// 单写排队：手动维护 Future 链
  Future<void> tryWriteFileByPath(String? path, String content, {FileMode mode = FileMode.write}) async {
    if (path.isNullOrEmpty) {
      ZLog.e(_tag, "tryWriteFileByPath path empty.");
      return;
    }
    await tryWriteFileByFile(File(path!), content, mode: mode);
  }

  /// 单写排队：手动维护 Future 链
  Future<void> tryWriteFileByFile(File? file, String content, {FileMode mode = FileMode.write}) async {
    if (file == null) {
      ZLog.e(_tag, "tryWriteFileByFile file=null");
      return;
    }
    final path = file.absolutePath!;
    // 1. 获取该路径当前的“最后一道工序”
    // Future.value() 一个已经完成的 Future。代码中用来表示“当前没有人排队，可以直接开始”。
    final previousTask = _writeQueues[path] ?? Future.value();
    // 2. 创建“我这一棒”的 Completer。Completer用于精准控制future的结束。
    // Completer 用于获取future，并指定其完成时机。。
    final currentTaskCompleter = Completer<void>();
    final currentTask = currentTaskCompleter.future;
    // 3. 更新 Map，让下一个人等我的 selfCompleter.future
    // 这样下一个人只会等我这一棒跑完，而不会被卷入更长的链条
    _writeQueues[path] = currentTask;
    // 4. 排队逻辑：等前一个人跑完
    previousTask.whenComplete(() async {
      try {
        // 执行真正的 IO 操作
        await _writeFile(path, content, mode: mode);
        // 这一行执行后，外部 await writeFile() 的地方会立即恢复执行
        currentTaskCompleter.complete();
      } catch (e, trace) {
        ZLog.e(_tag, "", e, trace);
        // complete或者completeError，都会走到whenComplete，then和catchError才是互斥的。
        currentTaskCompleter.completeError(e, trace);
      } finally {
        // 移除内容。
        if (_writeQueues[path] == currentTask) {
          _writeQueues.remove(path);
        }
      }
    });

    // 6. 返回我自己的 Future 给调用者，而不是返回整个链条
    return currentTask;
  }

  Future<void> _writeFile(String path, String content, {FileMode mode = FileMode.write}) async {
    final file = File(path);
    final directory = file.parent;
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    await file.writeAsString(content, mode: mode, flush: true);
    ZLog.d(_tag, "_writeFile success, $path, $mode", );
  }
}