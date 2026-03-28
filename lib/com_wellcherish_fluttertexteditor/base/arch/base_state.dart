
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';

abstract class BaseState<VM extends BaseViewModel, W extends StatefulWidget> extends State<W> {
  // 在 State 中持有 ViewModel 实例
  late final VM viewModel;

  void createViewModel();

  @override
  void initState() {
    super.initState();
    createViewModel();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}