
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/state_widget/loading_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/home/home_view_model.dart';

import '../../resource/strings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BaseState<HomeViewModel, HomePage> {
  @override
  HomeViewModel createViewModel() {
    return HomeViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModel: viewModel,
      builder: (context, child) {
        return LoadingView(text: Strings.dataLoading,);
        /*switch (viewModel.state) {
          case LoadState.completed:
            // 展示列表
            return SizedBox.shrink();
          case LoadState.error:
            return EmptyView();
          default:
            return LoadingView(text: Strings.dataLoading,);
        }*/
      },
    );
  }
}