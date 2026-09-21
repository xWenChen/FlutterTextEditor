import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/explain/data_sync_explain_view_model.dart';

import '../../../base/constants/load_state.dart';
import '../../../base/constants/material3/app_space.dart';
import '../../../base/extension/build_context_extension.dart';
import '../../../base/ui/appbar/editor_app_bar.dart';
import '../../../base/ui/state_widget/empty_view.dart';
import '../../../base/ui/state_widget/loading_view.dart';
import '../../../resource/strings.dart';
import '../../../router/app_router.dart';

/// 数据搬家说明文档页面
class DataSyncExplainPage extends StatefulWidget {
  const DataSyncExplainPage({super.key});

  @override
  State<DataSyncExplainPage> createState() => _DataSyncExplainPageState();
}

class _DataSyncExplainPageState extends BaseState<DataSyncExplainViewModel, DataSyncExplainPage> {
  @override
  void createViewModel() {
    viewModel = DataSyncExplainViewModel();
    viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: EditorAppBar(
          title: Strings.dataSyncTitle,
          handleBack: () async {
            AppRouter.handleBack(context);
          },
          actions: () => <Widget>[],
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([viewModel.state, viewModel.text]),
          builder: (context, child) {
            switch (viewModel.state.value) {
              case LoadState.completed:
                // 读取成功，渲染 Markdown
                final String markdownContent = viewModel.text.value;

                return Container(
                  padding: EdgeInsets.only(
                    bottom: AppSpace.medium,
                    left: AppSpace.medium,
                    right: AppSpace.medium,
                  ),
                  child: Markdown(
                    data: markdownContent,
                    selectable: true, // 支持文本长按复制
                    styleSheet: buildCustomMarkdownStyle(context), // 自定义 Markdown 页面精细化排版样式
                  ),
                );
              case LoadState.empty:
                return EmptyView(text: Strings.noData,);
              case LoadState.error:
                return EmptyView(
                  text: Strings.dataError,
                );
              default:
                return LoadingView(
                  text: Strings.dataLoading,
                );
            }
          },
        ),
        backgroundColor: context.appBackground,
      ),
    );
  }
}
// 封装一个构建全局 Markdown 样式的函数
MarkdownStyleSheet buildCustomMarkdownStyle(BuildContext context) {
  final theme = Theme.of(context);
  // 定义主色调（可按需替换为任意颜色，如 Colors.teal / Color(0xFF1E88E5)）
  final primaryColor = context.contentColor;

  return MarkdownStyleSheet.fromTheme(theme).copyWith(
    // ----------------- 1. 全局正文与文本颜色 -----------------
    p: TextStyle(
      color: primaryColor, // 正文主颜色
    ),
    // ----------------- 2. 各级标题字号与主色调 -----------------
    h1: TextStyle(
      color: primaryColor,   // 统一应用主色调
    ),
    h2: TextStyle(
      color: primaryColor,
    ),
    h3: TextStyle(
      color: primaryColor,
    ),
  );
}