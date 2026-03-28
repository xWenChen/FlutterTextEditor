import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/app_init_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/state_widget/empty_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/state_widget/loading_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/splash/splash_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/router/route_constants.dart';

import '../../base/arch/base_view.dart';
import '../../base/extension/build_context_extension.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends BaseState<SplashViewModel, SplashPage> {

  @override
  SplashViewModel createViewModel() {
    return SplashViewModel();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModel: viewModel,
      builder: (context, child) {
        switch (viewModel.state) {
          case AppInitState.completed:
            // 进入下个页面，并将本页面从堆栈中移除。
            context.goRouter.go(RouteConstants.home);
            return SizedBox.shrink();
          case AppInitState.error:
            return EmptyView();
          default:
            return LoadingView();
        }
      },
    );
  }
}