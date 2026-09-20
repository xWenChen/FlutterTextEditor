import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/bean/file_data.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/config/app_config.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_space.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/string_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';

typedef ListItemTapCallback = Future<void> Function(FileData?, int, bool, bool);

class FileListItemView extends StatefulWidget {
  final int index;
  final FileData? fileData;
  final bool isSelectionMode;
  final ListItemTapCallback? onTap;
  final ListItemTapCallback? onLongPress;

  FileListItemView({
    super.key,
    this.index = 0,
    this.fileData,
    this.isSelectionMode = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<StatefulWidget> createState() => FileListItemViewState();
}

class FileListItemViewState extends State<FileListItemView> {
  @override
  Widget build(BuildContext context) {
    final fileData = widget.fileData;
    final index = widget.index;
    final isSelectionMode = widget.isSelectionMode;
    final itemSelected = fileData?.itemSelected ?? false;
    return ListTile(
      selected: itemSelected,
      onTap: () async {
        if (mounted) {
          widget.onTap?.call(fileData, index, isSelectionMode, itemSelected);
        }
      },
      onLongPress: () async {
        if (mounted) {
          widget.onLongPress?.call(fileData, index, isSelectionMode, itemSelected);
        }
      },
      title: Text(
        (fileData?.title).ifEmpty(Strings.noTitle),
        maxLines: AppConfig.listTitleLines,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.titleLarge?.merge(TextStyle(
          color: context.contentColor,
          fontWeight: FontWeight.w500,
        )),
      ),
      subtitle: Container(
        child: Text(
          (fileData?.content).ifEmpty(Strings.noText),
          maxLines: AppConfig.listTextLines,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodyLarge?.merge(TextStyle(
            color: context.contentColor,
          )),
        ),
      ),
      trailing: isSelectionMode ? Checkbox(
        value: itemSelected,
        onChanged: (bool? newValue) async {
          widget.onTap?.call(fileData, index, isSelectionMode, itemSelected);
        },
      ) : null,
      dense: true, // 1. 开启紧凑模式，缩小默认的高度和字体间距
      visualDensity: VisualDensity(vertical: -AppSpace.extraSmall), // 2. 将垂直方向的密度压到极致（范围 -4 到 4）
    );
  }
}