
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_size.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_space.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/state_widget/empty_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/state_widget/loading_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/home/home_view_model.dart';

import '../../base/constants/load_state.dart';
import '../../resource/strings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BaseState<HomeViewModel, HomePage> {
  @override
  void createViewModel() {
    viewModel =  HomeViewModel();
    viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final fabSize = AppSize.fabSize;
    final addIconSize = fabSize - AppSpace.large;
    return BaseView(
      viewModel: viewModel,
      builder: (context, child) {
        switch (viewModel.state) {
          case LoadState.completed:
            // 展示列表
            return SizedBox.shrink();
          case LoadState.empty:
            return EmptyView();
          case LoadState.error:
            return EmptyView(text: Strings.dataError,);
          default:
            return LoadingView(text: Strings.dataLoading,);
        }
      },
      floatingActionButton: SizedBox(
        width: fabSize,
        height: fabSize,
        child: FloatingActionButton(
          onPressed: () {
            /// 进入创建文本文件的页面。
          },
          shape: CircleBorder(),
          child: Icon(
            Icons.add_rounded,
            size: addIconSize,
          ),
        ),
      ),
    );
  }
}