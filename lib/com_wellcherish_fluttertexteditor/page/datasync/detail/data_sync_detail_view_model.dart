
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/device_status.dart';

import '../feature/data_sync_service.dart';
import '../feature/data_sync_wifi_p2p_device.dart';

class DataSyncDetailViewModel extends BaseViewModel {
  static final _tag = "DataSyncDetailViewModel";

  bool canPop = true;

  MutableState<DataSyncWifiP2pDevice> data = MutableState(DataSyncWifiP2pDevice());
  MutableState<DeviceStatus> deviceStatus = MutableState(DeviceStatus.unavailable);

  DataSyncService? _service = null;

  /// 初始化 -> discoverPeers -> requestPeers。
  Future<void> init(DataSyncWifiP2pDevice currentDevice) async {
    /// 开始扫描、获取设备列表。
    final service = DataSyncService();
    service.registerDeviceUpdateCallback(updateDevices);
    _service = service;
    data.value = currentDevice;
    notifyListeners();
  }

  Future<void> dispose() async {
    _service?.unregisterDeviceUpdateCallback(updateDevices);
    _service = null;
  }

  Future<bool> updateDevices(Map<String, DataSyncWifiP2pDevice> deviceMap) async {
    final currentDevice = deviceMap[data.value.deviceAddress];
    if (currentDevice == null) {
      return false;
    }
    // 关键：等待当前帧结束后，再触发状态变更，让 Flutter 有喘息和准备的时间。避免刷新冲突，页面出现闪烁。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      data.value = currentDevice;
      deviceStatus.value = currentDevice.deviceStatus;
      notifyListeners();
    });
    return true;
  }
}