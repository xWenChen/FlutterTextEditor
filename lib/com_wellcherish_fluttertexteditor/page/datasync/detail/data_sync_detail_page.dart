
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view.dart';

import '../../../base/arch/base_state.dart';
import '../../../base/constants/material3/app_space.dart';
import '../../../base/ui/appbar/appbar_info_item.dart';
import '../../../base/ui/appbar/editor_app_bar.dart';
import '../../../resource/strings.dart';
import '../../../router/app_router.dart';
import '../../../router/route_constants.dart';
import '../feature/data_sync_wifi_p2p_device.dart';
import 'data_sync_detail_view_model.dart';

class DataSyncDetailPage extends StatefulWidget {
  final DataSyncWifiP2pDevice currentDevice;
  const DataSyncDetailPage({
    super.key,
    required this.currentDevice,
  });

  @override
  State<DataSyncDetailPage> createState() => _DataSyncDetailPageState();
}

class _DataSyncDetailPageState extends BaseState<DataSyncDetailViewModel, DataSyncDetailPage> {

  @override
  void createViewModel() {
    viewModel =  DataSyncDetailViewModel();
    viewModel.init(widget.currentDevice);
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
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
        actions: () => <Widget>[AppbarInfoItem(pageName: RouteConstants.dataSyncExplain)],
      ),
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.only(
            top: AppSpace.extraSmall,
            bottom: AppSpace.medium,
            left: AppSpace.medium,
            right: AppSpace.medium,
          ),
          alignment: Alignment.center,
          child: SizedBox(),
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
