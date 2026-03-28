import '../bean/file_item.dart';
import 'package:isar/isar.dart';

class FileItemDao {
  final Isar isar;

  FileItemDao(this.isar);

  /// 1. 查询所有。where() 的作用是**“开启索引查询通道”**。Where（走索引） 和 Filter（走过滤）。
  Future<List<FileItem>> queryAll() => isar.fileItems.where().findAll();

  /// 2. 根据 ID 列表查询
  Future<List<FileItem>> loadAllByIds(List<int> ids) {
    return isar.fileItems.getAll(ids).then((list) => list.whereType<FileItem>().toList());
  }

  /// 3. 按时间逆序并过滤删除状态
  Future<List<FileItem>> queryAllByTimeSort(bool deleted) {
    return isar.fileItems
        .filter()
        .isDeletedEqualTo(deleted)
        .sortByUpdateTimeDesc()
        .findAll();
  }

  /// 4. 分页加载 (OFFSET & LIMIT)
  Future<List<FileItem>> queryByPage(int offset, int size) {
    return isar.fileItems
        .where()
        .sortByUpdateTimeDesc()
        .offset(offset)
        .limit(size)
        .findAll();
  }

  /// 5. 根据 ContentID 查询单条
  Future<FileItem?> queryByContentId(String contentId) {
    return isar.fileItems.filter().contentIdEqualTo(contentId).findFirst();
  }

  /// 6. 插入 (批量)
  Future<void> insertAll(List<FileItem> data) async {
    await isar.writeTxn(() async {
      await isar.fileItems.putAll(data);
    });
  }

  /// 7. 更新 (Isar 的 put 会根据 ID 自动处理新增或覆盖)
  Future<void> updateOne(FileItem data) async {
    await isar.writeTxn(() async {
      await isar.fileItems.put(data);
    });
  }

  /// 8. 只更新某个字段 (局部更新)
  Future<void> markAsDeleted(int id) async {
    await isar.writeTxn(() async {
      final item = await isar.fileItems.get(id);
      if (item != null) {
        item.isDeleted = true;
        await isar.fileItems.put(item);
      }
    });
  }

  /// 9. 删除单条
  Future<bool> deleteOne(int id) async {
    return await isar.writeTxn(() => isar.fileItems.delete(id));
  }

  /// 10. 批量删除
  Future<int> deleteAll(List<int> ids) async {
    return await isar.writeTxn(() => isar.fileItems.deleteAll(ids));
  }
}