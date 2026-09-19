import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/data_sync_wifi_p2p_device.dart';

class DataSyncViewModel extends BaseViewModel {
  static final _tag = "DataSyncViewModel";

  bool canPop = true;

  MutableState<List<DataSyncWifiP2pDevice>> dataList = MutableState(<DataSyncWifiP2pDevice>[]);

  Future<void> init() async {
    /// 开始扫描、获取设备列表。

  }
}