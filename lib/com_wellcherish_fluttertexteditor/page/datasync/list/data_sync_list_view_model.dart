
import 'package:flutter/cupertino.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';

import '../../../base/constants/load_state.dart';
import '../feature/data_sync_service.dart';
import '../feature/data_sync_wifi_p2p_device.dart';

class DataSyncListViewModel extends BaseViewModel {
  static final _tag = "DataSyncListViewModel";

  bool canPop = true;

  MutableState<List<DataSyncWifiP2pDevice>> dataList = MutableState(<DataSyncWifiP2pDevice>[]);

  MutableState<LoadState> state = MutableState(LoadState.none);

  DataSyncService? _service = null;

  /// 初始化 -> discoverPeers -> requestPeers。
  Future<void> init() async {
    state.value = LoadState.loading;
    /// 开始扫描、获取设备列表。
    final service = DataSyncService();
    service.registerDeviceUpdateCallback(updateDevices);
    service.init();
    _service = service;
  }

  Future<void> dispose() async {
    await _service?.release();
    _service?.unregisterDeviceUpdateCallback(updateDevices);
    _service = null;
  }

  Future<bool> updateDevices(Map<String, DataSyncWifiP2pDevice> deviceMap) async {
    final list = deviceMap.values.toList();
    dataList.value = list;
    // 关键：等待当前帧结束后，再触发状态变更，让 Flutter 有喘息和准备的时间。避免刷新冲突，页面出现闪烁。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (list.isEmpty) {
        state.value = LoadState.empty;
      } else {
        state.value = LoadState.completed;
      }
    });
    notifyListeners();
    return true;
  }
}