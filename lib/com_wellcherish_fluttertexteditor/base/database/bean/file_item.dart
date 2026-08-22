import 'package:isar/isar.dart';

// 必须包含这行，运行 build_runner 后生成的文件
part 'file_item.g.dart';

/// 一个类对应数据库中的一张表（Collection）
@collection
class FileItem {
  /// 必须有 Id 字段，Isar.autoIncrement 会自动分配
  Id id = Isar.autoIncrement;

  /// 唯一索引，查询速度极快。
  /// replace: true 是冲突解决策略。
  @Index(unique: true, replace: true)
  String contentId;

  String? filePath;
  String? title;

  @Index()
  int updateTime;

  @Index()
  bool isDeleted;

  FileItem({
    required this.contentId,
    this.filePath,
    this.title,
    required this.updateTime,
    this.isDeleted = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          contentId == other.contentId &&
          filePath == other.filePath &&
          title == other.title &&
          updateTime == other.updateTime &&
          isDeleted == other.isDeleted;

  @override
  int get hashCode =>
      Object.hash(id, contentId, filePath, title, updateTime, isDeleted);
}