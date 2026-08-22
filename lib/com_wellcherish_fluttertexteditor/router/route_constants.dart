/// 用于存储所有路由常量
library;

class RouteConstants {
  /// go_router 顶级路由，必须由 / 开头
  static const String schema = "/texteditor/";
  /// 闪屏页，应用启动时第一个加载的页面，会做些初始化的动作。
  static const String splash = "splash";
  /// 首页
  static const String home = "home";
  /// 编辑页
  static const String editor = "editor";
  static const String editorParamContentId = "contentId";
  /// 设置页
  static const String settings = "setting";
}