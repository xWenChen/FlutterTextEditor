
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/app_init_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/file_item_database.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';

class SplashViewModel extends BaseViewModel {
  static final _tag = "SplashViewModel";
  /// 应用的初始化状态
  AppInitState state = AppInitState.none;

  Future<void> initApp() async {
    try {
      updateAppInitState(AppInitState.running);
      /// 初始化数据库。
      FileItemDatabase.initialize();
      updateAppInitState(AppInitState.completed);
    } catch (e, stackTrace) {
      ZLog.e(_tag, error: e, stackTrace: stackTrace);
      updateAppInitState(AppInitState.error);
    }
  }

  void updateAppInitState(AppInitState newState) {
    state = newState;
    /// 通知页面更新
    notifyListeners();
  }
}