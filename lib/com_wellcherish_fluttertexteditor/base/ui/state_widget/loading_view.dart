
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/state_widget/state_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';

import '../../constants/material3/app_size.dart';
import '../../extension/build_context_extension.dart';

class LoadingView extends StatefulWidget {
  final String text;
  const LoadingView({
    super.key,
    this.text = Strings.appInitializing,
  });

  @override
  State<StatefulWidget> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1. 初始化 AnimationController，定义动画时长
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // 1秒转一圈
      vsync: this, // 防止屏幕外动画消耗资源
    );
    // 2. 开始无限循环动画
    // repeat() 默认使用线性插值 (LinearEasing)，且 RepeatMode 为 Restart
    _controller.repeat();
  }

  @override
  void dispose() {
    // 3. 销毁控制器，释放资源
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. 直接使用 RotationTransition
    // 它接收一个 Animation<double> (此处即 _controller)，并自动应用旋转
    // 这里的 turns 参数：0.0 代表 0度，1.0 代表 360度
    return StateView(
      icon: RotationTransition(
        turns: _controller,
        child: Image(
          width: AppSize.stateCardSizeM,
          height: AppSize.stateCardSizeM,
          image: AssetImage("assets/images/ic_loading.png"),
        ),
      ),
      text: widget.text,
    );
  }
}

