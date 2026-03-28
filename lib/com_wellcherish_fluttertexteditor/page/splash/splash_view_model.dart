
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
      /// 初始化数据库。最小等待2秒。
      // 并发执行：业务逻辑 vs 固定倒计时
      await Future.wait([
        FileItemDatabase.initialize(), // 你的业务初始化逻辑
        Future.delayed(const Duration(seconds: 2)), // 强制等待 2 秒
      ]);
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