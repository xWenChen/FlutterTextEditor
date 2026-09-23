
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';

import '../../../base/arch/base_state.dart';
import '../../../base/constants/material3/app_shapes.dart';
import '../../../base/constants/material3/app_space.dart';
import '../feature/data_sync_wifi_p2p_device.dart';
import 'data_sync_detail_view_model.dart';

// 当前页面时作为 Dialog 展示，不用写完整的脚手架信息。
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
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.currentDevice;
    return Dialog(
      // 设置圆角样式
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppShapes.large),),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSpace.medium),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "连接设备并发送内容",
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.contentColor,
              ),
            ),
            SizedBox(height: AppSpace.small,),
            // 正文
            Text.rich(
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.contentColor,
              ),
              TextSpan(
                children: [
                  const TextSpan(text: "是否连接设备 "),
                  TextSpan(
                    text: device.deviceName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.tertiary, // 可选：突出强调
                    ),
                  ),
                  const TextSpan(text: ' 并向其发送文本？'),
                ],
              ),
            ),
            SizedBox(height: AppSpace.medium,),
            // 按钮
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.onTertiary,
                backgroundColor: context.colorScheme.tertiary,
                // 设置边框形状为操场跑道/胶囊形
                shape: const StadiumBorder(),
                // 建议加点左右 padding，让跑道形状更舒展
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.large, vertical: AppSpace.extraSmall),
              ),
              child: const Text('连接并发送'),
            ),
            SizedBox(height: AppSpace.extraSmall,),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.onError,
                backgroundColor: context.colorScheme.error,
                // 设置边框形状为操场跑道/胶囊形
                shape: const StadiumBorder(),
                // 建议加点左右 padding，让跑道形状更舒展
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.large, vertical: AppSpace.extraSmall),
              ),
              child: const Text('取消'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> onItemTap(DataSyncWifiP2pDevice? data, int index) async {
    if (data == null) {
      return;
    }
    /// todo 响应点击操作
  }
}
