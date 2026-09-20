import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/bean/file_data.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/config/app_config.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_size.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_space.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/string_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';

import '../../../base/ui/list/list_item_widget.dart';

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
    return ListItemWidget(
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
      title: (fileData?.title).ifEmpty(Strings.noTitle),
      titleMaxLines: AppConfig.listTitleLines,
      titleStyle: context.textTheme.titleMedium?.merge(TextStyle(
        color: context.contentColor,
        fontWeight: FontWeight.w500,
      )),
      subTitle: (fileData?.content).ifEmpty(Strings.noText),
      subTitleMaxLines: AppConfig.listTextLines,
      subTitleStyle: context.textTheme.bodyMedium?.merge(TextStyle(
        color: context.contentColor,
      )),
      overflow: TextOverflow.ellipsis,
      trailing: isSelectionMode ? GestureDetector(
        onTap: () => widget.onTap?.call(fileData, index, isSelectionMode, itemSelected),
        child: Icon(
          itemSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: AppSize.mediumIcon,
          color: context.contentColor,
        ),
      ) : null,
      trailingAlignment: Alignment.topRight,
      borderRadius: AppSpace.smallX,
      backgroundColor: context.widgetBackground,
    );
  }
}