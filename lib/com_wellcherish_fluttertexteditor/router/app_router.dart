/// 核心配置文件，包含逻辑拦截。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/log/log.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/colors/color_scheme_example.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/detail/data_sync_detail_page.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/data_sync_wifi_p2p_device.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/settings/settings_page.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/splash/splash_page.dart';
import 'package:go_router/go_router.dart';

import '../page/datasync/list/data_sync_list_page.dart';
import '../page/editor/editor_page.dart';
import '../page/home/home_page.dart';
import 'route_constants.dart';

class AppRouter {
  static final _tag = "AppRouter";

  /// 1. 创建全局唯一的 Router 实例
  static final GoRouter router = GoRouter(
    initialLocation: "${RouteConstants.schema}${RouteConstants.home}",
    /// 3. 统一注册路由映射
    routes: [
      GoRoute(
        name: RouteConstants.splash,
        path: "${RouteConstants.schema}${RouteConstants.splash}",
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        name: RouteConstants.home,
        path: "${RouteConstants.schema}${RouteConstants.home}",
        pageBuilder: (context, state) => const NoTransitionPage(
          // 👈 禁用转场动画
          child: const HomePage(),
        ),
      ),
      GoRoute(
        name: RouteConstants.editor,
        path: "${RouteConstants.schema}${RouteConstants.editor}",
        builder: (context, state) {
          // 从 queryParameters 中提取 contentId，如果 URL 没带 ?contentId=xxx 则为 null
          final contentId = state.uri.queryParameters[RouteConstants.editorParamContentId];

          // 如果想要兼顾 extra 传递默认对象，也可以这样取：
          // final initialData = state.extra as FileData?;

          return EditorPage(
            contentId: contentId, // null 表示新建，有值表示编辑
          );
        },
      ),
      GoRoute(
        name: RouteConstants.settings,
        path: "${RouteConstants.schema}${RouteConstants.settings}",
        builder: (context, state) {
          return SettingsPage();
        },
      ),
      GoRoute(
        name: RouteConstants.colorSchemaExample,
        path: "${RouteConstants.schema}${RouteConstants.colorSchemaExample}",
        builder: (context, state) {
          return ColorSchemeExample();
        },
      ),
      GoRoute(
        name: RouteConstants.dataSyncList,
        path: "${RouteConstants.schema}${RouteConstants.dataSyncList}",
        builder: (context, state) {
          return DataSyncListPage();
        },
      ),
      GoRoute(
        name: RouteConstants.dataSyncDetail,
        path: "${RouteConstants.schema}${RouteConstants.dataSyncDetail}",
        builder: (context, state) {
          // 1. 从 state.extra 取出对象并强转
          final device = state.extra as DataSyncWifiP2pDevice;
          return DataSyncDetailPage(currentDevice: device,);
        },
      ),
    ],

    /// 4. 全局重定向（路由守卫）
    /*redirect: (context, state) {
      final bool loggedIn = false; // 假设从 Provider/Bloc 获取登录状态
      final bool loggingIn = state.matchedLocation == AppRoutes.login;

      if (!loggedIn && !loggingIn) return AppRoutes.login; // 没登录且不在登录页，强制跳转
      if (loggedIn && loggingIn) return AppRoutes.home; // 已登录还想去登录页，遣返首页

      return null; // 不重定向
    },*/

    /// 跳转页面
    /// 1. 声明式跳转（会替换当前栈，适合底部导航切换）
    /// context.go(AppRoutes.home);

    /// 2. 编程式压栈（往上盖一层，有返回按钮）
    /// context.push(AppRoutes.login);

    /// 3. 通过名称跳转（推荐，不用关心 URL 怎么拼）
    /// context.pushNamed('detail', pathParameters: {'id': '99'});

    /// 4. 传递复杂对象
    /// 发送
    /// context.push(AppRoutes.detail, extra: {'title': '商品详情', 'price': 100});
    /// 接收 (在 GoRoute 的 builder 中获取)
    /// final data = state.extra as Map;
  );

  /// 处理返回按钮
  static Future<void> handleBack(BuildContext context) async {
    // 1. 优先触发 Navigator 的 Pop 尝试（会优先走 PopScope 拦截逻辑）
    final didPop = await Navigator.maybePop(context);

    // 2. 如果已成功触发 PopScope 逻辑，或页面已被普通 Pop 弹出，直接返回
    if (didPop) return;

    // 3. 判断是否可以返回 (GoRouter 的判断方式)
    await handleBackDirectly(context);
  }

  /// 处理返回按钮
  static Future<void> handleBackDirectly(BuildContext context) async {
    // 3. 判断是否可以返回 (GoRouter 的判断方式)
    final router = GoRouter.of(context);
    if (router.canPop()) {
      // 直接返回上一页
      router.pop();
    } else {
      ZLog.d(_tag, "exit text editor!");
      // 如果已经在路由最底层，退出应用
      await SystemNavigator.pop();
    }
  }

  /// 跳转设置页
  static Future<void> goSettingsPage(BuildContext context) async {
    ZLog.d(_tag, "go settings page!");
    await context.goRouter.pushNamed(RouteConstants.settings);
  }
}