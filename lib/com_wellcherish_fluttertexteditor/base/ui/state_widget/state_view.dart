
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_size.dart';

import '../../constants/material3/app_space.dart';
import '../../extension/build_context_extension.dart';

/// 通用的基础视图组件 (无动画)
class StateView extends StatefulWidget {
  final Widget icon;
  final String text;
  final double size;

  const StateView({
    super.key,
    required this.icon,
    required this.text,
    this.size = AppSize.stateCardSizeL,
  });

  @override
  State<StatefulWidget> createState() => _StateViewState();
}

class _StateViewState extends State<StateView> {
  @override
  Widget build(BuildContext context) {
    var size = widget.size;
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 图标容器，处理大小和间距
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.only(bottom: AppSpace.medium),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                context.colorScheme.primary,
                BlendMode.srcIn,
              ),
              child: widget.icon,
            ),
          ),
          Text(
            widget.text,
            style: context.textTheme.titleLarge?.copyWith(
              color: context.colorScheme.secondary,

            ),
          ),
          /// 上顶100，使文本居中。
          SizedBox(
            width: size,
            height: size,
          ),
        ],
      ),
    );
  }
}