
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';

class TextProgressBar extends StatelessWidget {
  final _size = 120.0;
  // 为null表示无限循环动画。
  final int progress;

  TextProgressBar({
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: _size,
          height: _size,
          // 进度条不传value，就是无限转圈。
          child: CircularProgressIndicator(
            value: _animProgress(),
            color: context.contentColor,
            strokeWidth: 4.0,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '${progress ?? 0}%',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.contentColor,
          ),
        ),
      ],
    );
  }

  double? _animProgress() {
    // 返回 null 表示展示无限动画
    if (progress <= 0 || progress >= 100) {
      return progress.toDouble();
    }
    return null;
  }
}