import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/bean/file_data.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/config/app_config.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_space.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/router/route_constants.dart';

class FileListItemView extends StatefulWidget {
  final FileData? fileData;

  FileListItemView({
    super.key,
    this.fileData,
  });

  @override
  State<StatefulWidget> createState() => FileListItemViewState();
}

class FileListItemViewState extends State<FileListItemView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (mounted) {
          context.goRouter.goNamed(
            RouteConstants.editor,
            queryParameters: {
              RouteConstants.editorParamContentId: widget.fileData?.contentId,
            },
          );

          context.goRouter.go;
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题
          Text(
            widget.fileData?.title ?? Strings.noTitle,
            maxLines: AppConfig.listTitleLines,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.titleMedium,
          ),
          // 正文
          Container(
            padding: EdgeInsets.only(top: AppSpace.extraSmall),
            child: Text(
              widget.fileData?.content ?? Strings.noText,
              maxLines: AppConfig.listTextLines,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}