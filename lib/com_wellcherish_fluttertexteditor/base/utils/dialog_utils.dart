import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';
import 'package:go_router/go_router.dart';

class DialogUtils {
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    String title = Strings.tips,
    String content = Strings.deleteSelectedContent,
    String cancelText = Strings.cancel,
    String confirmText = Strings.confirm,
    Future<bool> Function()? onConfirmTap,
  }) async {
    // context.push<bool> 或 showDialog 都可以配合 context.pop(result) 接收返回值
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: context.textTheme.titleMedium?.merge(
              TextStyle(color: context.colorScheme.onPrimaryContainer),
            ),
          ),
          content: Text(
            content,
            style: context.textTheme.bodyMedium?.merge(
              TextStyle(color: context.colorScheme.onPrimaryContainer),
            ),
          ),
          actionsPadding: EdgeInsets.zero,
          actions: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: FilledButton.styleFrom(
                      foregroundColor: context.colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => context.pop(false),
                    child: Text(cancelText),
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  color: context.colorScheme.outline,
                ),
                Expanded(
                  child: TextButton(
                    style: FilledButton.styleFrom(
                      foregroundColor: context.colorScheme.error,
                    ),
                    onPressed: () => context.pop(true),
                    child: Text(confirmText),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    // 根据返回的异步结果处理后续逻辑
    if (isConfirmed == true) {
      return await onConfirmTap?.call() ?? false;
    }
    return false;
  }
}