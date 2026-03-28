
/// 应用的加载状态
enum LoadState {
  none,
  /// 加载中。
  loading,
  /// 加载完成。
  completed,
  /// 加载失败。
  error,
}