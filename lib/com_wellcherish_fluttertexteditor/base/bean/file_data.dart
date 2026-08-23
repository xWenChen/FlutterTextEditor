import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/bean/file_item.dart';

class FileData {

  FileItem? fileItem;

  String? content;

  String? get title => fileItem?.title;
  set title(String? title) => fileItem?.title = title;

  String? get contentId => fileItem?.contentId;
  set contentId(String? contentId) => fileItem?.contentId = contentId ?? '';

  FileData({
    required this.fileItem,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileData &&
          runtimeType == other.runtimeType &&
          content == other.content &&
          fileItem == other.fileItem;

  @override
  int get hashCode => Object.hash(content, fileItem);
}