import 'package:flutter/material.dart';
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
import 'util/fast_simple_markdown.dart';

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
          listenable: Listenable.merge([viewModel.state, viewModel.textList]),
          builder: (context, child) {
            switch (viewModel.state.value) {
              case LoadState.completed:
                // 读取成功，渲染 Markdown
                final content = viewModel.textList.value;

                return Container(
                  padding: EdgeInsets.only(
                    top: AppSpace.medium,
                    bottom: AppSpace.medium,
                    left: AppSpace.medium,
                    right: AppSpace.medium,
                  ),
                  child: FastSimpleMarkdown(textList: content,),
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