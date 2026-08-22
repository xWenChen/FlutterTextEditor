import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/bean/file_data.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/file_item_database.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/file/editor_file_utils.dart';

import '../base/database/bean/file_item.dart';

class FileDataSource {
  /// 1. 私有化构造函数，防止外部直接构造对象 (FileDataSource())
  FileDataSource._internal();

  /// 2. 创建并持有一个静态私有实例
  static final FileDataSource _instance = FileDataSource._internal();

  /// 3. 提供 factory 构造函数，外部调用 FileDataSource() 时始终返回同一个实例
  factory FileDataSource() => _instance;

  final _dao = FileItemDatabase().fileDao;

  Future<List<FileData>> queryAll() async {
    final dbList = await _dao.queryAll();
    return await _dbListToUIList(dbList);
  }

  Future<FileData?> queryByContentId(String contentId) async {
    final fileItem = await _dao.queryByContentId(contentId);
    return await _dbItemToUIItem(fileItem);
  }

  /// 插入或者更新 (Isar 的 put 会根据 ID 自动处理新增或覆盖)
  Future<void> insertOrUpdateOne(FileItem data) async {
    await _dao.updateOne(data);
  }

  Future<List<FileData>> _dbListToUIList(List<FileItem> list) async {
    final uiList = list.map((item) => FileData(fileItem: item)).toList();
    uiList.forEach((data) async {
      final fileText = await EditorFileUtils.getFileContentByPath(data.fileItem?.filePath);
      data.content = EditorFileUtils.splitTitleAndText(fileText).$2;
    });

    return uiList;
  }

  Future<FileData?> _dbItemToUIItem(FileItem? fileItem) async {
    if (fileItem == null) return null;

    final data = FileData(fileItem: fileItem);

    final fileText = await EditorFileUtils.getFileContentByPath(fileItem.filePath);
    data.content = EditorFileUtils.splitTitleAndText(fileText).$2;

    return data;
  }
}