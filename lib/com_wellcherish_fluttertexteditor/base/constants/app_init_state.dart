
/// 应用的初始化状态
enum AppInitState {
  none,
  /// 初始化中。
  running,
  /// 初始化完成。
  completed,
  /// 初始化失败。
  error,
}