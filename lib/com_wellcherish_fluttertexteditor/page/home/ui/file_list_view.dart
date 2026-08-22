import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/bean/file_data.dart';

import 'file_list_item_view.dart';

class FileListView extends StatefulWidget {
  final List<FileData> fileDataList;

  FileListView({
    super.key,
    required this.fileDataList,
  });

  @override
  State<StatefulWidget> createState() => FileListViewState();
}

class FileListViewState extends State<FileListView> {
  @override
  Widget build(BuildContext context) {
    final list = widget.fileDataList;
    return ListView.separated(
      itemBuilder: (context, index) {
        var data = list[index];
        return FileListItemView(
          key: ObjectKey(data),
          fileData: data,
        );
      },
      separatorBuilder: (context, index) {
        if (index == list.length - 1) {
          return SizedBox.shrink();
        } else {
          return Divider();
        }
      },
      itemCount: list.length,
    );
  }
}