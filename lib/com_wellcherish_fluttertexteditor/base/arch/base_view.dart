
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../extension/build_context_extension.dart';
import '../ui/appbar/editor_app_bar.dart';

class BaseView extends StatefulWidget {
  final Widget? body;
  final EditorAppBar? appBar;
  final FloatingActionButton? floatingActionButton;

  const BaseView({
    super.key,
    required this.body,
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
      body: widget.body,
      floatingActionButton: widget.floatingActionButton,
      backgroundColor: context.colorScheme.surface,
    );
  }
}