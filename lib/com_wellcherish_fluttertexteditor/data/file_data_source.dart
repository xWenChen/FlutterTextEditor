import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/file_item_database.dart';

import '../base/database/bean/file_item.dart';

class FileDataSource {
  final _dao = FileItemDatabase().fileDao;

  Future<List<FileItem>> queryAll() async {
    return await _dao.queryAll();
  }
}