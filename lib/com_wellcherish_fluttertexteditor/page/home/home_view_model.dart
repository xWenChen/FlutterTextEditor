
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';
import '../../base/constants/load_state.dart';

class HomeViewModel extends BaseViewModel {
  static final _tag = "HomeViewModel";
  LoadState state = LoadState.none;

  Future<void> load() async {
    try {
      updateAppInitState(LoadState.loading);
      /// 初始化数据库。
      await _loadFromDb();
      updateAppInitState(LoadState.completed);
    } catch (e, stackTrace) {
      ZLog.e(_tag, error: e, stackTrace: stackTrace);
      updateAppInitState(LoadState.error);
    }
  }

  Future<void> _loadFromDb() async {

  }

  void updateAppInitState(LoadState newState) {
    state = newState;
    /// 通知页面更新
    notifyListeners();
  }
}