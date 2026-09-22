
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';

import '../../../base/constants/load_state.dart';
import '../../../base/log/log.dart';

class DataSyncExplainViewModel extends BaseViewModel {
  static final _tag = "DataSyncExplainViewModel";

  /// Assets 资源路径
  static const String _assetPath = 'assets/files/数据搬家说明.md';

  bool canPop = true;

  // 分批加载的文本列表。
  MutableState<List<String>> textList = MutableState(<String>[]);

  MutableState<LoadState> state = MutableState(LoadState.none);

  /// 初始化 -> discoverPeers -> requestPeers。
  Future<void> init() async {
    state.value = LoadState.loading;
    textList.value = await _loadTextAsList(_assetPath);
    WidgetsBinding.instance.addPostFrameCallback((callback) {
      state.value = LoadState.completed;
    });
  }

  static Future<List<String>> _loadTextAsList(String filePath) async {
    String content;
    try {
      content = await rootBundle.loadString(filePath);
    } on Exception catch (e) {
      ZLog.e(_tag, "", e);
      content = '无法找到或读取文件：$filePath';
    }
    return content.split('\n');
  }
}