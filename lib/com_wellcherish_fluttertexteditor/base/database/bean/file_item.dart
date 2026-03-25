
import 'package:drift/drift.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/constants/constants.dart';

/// 这里的类名默认会生成 FileItems 类，表名默认是 file_items
/// 如果想指定表名，重写 tableName 属性

/// class 名称为复数，DataClassName为单数。
@DataClassName("FileItem")
class FileItems extends Table {
  @override
  String get tableName => DbConstants.tableName;

  /// 主键：自增 Long 类型 (Int64)
  /// 调用 .autoIncrement() 时，Drift 内部会自动为该字段添加 PRIMARY KEY 约束。
  IntColumn get id => integer().autoIncrement()();
  /// 内容 ID (对应 Room 的 ColumnInfo)
  TextColumn get contentId => text()();
  /// 文件地址：允许为空 (对应 Room 的 String?)
  TextColumn get filePath => text().nullable()();
  /// 文件标题：允许为空
  TextColumn get title => text().nullable()();

  /// 更新时间：Drift 可以直接存 DateTime，也可以存 Int64 毫秒
  IntColumn get updateTime => integer()();

  /// 是否删除：布尔类型
  BoolColumn get isDeleted => boolean()();
}