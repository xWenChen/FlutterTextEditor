
import 'dart:async';
import 'dart:io';

import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/config/app_config.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/database/bean/file_item.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/file_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/utils/EventManager.dart';
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

  FileData? currentFileData;

  File? file;
  String Function() getTitle;
  String Function() getContent;
  void Function() updateText;
  void Function() onFail;

  Timer? _timer;
  String lastSavedTitle = "";
  String lastSavedContent = "";

  bool isBacking = false;

  EditorViewModel({
    required this.getTitle,
    required this.getContent,
    required this.updateText,
    required this.onFail,
    this.file,
  });

  Future<void> init(String? contentId) async {
    changeContentSaveState(FileSaveState.dataLoading);
    if (contentId == null) {
      // 没有从上个页面传入文件信息，则视作新建 txt。
      await openNewFile();
    } else {
      currentFileData = await _dataSource.queryByContentId(contentId);
      await openExistFile();
    }
    changeContentSaveState(FileSaveState.saved);
  }

  Future<void> openNewFile() async {
    final contentId = EditorFileUtils.getUUID();
    file = await EditorFileUtils.getNewTxtFile(fileName: contentId);
    currentFileData = FileData(
      fileItem: FileItem(
        contentId: contentId,
        updateTime: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    lastSavedTitle = "";
    lastSavedContent = "";
    updateText();
  }

  Future<void> openExistFile() async {
    final fileData = currentFileData;
    if (fileData == null) {
      return;
    }

    file = File(fileData.fileItem?.filePath ?? '');
    if (!(await file?.exists() ?? false)) {
      await file?.create();
    }
    lastSavedTitle = fileData.title ?? "";
    lastSavedContent = fileData.content ?? "";
    updateText();
  }

  /// 文件已经保存了，才允许直接退出。
  bool get saved {
    return saveState == FileSaveState.saved;
  }

  bool get isSaving {
    return saveState == FileSaveState.saving;
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
    currentFileData = null;
  }

  bool titleSame(String title) {
    return lastSavedTitle == title;
  }

  bool contentSame(String content) {
    return lastSavedContent == content;
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
    String currentTitle = getTitle();
    String currentText = getContent();

    if (currentTitle == lastSavedTitle && currentText == lastSavedContent) {
      return;
    }

    // 正在保存中，不重复保存。
    if (isSaving) return;

    changeContentSaveState(FileSaveState.saving);

    // 判断是否有变更
    final ok = await saveToFile(currentTitle, currentText);
    if (!ok) {
      ZLog.e(_tag, "trySave file failed");
      changeContentSaveState(FileSaveState.saved);
      return;
    }

    final data = currentFileData;
    if (data == null) {
      ZLog.e(_tag, "trySave file failed, data = null");
      changeContentSaveState(FileSaveState.saved);
      return;
    }
    final dbItem = data.fileItem;
    if (dbItem == null) {
      ZLog.e(_tag, "trySave file failed, dbItem = null");
      changeContentSaveState(FileSaveState.saved);
      return;
    }

    // 更新数据库。
    data.content = currentText;

    dbItem
      ..title = currentTitle
      ..filePath = file?.absolutePath
      ..updateTime = DateTime.now().millisecondsSinceEpoch;

    await _dataSource.insertOrUpdateOne(dbItem);

    // 更新最后一次保存的内容
    lastSavedTitle = currentTitle;
    lastSavedContent = currentText;

    EventManager.emit(FileChangeType.update.name);

    changeContentSaveState(FileSaveState.saved);
  }

  Future<bool> saveToFile(String title, String content) async {
    var finalText = EditorFileUtils.concatTitleAndText(title, content);
    var finalFile = await _getFile();
    if (finalFile == null) {
      return false;
    }
    await FileManager.instance.tryWriteFileByFile(finalFile, finalText);
    return true;
  }

  Future<File?> _getFile() async {
    if (file != null) {
      return file!;
    }
    ZLog.d(_tag, "_checkFile, file=null");
    return null;
  }
}