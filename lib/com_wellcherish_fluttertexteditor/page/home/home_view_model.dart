
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/bean/file_item.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/data/file_data_source.dart';
import '../../base/constants/load_state.dart';

class HomeViewModel extends BaseViewModel {
  static final _tag = "HomeViewModel";
  List<FileItem> dataList = List.empty();
  final _dataSource = FileDataSource();
  LoadState state = LoadState.none;

  Future<void> load() async {
    try {
      updateAppInitState(LoadState.loading);
      /// 加载数据列表。
      final existData = await _loadFromDb();
      if (existData) {
        updateAppInitState(LoadState.completed);
      } else {
        updateAppInitState(LoadState.empty);
      }
    } catch (e, stackTrace) {
      ZLog.e(_tag, error: e, stackTrace: stackTrace);
      updateAppInitState(LoadState.error);
    }
  }

  Future<bool> _loadFromDb() async {
    dataList = await _dataSource.queryAll();
    return dataList.isNotEmpty;
  }

  void updateAppInitState(LoadState newState) {
    state = newState;
    /// 通知页面更新
    notifyListeners();
  }
}