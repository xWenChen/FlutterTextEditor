/// 核心配置文件，包含逻辑拦截。
library;

import 'package:go_router/go_router.dart';

import '../home/home_page.dart';
import 'app_routes.dart';

class AppRouter {
  /// 1. 创建全局唯一的 Router 实例
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    /// 2. 调试配置（可选）
    debugLogDiagnostics: true,
    /// 3. 统一注册路由映射
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      /*GoRoute(
        path: AppRoutes.editor,
        builder: (context, state) => const EditorPage(),
      ),
      // 带参数的路由, :id是占位符
      GoRoute(
        path: '${AppRoutes.setting}/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!; // 获取路径参数
          final extraData = state.extra as Map?; // 获取复杂对象参数
          return DetailPage(id: id, extra: extraData);
        },
      ),*/
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
}