
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';

import 'backup_operation_info.dart';

class DataBackupViewModel extends BaseViewModel {
  static final _tag = "DataBackupViewModel";

  bool canPop = true;

  // 分批加载的文本列表。
  MutableState<List<BackupOperationInfo>> supportOperationList = MutableState(<BackupOperationInfo>[]);

  MutableState<BackupOperationInfo> selectedOperation = MutableState(BackupOperationInfo());

  MutableState<OperationState> operationState = MutableState(OperationState.idle);

  MutableState<int> operationProgress = MutableState(0);

  /// 初始化 -> discoverPeers -> requestPeers。
  Future<void> init() async {
    supportOperationList.value = [
      BackupOperationInfo(
        operationType: OperationType.backup,
        title: Strings.backupData,
        desc: Strings.backupDataDesc,
      ),
      BackupOperationInfo(
        operationType: OperationType.restore,
        title: Strings.restoreData,
        desc: Strings.restoreDataDesc,
      ),
    ];
    selectedOperation.value = supportOperationList.value.first;
  }

  void updateProgress(int newProgress) {
    int value = newProgress;
    if (value < 0) {
      value = 0;
    } else if (value > 100) {
      value = 100;
    }
    operationProgress.value = value;
  }

  Future<void> syncData() async {

  }
}