
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';

class TextProgressBar extends StatelessWidget {
  final _size = 120.0;
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
            color: context.contentColor,
            strokeWidth: 4.0,
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '${progress}%',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.contentColor,
          ),
        ),
      ],
    );
  }
}