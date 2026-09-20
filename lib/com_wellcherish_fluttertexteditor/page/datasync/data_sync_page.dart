
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/data_sync_wifi_p2p_device.dart';

import '../../base/arch/base_state.dart';
import '../../base/constants/material3/app_space.dart';
import '../../base/extension/build_context_extension.dart';
import '../../base/ui/appbar/editor_app_bar.dart';
import '../../resource/strings.dart';
import '../../router/app_router.dart';
import 'data_sync_view_model.dart';

class DataSyncPage extends StatefulWidget {
  const DataSyncPage({super.key});

  @override
  State<DataSyncPage> createState() => _DataSyncPageState();
}

class _DataSyncPageState extends BaseState<DataSyncViewModel, DataSyncPage> {

  @override
  void createViewModel() {
    viewModel =  DataSyncViewModel();

    viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModel: viewModel,
      appBar: EditorAppBar(
        title: Strings.dataSyncTitle,
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
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      data.deviceName,
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(width: AppSpace.small,),
                    Text(
                      data.deviceStatusDesc,
                      style: context.textTheme.titleSmall,
                    ),
                  ],
                ),
                subtitle: Container(
                  child: Text(
                    data.detailDesc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodySmall,
                  ),
                ),
                leading: Icon(Icons.devices_rounded),
                trailing: Icon(Icons.keyboard_arrow_right_rounded),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
                dense: true, // 1. 开启紧凑模式，缩小默认的高度和字体间距
                visualDensity: VisualDensity(vertical: -AppSpace.extraSmall), // 2. 将垂直方向的密度压到极致（范围 -4 到 4）
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: list.length,
          ),
        );
      },
    );
  }

  Future<void> onItemTap(DataSyncWifiP2pDevice? data, int index) async {
    if (data == null) {
      return;
    }
    /// todo 响应点击操作

  }
}
