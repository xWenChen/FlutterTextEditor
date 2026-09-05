import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/bean/file_item.dart';

class FileData {

  FileItem? fileItem;

  String? content;

  bool itemSelected;

  String? get title => fileItem?.title;
  set title(String? title) => fileItem?.title = title;

  String? get contentId => fileItem?.contentId;
  set contentId(String? contentId) => fileItem?.contentId = contentId ?? '';

  FileData({
    required this.fileItem,
    this.itemSelected = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is FileData &&
              runtimeType == other.runtimeType &&
              content == other.content &&
              fileItem == other.fileItem &&
              itemSelected == other.itemSelected;

  @override
  int get hashCode => Object.hash(content, fileItem, itemSelected);

  FileData copyWith({
    FileItem? fileItem,
    String? content,
    bool? itemSelected,
  }) {
    return FileData(
      fileItem: fileItem ?? this.fileItem,
      itemSelected: itemSelected ?? this.itemSelected,
    )..content = content ?? this.content;
  }
}