import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/file_save_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/appbar/editor_app_bar.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/editor/ui/editor_view.dart';

import '../../base/arch/base_view.dart';
import '../../base/constants/material3/app_space.dart';
import '../../resource/strings.dart';
import 'editor_view_model.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends BaseState<EditorViewModel, EditorPage> {

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void createViewModel() {
    viewModel = EditorViewModel(
      getTitle: ()  => _titleController.text,
      getContent: () => _contentController.text,
      onFail: () =>_showSaveErrorTip(),
    );

    _titleController = TextEditingController();
    _contentController = TextEditingController();

    viewModel.init();

    viewModel.startAutoSave();
  }

  @override
  void initState() {
    super.initState();
    // 监听文本变化，实时刷新 UI 上的叉号。
    _titleController.addListener(onTitleChanged);
    _contentController.addListener(onContentChanged);

  }

  @override
  void dispose() {
    super.dispose();
    _titleController.removeListener(onTitleChanged);
    _titleController.dispose();
    _contentController.addListener(onContentChanged);
    _contentController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModel: viewModel,
      canPop: viewModel.canPop,
      onPopInvokedWithResult: handleBack,
      appBar: EditorAppBar(
        handleBack: () async {
          handleBack(viewModel.canPop, null);
        },
      ),
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.only(
            top: AppSpace.extraSmall,
            bottom: AppSpace.medium,
            left: AppSpace.medium,
            right: AppSpace.medium,
          ),
          child: EditorView(
            titleController: _titleController,
            contentController: _contentController,
            saveState: viewModel.saveState,
          ),
        );
      },
    );
  }

  Future<void> handleBack(bool didPop, Object? result) async {
    // 如果页面已经退出了（didPop 为 true），则不执行逻辑
    if (didPop) return;

    // 执行保存操作
    await viewModel.trySave();
  }

  void onTitleChanged() {
    setState(() {
      viewModel.changeContentSaveState(FileSaveState.unsaved);
    });
  }

  void onContentChanged() {
    setState(() {
      viewModel.changeContentSaveState(FileSaveState.unsaved);
    });
  }

  void _showSaveErrorTip() {
    // 在按钮点击或其他事件中调用
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(Strings.saveFail),
      ),
    );
  }
}