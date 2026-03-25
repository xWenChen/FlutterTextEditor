import 'package:drift/drift.dart';

import '../bean/file_item.dart';
import '../file_item_database.dart';

part 'file_item_dao.g.dart';

@DriftAccessor(tables: [FileItems])
class FileItemDao extends DatabaseAccessor<FileItemDatabase> with _$FileItemDaoMixin {
  FileItemDao(super.db);

  /// 1. 查询所有 (SELECT * FROM table)
  /// fileItems 代表了数据库中的那张表。
  Future<List<FileItem>> queryAll() => db.managers.fileItems.get();

  /// 2. 根据 ID 列表查询 (WHERE id IN (:ids))
  Future<List<FileItem>> loadAllByIds(List<int> ids) {
    return db.managers.fileItems
        .filter((o) => o.id.isIn(ids))
        .get();
  }

  /// 3. 按时间逆序并过滤删除状态 (ORDER BY updateTime DESC)
  /// OrderingTerm 代表排序的具体约束。
  Future<List<FileItem>> queryAllByTimeSort(bool deleted) {
    return db.managers.fileItems
        .filter((o) => o.isDeleted(deleted))
        .orderBy((o) => o.updateTime.desc())
        .get();
  }

  /// 4. 分页加载 (LIMIT :size OFFSET :offset)
  Future<List<FileItem>> queryByPage(int offset, int size) {
    return db.managers.fileItems
        .orderBy((o) => o.updateTime.desc())
        .limit(size, offset: offset)
        .get();
  }

  /// 5. 根据 ContentID 查询单条 (LIMIT 1)
  Future<FileItem?> queryByContentId(String contentId) {
    return db.managers.fileItems
        .filter((o) => o.contentId(contentId))
        .getSingleOrNull();
  }

  /// 6. 插入 (支持单条或列表)
  /// 注意：插入通常使用 Companion 类，因为 id 是自增的，不需要手动传入
  Future<void> insertAll(List<FileItem> data) async {
    await db.batch((b) => b.insertAll(db.fileItems, data));
  }

  /// 7. 更新 (返回成功更新的行数)
  Future<int> updateOne(FileItem data) {
    return db.managers.fileItems
        .filter((o) => o.id(data.id)) // 定位到那一行
        .update((c) => data.toCompanion(true)); // 将实体类转为 Companion 执行更新
  }

  /// 8.只更新某个字段
  Future<int> markAsDeleted(int id) {
    return db.managers.fileItems
        .filter((o) => o.id(id))
        .update((c) => c(isDeleted: const Value(true)));
  }

  /// 9. 删除 (返回成功删除的行数)
  Future<int> deleteOne(FileItem data) {
    return db.managers.fileItems
        .filter((o) => o.id(data.id))
        .delete();
  }

  /// 10. 批量删除示例
  Future<int> deleteAll(List<int> ids) {
    return db.managers.fileItems
        .filter((o) => o.id.isIn(ids))
        .delete();
  }
}