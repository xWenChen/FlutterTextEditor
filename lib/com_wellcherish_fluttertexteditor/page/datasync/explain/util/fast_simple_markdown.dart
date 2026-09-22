import 'package:flutter/material.dart';

import '../../../../base/constants/material3/app_space.dart';
import '../../../../base/extension/build_context_extension.dart';

/// ============================================================================
/// 3. 轻量级 Markdown 渲染器（高性能零正则单次扫描）
/// ============================================================================
class FastSimpleMarkdown extends StatelessWidget {
  final List<String> textList;

  static final titleFlagMap = <String, int>{
    "#": 1,
    "##": 2,
    "###": 3,
    "####": 4,
    "#####": 5,
    "######": 6,
  };

  const FastSimpleMarkdown({super.key, required this.textList});

  @override
  Widget build(BuildContext context) {
    final defaultStyle = context.textTheme.bodyMedium?.copyWith(
      color: context.contentColor
    );

    final List<Widget> widgets = [];

    for (int i = 0; i < textList.length; i++) {
      final line = textList[i];
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: AppSpace.extraSmall));
        continue;
      }

      // 1. 行级解析：检测标题 (# ~ ######)
      int titleLevel = 0;
      while (titleLevel < line.length && titleLevel < 6 && line[titleLevel] == '#') {
        titleLevel++;
      }

      if (titleLevel > 0 && titleLevel < line.length && line[titleLevel] == ' ') {
        final titleText = line.substring(titleLevel + 1);
        final headingStyle = _getHeadingStyle(context, titleLevel);
        // 标题
        widgets.add(
          Container(
            padding: EdgeInsets.symmetric(vertical: AppSpace.extraSmall),
            child: Text.rich(
              TextSpan(
                children: _parseInlineBold(titleText, headingStyle),
              ),
            ),
          ),
        );
      } else {
// 2. 正文解析
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text.rich(
              TextSpan(
                children: _parseInlineBold(line, defaultStyle),
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  /// 获取对应级别标题样式（自动适配亮暗模式的主色调）
  TextStyle? _getHeadingStyle(BuildContext context, int level) {
    final primary = context.contentColor;
    final textTheme = context.textTheme;
    switch (level) {
      case 1:
        return textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: primary,
        );
      case 2:
        return textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: primary,
        );
      case 3:
        return textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: primary,
        );
      default:
        return textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: primary,
        );
    }
  }

  /// 高效内联加粗解析：基于 indexOf 指针遍历（无正则表达式开销）
  List<InlineSpan> _parseInlineBold(String text, TextStyle? baseStyle) {
    final List<InlineSpan> spans = [];
    int start = 0;

    while (start < text.length) {
      final int openIdx = text.indexOf('**', start);
      if (openIdx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }

      final int closeIdx = text.indexOf('**', openIdx + 2);
      if (closeIdx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }

      if (openIdx > start) {
        spans.add(TextSpan(text: text.substring(start, openIdx), style: baseStyle));
      }

      final boldText = text.substring(openIdx + 2, closeIdx);
      spans.add(
        TextSpan(
          text: boldText,
          style: baseStyle?.copyWith(fontWeight: FontWeight.w600),
        ),
      );

      start = closeIdx + 2;
    }

    return spans;
  }
}
