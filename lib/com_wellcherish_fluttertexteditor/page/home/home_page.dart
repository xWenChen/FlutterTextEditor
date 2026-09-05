
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/bean/file_data.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/file_change_type.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_size.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_space.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/appbar/editor_app_bar.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/state_widget/empty_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/state_widget/loading_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/utils/EventManager.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/home/home_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/home/ui/file_list_view.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/sizes.dart';

import '../../base/constants/load_state.dart';
import '../../base/extension/build_context_extension.dart';
import '../../resource/strings.dart';
import '../../router/route_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends BaseState<HomeViewModel, HomePage> {

  late final AppLifecycleListener _lifecycleListener;
  bool _isResumed = true; // 记录 App 是否在前台，在前台才刷新页面。
  bool _needRefresh = false; // 记录后台期间是否有新通知
  late final updateCallback = _listenUpdateEvent;
  late final insertCallback =_listenUpdateEvent;
  late final Listenable _mergedListState;


  @override
  void createViewModel() {
    viewModel =  HomeViewModel();
    viewModel.init();
    _mergedListState = Listenable.merge([viewModel.dataList, viewModel.isSelectionMode]);
    _listenDataChanged();

  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    EventManager.unregister(FileChangeType.update.name, updateCallback);
    EventManager.unregister(FileChangeType.added.name, insertCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fabSize = AppSize.fabSize;
    final addIconSize = fabSize - AppSpace.large;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        viewModel.tryPop(context, didPop, result);
      },
      child: Scaffold(
        appBar: EditorAppBar(
          listenable: viewModel.isSelectionMode,
          actions: () {
            // actions 的构建需要放到Listenable 内部。
            return viewModel.isSelectionMode.value ? [
              IconButton(
                iconSize: Sizes.appbarIcon,
                icon: Icon(
                  Icons.delete_forever_rounded,
                  color: context.colorScheme.onPrimaryContainer,
                ),
                onPressed: () async => viewModel.tryDeleteSelectedItems(context),
              ),
            ] : null;
          },
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([viewModel.state, _mergedListState]),
          builder: (context, child) {
            switch (viewModel.state.value) {
              case LoadState.completed:
                // 展示列表
                return Container(
                  padding: EdgeInsets.only(
                    top: AppSpace.extraSmall,
                    bottom: AppSpace.medium,
                    left: AppSpace.medium,
                    right: AppSpace.medium,
                  ),
                  child: FileListView(
                    fileDataList: viewModel.dataList.value,
                    isSelectionMode: viewModel.isSelectionMode.value,
                    onItemTap:
                        (fileData, index, isSelectionMode, itemSelected) =>
                        onItemTap(
                            fileData, index, isSelectionMode, itemSelected),
                    onItemLongPress:
                        (fileData, index, isSelectionMode, itemSelected) =>
                        onItemLongPress(
                            fileData, index, isSelectionMode, itemSelected),
                  ),
                );
              case LoadState.empty:
                return EmptyView();
              case LoadState.error:
                return EmptyView(
                  text: Strings.dataError,
                );
              default:
                return LoadingView(
                  text: Strings.dataLoading,
                );
            }
          },
        ),
        floatingActionButtonLocation: CustomFabLocation(),
        floatingActionButton: SizedBox(
          width: fabSize,
          height: fabSize,
          child: FloatingActionButton(
            onPressed: () {
              /// 进入创建文本文件的页面。
              if (mounted) {
                context.goRouter.pushNamed(RouteConstants.editor);
              }
            },
            shape: CircleBorder(),
            child: Icon(
              Icons.add_rounded,
              size: addIconSize,
            ),
          ),
        ),
        backgroundColor: context.appBackground,
      ),
    );
  }

  void _listenDataChanged() {
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _isResumed = true;
        // 回到前台时，如果后台期间有新通知，补做一次刷新
        if (_needRefresh) {
          _needRefresh = false;
          viewModel.load();
        }
      },
      onPause: () {
        _isResumed = false;
      },
    );

    // 2. 监听全局通知/事件
    EventManager.register(FileChangeType.update.name, updateCallback);
    EventManager.register(FileChangeType.added.name, insertCallback);
  }

  bool _listenUpdateEvent(String type) {
    if (type == FileChangeType.unknown) {
      return false;
    }
    if (_isResumed) {
      // 在前台：直接加载数据
      viewModel.load();
      _needRefresh = false;
    } else {
      // 在后台：只标记，不进行任何网络/UI请求
      _needRefresh = true;
    }
    return true;
  }


  Future<void> onItemTap(FileData? fileData, int index, bool isSelectionMode, bool itemSelected) async {
    if (isSelectionMode) {
      /// 选择模式下，改变item的选中态。
      await viewModel.selectItem(fileData, index, itemSelected);
      return;
    }
    /// 非选择模式，跳转页面。
    context.goRouter.pushNamed(
      RouteConstants.editor,
      queryParameters: {
        RouteConstants.editorParamContentId: fileData?.contentId,
      },
    );
  }

  Future<void> onItemLongPress(FileData? fileData, int index, bool isSelectionMode, bool itemSelected) async {
    if (!isSelectionMode) {
      /// 选择模式下，删除item。
      await viewModel.selectItem(fileData, index, itemSelected);
      return;
    }
    /// 非选择模式，不做处理。
  }
}