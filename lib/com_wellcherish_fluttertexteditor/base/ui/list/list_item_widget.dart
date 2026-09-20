import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';

import '../../constants/material3/app_size.dart';
import '../../constants/material3/app_space.dart';

class ListItemWidget extends StatelessWidget {
  const ListItemWidget({
    super.key,
    required this.title,
    this.titleMaxLines,
    this.titleStyle,
    this.subTitle,
    this.subTitleMaxLines,
    this.subTitleStyle,
    this.overflow = TextOverflow.ellipsis,
    this.leading,
    this.trailing,
    this.trailingAlignment = Alignment.centerRight,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.backgroundColor,
    this.borderRadius = AppSpace.small,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: AppSpace.medium, vertical: AppSpace.small,),
  });

  // Title 参数
  final String title;
  final int? titleMaxLines;
  final TextStyle? titleStyle;

  // SubTitle 参数
  final String? subTitle;
  final int? subTitleMaxLines;
  final TextStyle? subTitleStyle;

  // 通用文本截断
  final TextOverflow overflow;

  // 左右 Widget
  final Widget? leading;
  final Widget? trailing;
  final Alignment trailingAlignment;

  // 交互与样式
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    // 1. 获取选中的颜色逻辑
    final effectiveSelectedColor = context.contentColor;
    TextStyle? defaultTitleStyle = context.textTheme.titleMedium;
    TextStyle? defaultSubTitleStyle = context.textTheme.bodyMedium;
    if (selected) {
      defaultTitleStyle = defaultTitleStyle?.copyWith(color: effectiveSelectedColor);
      defaultSubTitleStyle = defaultSubTitleStyle?.copyWith(color: effectiveSelectedColor);
    }

    final finalTitleStyle = titleStyle ?? defaultTitleStyle;
    final finalSubTitleStyle = subTitleStyle ?? defaultSubTitleStyle;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias, // 防水波纹溢出圆角
      child: Stack(
        children: [
          // 底层：点击手势 + 核心内容排版 (Leading + Title/SubTitle)
          InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            child: Padding(
              padding: contentPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading 逻辑：有值则展示，无值隐藏
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: AppSize.smallIcon),
                  ],

                  // 中间文本区域（Title + SubTitle）
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          maxLines: titleMaxLines,
                          overflow: overflow,
                          style: finalTitleStyle,
                        ),

                        // SubTitle 逻辑：有值且不为空才展示
                        if (subTitle != null && subTitle!.isNotEmpty) ...[
                          Text(
                            subTitle!,
                            maxLines: subTitleMaxLines,
                            overflow: overflow,
                            style: finalSubTitleStyle,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 顶层：覆盖式 Trailing（使用 Positioned.fill + Align 放置在最上层）
          if (trailing != null)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false, // 如果 trailing 内部组件（如 Checkbox）需要点击，保持 false
                child: Align(
                  alignment: trailingAlignment,
                  child: trailing,
                ),
              ),
            ),
        ],
      ),
    );
  }
}