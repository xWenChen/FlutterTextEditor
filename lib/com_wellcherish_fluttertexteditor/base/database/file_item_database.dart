
// 这行是必须的，用于指向生成的文件
import 'package:drift/drift.dart';

import 'bean/file_item.dart';
import 'dao/file_item_dao.dart';

part 'file_item_database.g.dart';

@DriftDatabase(
    tables: [FileItems],
    daos: [FileItemDao]
)
class FileItemDatabase extends _$FileItemDatabase {
  FileItemDatabase(super.e);

  late final FileItemDao fileDao = FileItemDao(this);

  @override
  int get schemaVersion => 1;
}