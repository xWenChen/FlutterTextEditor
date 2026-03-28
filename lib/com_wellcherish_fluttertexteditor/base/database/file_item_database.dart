
// 这行是必须的，用于指向生成的文件
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../log/log.dart';
import 'bean/file_item.dart';
import 'dao/file_item_dao.dart';
import 'package:isar/isar.dart';

class FileItemDatabase {
  static final _tag = "FileItemDatabase";

  late final FileItemDao fileDao;

  /// 1. 静态私有实例（设为可空，因为需要运行时动态创建）
  static FileItemDatabase? _instance;

  /// 2. 私有构造函数。
  FileItemDatabase._internal();
  /// 3. 工厂构造函数
  factory FileItemDatabase() {
    if (_instance == null) {
      var errorMsg = "not initialized, call initialize() first.";
      ZLog.e(_tag, message: errorMsg);
      throw Exception(errorMsg);
    }
    return _instance!;
  }

  static Future<void> initialize() async {
    final dir = await _getDbDir();

    final isarObj = await Isar.open(
      [FileItemSchema], // 自动生成的 Schema
      directory: dir.path,
      inspector: true, // 开启调试浏览器，可以在电脑端查看数据库内容
    );

    _instance ??= FileItemDatabase._internal()
      ..fileDao = FileItemDao(isarObj);
  }

  static Future<Directory> _getDbDir() async {
    /// 1. 获取基础文档目录
    final dir = await getApplicationDocumentsDirectory();
    /// 2. 构造自定义子目录路径 (例如: .../app_docs/database)
    final dbFileDir = Directory(path.join(dir.path, "database"));
    /// 3. 检测并创建目录。recursive: true 确保如果父目录不存在也会一并创建
    if (!await dbFileDir.exists()) {
      await dbFileDir.create(recursive: true);
    }

    return dbFileDir;
  }
}