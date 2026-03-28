
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_space.dart';

import '../extension/build_context_extension.dart';
import '../ui/appbar/editor_app_bar.dart';

class BaseView<T extends BaseViewModel> extends StatefulWidget {
  final T viewModel;
  final TransitionBuilder builder;
  final EditorAppBar? appBar;
  final Widget? floatingActionButton;

  const BaseView({
    super.key,
    required this.viewModel,
    required this.builder,
    this.appBar,
    this.floatingActionButton,
  });

  @override
  State<StatefulWidget> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ?? EditorAppBar(
        backgroundColor: context.colorScheme.primaryContainer,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: widget.builder,
      ),
      // 默认就是这个位置，间距为 16
      floatingActionButtonLocation: CustomFabLocation(),
      floatingActionButton: widget.floatingActionButton,
      backgroundColor: context.colorScheme.surface,
    );
  }
}

class CustomFabLocation extends FloatingActionButtonLocation {
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    final pageSize = scaffoldGeometry.scaffoldSize;
    final buttonSize = scaffoldGeometry.floatingActionButtonSize;
    final margin = AppSpace.extraLarge;
    // 屏幕宽度 - FAB宽度 - 期望的右边距
    final double x = pageSize.width - buttonSize.width - AppSpace.extraLarge; // 距离右边 32

    // 屏幕高度 - FAB高度 - 期望的下边距
    final double y = pageSize.height - buttonSize.height - AppSpace.doubleExtraLarge; // 距离底部 64

    // FloatingActionButton 左上角的坐标。
    return Offset(x, y);
  }
}