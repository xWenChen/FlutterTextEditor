
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/data_sync_service.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/data_sync_wifi_p2p_device.dart';

class DataSyncViewModel extends BaseViewModel {
  static final _tag = "DataSyncViewModel";

  bool canPop = true;

  MutableState<List<DataSyncWifiP2pDevice>> dataList = MutableState(<DataSyncWifiP2pDevice>[]);

  DataSyncService? _service = null;

  /// 初始化 -> discoverPeers -> requestPeers。
  Future<void> init() async {
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
    notifyListeners();
    return true;
  }
}