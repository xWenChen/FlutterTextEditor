
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_size.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_space.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';
import '../../../base/constants/file_save_state.dart';
import '../../../resource/strings.dart';

class EditorTextStateTips extends StatefulWidget {
  final FileSaveState saveState;
  final VoidCallback? onClearText;
  final bool topEnable;
  final bool bottomEnable;
  final void Function(bool)? onScroll;

  EditorTextStateTips({
    super.key,
    this.saveState = FileSaveState.dataLoading,
    this.onClearText,
    this.topEnable = true,
    this.bottomEnable = true,
    this.onScroll,
  });

  @override
  State<EditorTextStateTips> createState() => _EditorTextStateTipsState();
}

class _EditorTextStateTipsState extends State<EditorTextStateTips> {
  static final String _tag = "_EditorTextStateTipsState";
  @override
  Widget build(BuildContext context) {
    final (icon, color, tips) = getTipsInfo(widget.saveState);

    return Container(
      padding: EdgeInsets.symmetric(vertical: AppSpace.extraSmall),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: AppSize.littleSmall,
              ),
              SizedBox(width: AppSpace.small,), // 间距
              Text(
                tips,
                style: context.textTheme.labelLarge?.copyWith(
                    color: color
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 滚动到顶部
              EditTextFunction(
                iconData: Icons.keyboard_double_arrow_up_rounded,
                onPressed: widget.topEnable ? () {
                  widget.onScroll?.call(true);
                } : null,
                backgroundColor: context.colorScheme.primaryContainer,
                disabledBackgroundColor: context.colorScheme.surfaceContainer,
              ),
              SizedBox(width: AppSpace.medium,), // 间距
              // 滚动到底部。
              EditTextFunction(
                iconData: Icons.keyboard_double_arrow_down_rounded,
                onPressed: widget.bottomEnable ? () {
                  widget.onScroll?.call(false);
                } : null,
                backgroundColor: context.colorScheme.primaryContainer,
                disabledBackgroundColor: context.colorScheme.surfaceContainer,
              ),
              SizedBox(width: AppSpace.medium,), // 间距
              // 清除文本。
              EditTextFunction(
                iconData: Icons.delete_forever_rounded,
                onPressed: widget.onClearText,
                backgroundColor: context.colorScheme.errorContainer,
                disabledBackgroundColor: context.colorScheme.surfaceContainer,
              ),
            ],
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) getTipsInfo(FileSaveState state) {
    switch (state) {
      case FileSaveState.dataLoading:
        return (Icons.change_circle_rounded, Colors.blue, Strings.dataLoading);
      case FileSaveState.unsaved:
        return (Icons.sentiment_dissatisfied_rounded, Colors.red, Strings.unsaved);
      case FileSaveState.saving:
        return (Icons.sentiment_neutral_rounded, Colors.orange, Strings.saving);
      case FileSaveState.saved:
        return (Icons.sentiment_satisfied_rounded, Colors.green, Strings.saved);
    }
  }
}

class EditTextFunction extends StatelessWidget {
  const EditTextFunction({
    super.key,
    required this.iconData,
    required this.onPressed,
    this.foregroundColor,
    this.backgroundColor,
    this.disabledForegroundColor,
    this.disabledBackgroundColor,
  });

  final IconData iconData;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledForegroundColor;
  final Color? disabledBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(iconData,),
      onPressed: onPressed,
      iconSize: AppSize.littleSmall,
      padding: EdgeInsets.all(AppSpace.extraSmall), // 清除默认内边距
      constraints: const BoxConstraints(), // 清除默认的 48dp 最小限制
      style: IconButton.styleFrom(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        disabledForegroundColor: disabledForegroundColor,
        disabledBackgroundColor: disabledBackgroundColor,
        shape: const CircleBorder(),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 紧凑型点击热区
      ),
    );
    /// TextButton的写法。
    /*TextButton(
      onPressed: widget.onClearText,
      style: TextButton.styleFrom(
        backgroundColor: Colors.red,
        // 1. 将最小尺寸设为 0，否则 padding vertical: 0 会被忽略
        minimumSize: Size.zero,
        // 2. 将点击热区设置为紧凑模式，消除外部多余的透明边距
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // 设置内间距：上下 15，左右 30
        padding: EdgeInsets.symmetric(horizontal: AppSpace.small, vertical: AppSpace.extraSmall),
        // 3. 定义形状：圆角矩形
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpace.small), // 数值越大越圆润
        ),
      ),
      child: Text(
        Strings.clearText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),*/
  }
}