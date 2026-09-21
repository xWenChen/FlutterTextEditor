
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';

import '../../../base/constants/load_state.dart';

class DataSyncExplainViewModel extends BaseViewModel {
  static final _tag = "DataSyncExplainViewModel";

  /// Assets 资源路径
  static const String _assetPath = 'assets/files/数据搬家说明.md';

  bool canPop = true;

  MutableState<String> text = MutableState("");

  MutableState<LoadState> state = MutableState(LoadState.none);

  /// 初始化 -> discoverPeers -> requestPeers。
  Future<void> init() async {
    state.value = LoadState.loading;
    try {
      text.value = await rootBundle.loadString(_assetPath);
    } catch (e) {
      ZLog.e(_tag, "", e);
      text.value = '无法找到或读取文件：$_assetPath';;
    }
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      state.value = LoadState.completed;
    });
  }
}