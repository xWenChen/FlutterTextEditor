
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/settings/settings_item.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/settings/settings_view_model.dart';

import '../../base/arch/base_state.dart';
import '../../base/constants/material3/app_space.dart';
import '../../base/extension/build_context_extension.dart';
import '../../base/ui/appbar/editor_app_bar.dart';
import '../../router/app_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends BaseState<SettingsViewModel, SettingsPage> {


  @override
  void createViewModel() {
    viewModel =  SettingsViewModel();

    // 注册帧末尾回调
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // 当前帧渲染完成后，安全地调用 setState 刷新下一帧
      viewModel.tryUpdate();
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModel: viewModel,
      appBar: EditorAppBar(
        handleBack: () async {
          AppRouter.handleBack(context);
        },
        actions: () => <Widget>[],
      ),
      builder: (context, child) {
        final list = viewModel.dataList.value;
        return Container(
          padding: EdgeInsets.only(
            top: AppSpace.extraSmall,
            bottom: AppSpace.medium,
            left: AppSpace.medium,
            right: AppSpace.medium,
          ),
          child: ListView.separated(
            itemBuilder: (context, index) {
              var data = list[index];
              return ListTile(
                onTap: () async {
                  if (mounted) {
                    await onItemTap(data, index);
                  }
                },
                title: Text(
                  data.name,
                  style: context.textTheme.titleLarge,
                ),
                subtitle: Container(
                  padding: EdgeInsets.only(top: AppSpace.extraSmall),
                  child: Text(
                    data.desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge,
                  ),
                ),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: list.length,
          ),
        );
      },
    );
  }

  Future<void> onItemTap(SettingsItem? settingsItem, int index) async {
    if (settingsItem == null) {
      return;
    }
    /// 非选择模式，跳转页面。
    await context.goRouter.pushNamed(settingsItem.pageRouteName);
  }
}