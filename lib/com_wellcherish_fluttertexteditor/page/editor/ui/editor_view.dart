
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/config/app_config.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/file_save_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/string_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/editor/ui/editor_text_field.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/editor/ui/editor_text_state_tips.dart';

import '../../../resource/strings.dart';

class EditorView extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final String titleHint;
  final String contentHint;
  final FileSaveState saveState;
  final bool saveTrimText;

  EditorView({
    super.key,
    required this.titleController,
    required this.contentController,
    this.titleHint = Strings.inputTitle,
    this.contentHint = Strings.inputContent,
    this.saveState = FileSaveState.dataLoading,
    this.saveTrimText = false,
  });

  @override
  State<StatefulWidget> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  static final String _tag = "_EditorViewState";

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late ScrollController _scrollController;

  // 定义两个布尔值控制按钮状态
  bool _isAtTop = true;
  bool _isAtBottom = true;
  // 当前的最大可滚动距离。
  double currentMaxScrollExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _titleController = widget.titleController;
    // 监听文本变化，实时刷新 UI 上的叉号。
    _titleController.addListener(updateTitleUI);
    _contentController = widget.contentController;
    _contentController.addListener(updateWaitState);
    _scrollController = ScrollController();
    // 1. 添加滚动监听
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.removeListener(updateTitleUI);
    _contentController.removeListener(updateWaitState);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 标题
        EditorTextField(
          hint: widget.titleHint,
          saveTrimText: widget.saveTrimText,
          maxTextLines: 1,
          maxTextLength: AppConfig.titleTextLength,
          textStyle: context.textTheme.titleLarge,
          controller: _titleController,
          showSuffixIcon: true,
        ),
        // 状态提示
        EditorTextStateTips(
          saveState: widget.saveState,
          onClearText: _contentController.text.isNullOrEmpty ? null : () {
            _contentController.clear();
          },
          topEnable: !_isAtTop,
          bottomEnable: !_isAtBottom,
          onScroll: (scrollToTop) {
            if (scrollToTop) {
              _scrollToTop();
            } else {
              _scrollToBottom();
            }
          },
        ),
        // 正文
        Expanded(
          child: Scrollbar(
            controller: _scrollController,
            child: EditorTextField(
              hint: widget.contentHint,
              saveTrimText: widget.saveTrimText,
              textStyle: context.textTheme.bodyLarge,
              controller: _contentController,
              scrollController: _scrollController,
              expanded: true,
            ),
          ),
        ),
      ],
    );
  }

  void updateWaitState() {
    currentMaxScrollExtent = _scrollController.position.maxScrollExtent;
  }

  void updateTitleUI() {
    setState(() {});
  }

  void _scrollListener() {
    // 确保 controller 已附加到正文 TextField
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    // 这里的 0.5 是为了增加一点容错，防止因微小像素偏差无法触发
    final maxScrollExtent = _scrollController.position.maxScrollExtent - 0.5;
    // 手动控制滚动 与 TextField 自动维护光标可见性 之间存在竞态。增加误差容错。
    final minScrollExtent = _scrollController.position.minScrollExtent + 0.5;

    final newBottomState = offset >= maxScrollExtent;
    final newTopState = offset <= minScrollExtent;

    // 当前的最大滚动距离小于新的最大距离，且不在底部，则跳过这次的状态变化。
    if (!newBottomState && currentMaxScrollExtent < maxScrollExtent) {
      // 此次刷新不响应，防止滚动到底部按钮的UI抖动。
      // 问题场景：
      // 1、用户新起一行，最大可滚动高度改变。
      // 2、scrollListener回调，是否在底部状态改变，按钮可点。
      // 3、TextField滚动到用户新输入的一行，此时滚动到了底部。
      // 4、scrollListener回调，是否在底部状态改变，按钮重新变为不可点。
      // 5. 1到4步的变化极快，在用户看来就是按钮闪烁了(或者叫抖动)。
      return;
    }

    // 2. 判断是否在顶部或底部
    if (_isAtTop != newTopState || _isAtBottom != newBottomState) {
      setState(() {
        currentMaxScrollExtent = maxScrollExtent;
        _isAtTop = newTopState;
        _isAtBottom = newBottomState;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut, // 滚动曲线：缓入缓出。
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut, // 滚动曲线：缓入缓出。
    );
  }
}