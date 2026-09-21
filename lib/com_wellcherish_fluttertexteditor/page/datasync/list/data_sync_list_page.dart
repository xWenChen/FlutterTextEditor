
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/router/route_constants.dart';

import '../../../base/arch/base_state.dart';
import '../../../base/constants/load_state.dart';
import '../../../base/constants/material3/app_space.dart';
import '../../../base/extension/build_context_extension.dart';
import '../../../base/ui/appbar/editor_app_bar.dart';
import '../../../base/ui/state_widget/empty_view.dart';
import '../../../base/ui/state_widget/loading_view.dart';
import '../../../resource/strings.dart';
import '../../../router/app_router.dart';
import '../feature/data_sync_wifi_p2p_device.dart';
import 'data_sync_list_view_model.dart';

class DataSyncListPage extends StatefulWidget {
  const DataSyncListPage({super.key});

  @override
  State<DataSyncListPage> createState() => _DataSyncListPageState();
}

class _DataSyncListPageState extends BaseState<DataSyncListViewModel, DataSyncListPage> {

  @override
  void createViewModel() {
    viewModel =  DataSyncListViewModel();
    viewModel.init();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
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
          listenable: Listenable.merge([viewModel.state, viewModel.dataList]),
          builder: (context, child) {
            switch (viewModel.state.value) {
              case LoadState.completed:
                // 展示列表
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                data.deviceName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.titleMedium?.copyWith(
                                  color: context.contentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpace.small,),
                            Text(
                              data.deviceStatusDesc,
                              style: context.textTheme.titleSmall?.copyWith(
                                color: data.deviceStatus.parseDeviceColor(context),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Container(
                          child: Text(
                            data.deviceType.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.contentColor,
                            ),
                          ),
                        ),
                        leading: Icon(
                          data.deviceType.icon,
                          color: context.contentColor,
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: context.contentColor,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                        dense: true, // 1. 开启紧凑模式，缩小默认的高度和字体间距
                        visualDensity: VisualDensity(vertical: -AppSpace.extraSmall), // 2. 将垂直方向的密度压到极致（范围 -4 到 4）
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: list.length,
                  ),
                );
              case LoadState.empty:
                return EmptyView(text: Strings.noDevice,);
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

  Future<void> onItemTap(DataSyncWifiP2pDevice? data, int index) async {
    if (data == null) {
      return;
    }
    /// todo 响应点击操作
    await context.goRouter.pushNamed(
      RouteConstants.dataSyncDetail,
      extra: data,
    );
  }
}
