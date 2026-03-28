
import 'dart:io';

import 'package:drift/backends.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/app_init_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/file_item_database.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class SplashViewModel extends BaseViewModel {
  static final _tag = "SplashViewModel";
  /// 应用的初始化状态
  AppInitState state = AppInitState.none;

  Future<void> initApp() async {
    try {
      updateAppInitState(AppInitState.running);
      /// 初始化数据库。
      await _initDatabase();
      updateAppInitState(AppInitState.completed);
    } catch (e, stackTrace) {
      ZLog.e(_tag, error: e, stackTrace: stackTrace);
      updateAppInitState(AppInitState.error);
    }
  }

  Future<void> _initDatabase() async {
    QueryExecutor queryExecutor;
    if (kIsWeb) {
      /// web平台
      queryExecutor = await _openWasmConnection();
    } else {
      queryExecutor = await _openNativeConnection();
    }
    FileItemDatabase.initialize(queryExecutor);
  }

  Future<DelegatedDatabase> _openNativeConnection() async {
    /// 1. 获取基础文档目录
    final dir = await getApplicationDocumentsDirectory();
    /// 2. 构造自定义子目录路径 (例如: .../app_docs/database)
    final dbFileDir = Directory(path.join(dir.path, "database"));
    /// 3. 检测并创建目录
    /// recursive: true 确保如果父目录不存在也会一并创建
    if (!await dbFileDir.exists()) {
      await dbFileDir.create(recursive: true);
    }

    /// 4. 指定数据库文件完整路径
    final file = File(path.join(dbFileDir.path, "file_sqlite_db.db"));
    if (!await file.exists()) {
      await file.create();
    }

    /// 5. 返回 NativeDatabase 实例
    return NativeDatabase(file);
  }

  /// web平台数据库。
  Future<LazyDatabase> _openWasmConnection() async {
    return LazyDatabase(() async {
      final result = await WasmDatabase.open(
        databaseName: "file_sqlite_db.db", // IndexedDB 中的数据库名
        sqlite3Uri: Uri.parse("sqlite3.wasm"),
        driftWorkerUri: Uri.parse("drift_worker.js"),
      );

      // 如果浏览器支持 Web Worker，Drift 会自动使用它
      if (result.missingFeatures.isNotEmpty) {
        ZLog.w(_tag, "警告：当前浏览器缺少部分 Web 功能: ${result.missingFeatures}");
      }

      return result.resolvedExecutor;
    });
  }

  void updateAppInitState(AppInitState newState) {
    state = newState;
    /// 通知页面更新
    notifyListeners();
  }
}