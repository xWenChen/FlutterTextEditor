
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/databackup/main/backup_operation_info.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/databackup/main/drop_down_list.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/databackup/main/text_progress_bar.dart';

import '../../../base/arch/base_state.dart';
import '../../../base/constants/material3/app_space.dart';
import '../../../base/extension/build_context_extension.dart';
import '../../../base/ui/appbar/editor_app_bar.dart';
import '../../../resource/strings.dart';
import '../../../router/app_router.dart';
import 'data_backup_view_model.dart';

/// 数据搬家说明文档页面
class DataBackupPage extends StatefulWidget {
  const DataBackupPage({super.key});

  @override
  State<DataBackupPage> createState() => _DataBackupPageState();
}

class _DataBackupPageState extends BaseState<DataBackupViewModel, DataBackupPage> {
  @override
  void createViewModel() {
    viewModel = DataBackupViewModel();
    viewModel.init();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: EditorAppBar(
          title: Strings.dataBackupTitle,
          handleBack: () async {
            AppRouter.handleBack(context);
          },
          actions: () => <Widget>[],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpace.medium,
            vertical: AppSpace.large80,
          ),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 进度条。
              Container(
                padding: EdgeInsets.all(AppSpace.small),
                child: ListenableBuilder(
                  listenable: Listenable.merge([viewModel.operationProgress, viewModel.operationState]),
                  builder: (context, child) => TextProgressBar(progress: viewModel.operationProgress.value),
                ),
              ),
              // 操作。
              Container(
                padding: EdgeInsets.all(AppSpace.small),
                child: ListenableBuilder(
                  listenable: Listenable.merge([viewModel.supportOperationList, viewModel.selectedOperation]),
                  builder: (context, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Strings.selectOperation,
                            style: context.textTheme.bodyLarge?.copyWith(
                              color: context.contentColor,
                            ),
                          ),
                          DropDownList(
                            items: viewModel.supportOperationList.value.map((BackupOperationInfo item) {
                              return DropdownMenuEntry<BackupOperationInfo>(
                                value: item,
                                label: item.title, // 直接传入字符串文本
                                labelWidget: Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis, // 超出时自动显示 "..."
                                ),
                              );
                            }).toList(),
                            selectedValue: viewModel.selectedOperation.value,
                            onChange: (BackupOperationInfo? newValue) {
                              if (newValue != null) {
                                viewModel.selectedOperation.value = newValue;
                              }
                            },
                          ),
                        ],
                      ),
                      Text(
                        viewModel.selectedOperation.value.desc,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: context.colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
              ),
              ),
              // 开始按钮。
              Container(
                padding: EdgeInsets.all(AppSpace.small),
                child: ListenableBuilder(
                  listenable: viewModel.operationState,
                  builder: (context, child) {
                    final state = viewModel.operationState.value;
                    final syncing = state == OperationState.inBackup || state == OperationState.inRestore;
                    return SizedBox(
                      width: 200.0,
                      child: FilledButton(
                        // 同步中，onPressed置为null，按钮变为disable态。
                        onPressed: syncing ? null : () {
                          // 开始进行动作
                          viewModel.syncData();
                        },
                        child: Text(
                          Strings.start,
                          style: context.textTheme.titleMedium?.copyWith(
                            color: context.widgetBackground,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        backgroundColor: context.appBackground,
      ),
    );
  }
}