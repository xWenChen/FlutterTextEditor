
typedef EventCallback = bool Function(String type);

class EventManager {
  // Key 为 事件类型，Value 为 该事件下的监听函数列表
  static final _listeners = <String, List<EventCallback>>{};

  static void register(String type, EventCallback callback) {
    _listeners[type] ??= [];
    if (!(_listeners[type]?.contains(callback) ?? false)) {
      _listeners[type]!.add(callback);
    }
  }

  static void unregister(String type, EventCallback callback) {
    _listeners[type]?.remove(callback);
  }

  // 触发通知
  static void emit(String type) {
    _listeners[type]?.forEach((callback) {
      callback(type);
    });
  }
}