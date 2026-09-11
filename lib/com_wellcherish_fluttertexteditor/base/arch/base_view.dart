
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
  // canPop=false时，用户需要点击两次返回按钮，才能退出应用。
  final bool Function()? canPop;
  final PopInvokedWithResultCallback? onPopInvokedWithResult;

  const BaseView({
    super.key,
    required this.viewModel,
    required this.builder,
    this.appBar,
    this.floatingActionButton,
    this.canPop,
    this.onPopInvokedWithResult,
  });

  @override
  State<StatefulWidget> createState() => _BaseViewState();
}

class _BaseViewState extends State<BaseView> {
  @override
  Widget build(BuildContext context) {
    // 整个 Scaffold 监听 viewModel，保证 appBar、floatingActionButton 和 body 都能实时响应通知
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, child) {
        return PopScope(
          canPop: widget.canPop?.call() ?? true,
          onPopInvokedWithResult: widget.onPopInvokedWithResult,
          child: Scaffold(
            appBar: widget.appBar ?? EditorAppBar(),
            body: widget.builder(context, child),
            floatingActionButtonLocation: CustomFabLocation(),
            floatingActionButton: widget.floatingActionButton,
            backgroundColor: context.appBackground,
          ),
        );
      },
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
    final double y = pageSize.height - buttonSize.height - AppSpace.large80; // 距离底部 64

    // FloatingActionButton 左上角的坐标。
    return Offset(x, y);
  }
}