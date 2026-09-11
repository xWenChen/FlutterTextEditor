import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/bean/file_data.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/file_item_database.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/utils/dialog_utils.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/data/file_data_source.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';
import 'package:go_router/go_router.dart';
import '../../base/constants/load_state.dart';

class HomeViewModel extends BaseViewModel {
  static final _tag = "HomeViewModel";

  late final _dataSource;

  MutableState<List<FileData>> dataList = MutableState(List.empty());

  MutableState<bool> isSelectionMode = MutableState(false);

  MutableState<LoadState> state = MutableState(LoadState.none);

  DateTime? _lastPressedTime;

  Future<void> init() async {
    /// 数据库初始化后，dataSource才能正常使用。
    await FileItemDatabase.initialize();
    _dataSource = FileDataSource();
    await load();
  }

  Future<void> load() async {
    try {
      updateAppInitState(LoadState.loading);
      final existData = await _loadFromDb();
      if (existData) {
        // 关键：等待当前帧结束后，再触发状态变更，让 Flutter 有喘息和准备的时间。避免刷新冲突，页面出现闪烁。
        WidgetsBinding.instance.addPostFrameCallback((_) {
          updateAppInitState(LoadState.completed);
        });

      } else {
        updateAppInitState(LoadState.empty);
      }
    } catch (e, stackTrace) {
      ZLog.e(_tag, "", e, stackTrace);
      updateAppInitState(LoadState.error);
    }
  }

  Future<bool> _loadFromDb() async {
    // 保证 dataList 是一个可修改的新 List
    final list = await _dataSource.queryAll();
    dataList.value = List<FileData>.of(list);
    return dataList.value.isNotEmpty;
  }

  void updateAppInitState(LoadState newState) {
    state.value = newState;
  }

  /// 切换 Item 选中状态：新建 FileData 对象，并生成新 List
  Future<void> selectItem(FileData? fileData, int index, bool oldSelected) async {
    if (fileData == null || index < 0 || index >= dataList.value.length) return;

    if (!isSelectionMode.value) {
      isSelectionMode.value = true;
    }

    // 1. 创建全新的 FileData 对象并替换状态
    final newItem = fileData.copyWith(itemSelected: !oldSelected);

    // 2. 生成全新的 List 数组，触发 Flutter 的引用变更感知
    final newList = List<FileData>.of(dataList.value);
    newList[index] = newItem;
    dataList.value = newList;
  }

  Future<bool> tryDeleteSelectedItems(BuildContext context) async {
    return await DialogUtils.showConfirmDialog(
      context,
      confirmText: Strings.delete,
      onConfirmTap: () async => await deleteSelectedItems(),
    );
  }

  /// 删除选中项：通过 where/toList 创建新集合
  Future<bool> deleteSelectedItems() async {
    // 1. 获取所有选中的数据集合
    final selectedList = dataList.value.where((data) => data.itemSelected).toList();
    if (selectedList.isEmpty) {
      return false;
    }

    // 2. 执行数据库/本地文件删除（传入选中的集合）
    final result = await _dataSource.deleteSelectedItems(selectedList);

    if (result) {
      // 3. 过滤掉被删掉的项，生成全新的 List
      dataList.value = dataList.value.where((data) => !data.itemSelected).toList();

      // 如果删光了，可自动切换状态或退出多选模式
      if (dataList.value.isEmpty) {
        isSelectionMode.value = false;
        state.value = LoadState.empty;
      } else {
        // 删除完成后检查是否还存在选中项，无选中项则退出选择模式
        final hasSelected = dataList.value.any((data) => data.itemSelected);
        if (!hasSelected) {
          isSelectionMode.value = false;
        }
      }
    }
    return result;
  }

  /// 退出选择模式：批量生成未选中的全新对象与全新 List
  Future<void> exitSelectionMode() async {
    if (!isSelectionMode.value) return;

    // 将所有选中的项全部替换为全新的反选对象
    dataList.value = dataList.value.map((data) {
      if (data.itemSelected) {
        return data.copyWith(itemSelected: false);
      }
      return data;
    }).toList();

    isSelectionMode.value = false;
  }

  Future<void> tryPop(BuildContext context, bool didPop, dynamic result) async {
    if (didPop) return;

    if (isSelectionMode.value) {
      exitSelectionMode();
      return;
    }

    final now = DateTime.now();
    if (_lastPressedTime == null || now.difference(_lastPressedTime!) > const Duration(seconds: 2)) {
      _lastPressedTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Strings.pressToExitApp,
            style: context.textTheme.titleMedium?.merge(
              TextStyle(
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          duration: Duration(seconds: 2),
          backgroundColor: context.colorScheme.primaryContainer,
        ),
      );
      return;
    }

    await SystemNavigator.pop();
  }
}