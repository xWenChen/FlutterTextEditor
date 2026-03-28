
// 这行是必须的，用于指向生成的文件
import 'package:drift/drift.dart';

import '../log/log.dart';
import 'bean/file_item.dart';
import 'dao/file_item_dao.dart';

part 'file_item_database.g.dart';

@DriftDatabase(
    tables: [FileItems],
    daos: [FileItemDao]
)
class FileItemDatabase extends _$FileItemDatabase {
  static final _tag = "FileItemDatabase";
  late final FileItemDao fileDao = FileItemDao(this);
  /// 1. 私有构造函数，接收执行器并传给父类
  FileItemDatabase._internal(super.e);
  /// 2. 静态私有实例（设为可空，因为需要运行时动态创建）
  static FileItemDatabase? _instance;
  /// 3. 工厂构造函数
  factory FileItemDatabase() {
    if (_instance == null) {
      var errorMsg = "not initialized, call initialize() first.";
      ZLog.e(_tag, message: errorMsg);
      throw Exception(errorMsg);
    }
    return _instance!;
  }
  /// 4. 提供一个静态初始化方法（传入查询执行器）,在runApp前调用。
  static void initialize(QueryExecutor executor) {
    _instance ??= FileItemDatabase._internal(executor);
  }

  @override
  int get schemaVersion => 1;
}