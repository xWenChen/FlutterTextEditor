
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';

import '../extension/build_context_extension.dart';
import '../ui/appbar/editor_app_bar.dart';

class BaseView<T extends BaseViewModel> extends StatefulWidget {
  final T viewModel;
  final TransitionBuilder builder;
  final EditorAppBar? appBar;
  final FloatingActionButton? floatingActionButton;

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
      floatingActionButton: widget.floatingActionButton,
      backgroundColor: context.colorScheme.surface,
    );
  }
}