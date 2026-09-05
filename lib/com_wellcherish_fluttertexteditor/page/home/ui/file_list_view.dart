import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/bean/file_data.dart';

import 'file_list_item_view.dart';

class FileListView extends StatefulWidget {
  final List<FileData> fileDataList;
  final bool isSelectionMode;
  final ListItemTapCallback? onItemTap;
  final ListItemTapCallback? onItemLongPress;

  FileListView({
    super.key,
    required this.fileDataList,
    this.isSelectionMode = false,
    this.onItemTap,
    this.onItemLongPress,
  });

  @override
  State<StatefulWidget> createState() => FileListViewState();
}

class FileListViewState extends State<FileListView> {
  @override
  Widget build(BuildContext context) {
    final list = widget.fileDataList;
    final isSelectionMode = widget.isSelectionMode;
    return ListView.separated(
      itemBuilder: (context, index) {
        var data = list[index];
        return FileListItemView(
          index: index,
          fileData: data,
          isSelectionMode: isSelectionMode,
          onTap: widget.onItemTap,
          onLongPress: widget.onItemLongPress,
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      itemCount: list.length,
    );
  }
}