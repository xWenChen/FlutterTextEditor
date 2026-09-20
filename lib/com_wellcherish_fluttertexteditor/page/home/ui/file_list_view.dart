import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/bean/file_data.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_space.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';

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
    return MasonryGridView.count(
      itemCount: list.length,
      crossAxisCount: 2,
      mainAxisSpacing: AppSpace.medium,
      crossAxisSpacing: AppSpace.medium,
      itemBuilder: (context, index) {
        var data = list[index];
        return Container(
          // 1. 设置内边距（可选，防止内容紧贴边缘）
          padding: const EdgeInsets.all(AppSpace.extraSmall),
          // 2. 使用 decoration 配置背景色和圆角
          decoration: BoxDecoration(
            color: context.widgetBackground, // 白色背景
            borderRadius: BorderRadius.circular(AppSpace.small), // 圆角半径（根据需要修改数值）
          ),
          // 3. 子组件
          child: FileListItemView(
            index: index,
            fileData: data,
            isSelectionMode: isSelectionMode,
            onTap: widget.onItemTap,
            onLongPress: widget.onItemLongPress,
          ),
        );
      }
    );
  }
}