
import 'dart:io';

import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../extension/string_extension.dart';

class EditorFileUtils {
  static final String _tag = "EditorFileUtils";
  static const String _separator = "\n<<<___###!!!&&&--->>>\n";

  static String concatTitleAndText(String? title, String content, [String separator = _separator]) {
    // 使用正则表达式匹配标题中的所有换行符并替换为空字符串
    var _title = title?.replaceAll(RegExp(r'[\r\n]'), "") ?? "";
    return "$_title$separator$content";
  }

  static (String?, String?) splitTitleAndText(String? fileText, [String separator = _separator]) {
    if (fileText.isNullOrEmpty) {
      return ("", "");
    }
    var result = fileText!.split(separator);
    if (result.isEmpty) {
      return ("", "");
    }
    if (result.length < 2) {
      // 内容当作正文。
      return ("", result[0]);
    }
    return (result[0], result[1]);
  }

  static Future<File?> getNewTxtFile({String? fileName}) async {
    if (fileName.isNullOrEmpty) {
      fileName = getUUID();
    }

    var dir = await documentDir;
    if (dir == null) {
      ZLog.d(_tag, "getNewTxtFile, dir=null");
      return null;
    }
    final file = File("${dir.path}/${fileName}.txt");

    if (!(await file.exists())) {
      await file.create();
    }

    return file;
  }

  // 1. 获取文档目录的路径
  static Future<Directory?> get documentDir async {
    Directory? directory;
    try {
      directory = await getApplicationDocumentsDirectory();
    } catch (e, stack) {
      ZLog.e(_tag, "", e, stack);
      directory = null;
    }
    return directory;
  }

  /// 获取uuid作为文件名。
  static String getUUID() {
    // 1. 初始化 UUID 实例
    var uuid = const Uuid();
    // 2. 生成 v4 (基于随机数) - 最常用
    // 示例输出: '110ec58a-a0f2-4ac4-8393-c891d8134f3d'
    String v4 = uuid.v4();
    // 干掉短横线。
    return v4.replaceAll("-", "");
  }

  /// 获取文件内容
  static Future<String?> getFileContentByPath(String? filePath) async {
    if (filePath == null) return null;
    return await getFileContentByFile(File(filePath));
  }

  /// 获取文件内容
  static Future<String?> getFileContentByFile(File? file) async {
    if (file == null) return null;
    if (!(await file.exists())) return null;
    return file.readAsString();
  }
}