
import 'dart:async';
import 'dart:io';

import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/config/app_config.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/bean/file_item.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/data/file_data_source.dart';

import '../../base/bean/file_data.dart';
import '../../base/constants/file_change_type.dart';
import '../../base/constants/file_save_state.dart';
import '../../base/file/editor_file_utils.dart';
import '../../base/file/file_manager.dart';
import '../../base/log/log.dart';

class EditorViewModel extends BaseViewModel {
  static final _tag = "EditorViewModel";

  final _dataSource = FileDataSource();

  FileSaveState saveState = FileSaveState.saved;
  FileChangeType fileChangeType = FileChangeType.unknown;

  FileData? currentOpenFile;

  File? file;
  String Function() getTitle;
  String Function() getContent;
  void Function() onFail;

  Timer? _timer;
  String _lastSavedTitle = "";
  String _lastSavedContent = "";

  EditorViewModel({
    required this.getTitle,
    required this.getContent,
    required this.onFail,
    this.file,
  });

  Future<void> init(String? contentId) async {
    if (contentId == null) {
      // 没有从上个页面传入文件信息，则视作新建 txt。
      await openNewFile();
    } else {
      currentOpenFile = await _dataSource.queryByContentId(contentId);
      await openExistFile();
    }
  }

  Future<void> openNewFile() async {
    final contentId = EditorFileUtils.getUUID();
    file = await EditorFileUtils.getNewTxtFile(fileName: contentId);
    currentOpenFile = FileData(
      fileItem: FileItem(
        contentId: contentId,
        updateTime: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    _lastSavedTitle = "";
    _lastSavedContent = "";
    notifyListeners();
  }

  Future<void> openExistFile() async {
    final fileData = currentOpenFile;
    if (fileData == null) {
      return;
    }

    file = File(fileData.fileItem?.filePath ?? '');
    if (!(await file?.exists() ?? false)) {
      await file?.create();
    }
    _lastSavedTitle = fileData.title ?? "";
    _lastSavedContent = fileData.content ?? "";
    notifyListeners();
  }

  /// 文件已经保存了，才允许直接退出。
  bool get canPop {
    return saveState == FileSaveState.saved;
  }

  bool get isSaving {
    return saveState == FileSaveState.saving;
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    currentOpenFile = null;
    fileChangeType = FileChangeType.unknown;
  }

  /// 更新保存状态并通知 UI
  void changeContentSaveState(FileSaveState newState) {
    if (saveState == newState) return;
    saveState = newState;
    notifyListeners();
  }

  /// 开启定时任务
  void startAutoSave() {
    // 每隔 5 秒执行一次
    _timer = Timer.periodic(Duration(seconds: AppConfig.editorAutoSaveDuration), (timer) async {
      await trySave();
    });
  }

  Future<void> trySave() async {
    // 正在保存中，不重复保存。
    if (isSaving) return;

    saveState = FileSaveState.saving;

    String currentTitle = getTitle();
    String currentText = getContent();

    // 判断是否有变更
    if (currentTitle != _lastSavedTitle || currentText != _lastSavedContent) {
      print("内容已变更，准备存入文件...");
      await saveToFile(currentTitle, currentText);
      // 更新数据库。
      //await _dataSource.insertOrUpdateOne(data);
      // 更新最后一次保存的内容
      _lastSavedTitle = currentTitle;
      _lastSavedContent = currentText;
    }

    saveState = FileSaveState.saved;
  }

  Future<void> saveToFile(String title, String content) async {
    var finalText = EditorFileUtils.concatTitleAndText(title, content);
    var finalFile = await _getFile();
    await FileManager.instance.tryWriteFileByFile(finalFile, finalText);
  }

  Future<File?> _getFile() async {
    if (file != null) {
      return file!;
    }
    ZLog.d(_tag, "_checkFile, file=null");
    return await EditorFileUtils.getNewTxtFile();
  }
}