import 'package:logger/logger.dart';

class ZLog {
  static final ZLog _instance = ZLog._internal();
  late Logger logger;

  ZLog._internal() {
    // 在私有构造函数里进行初始化配置
    logger = Logger(
      printer: PrettyPrinter(
          dateTimeFormat: DateTimeFormat.dateAndTime
      ),
    );
  }

  factory ZLog() => _instance;

  // 静态快捷方法，调用更方便：Log.d("message")
  static void d(String tag, String message) {
    ZLog().logger.d("[$tag] $message}");
  }
  static void w(String tag, String message) {
    ZLog().logger.w("[$tag] $message}");
  }
  static void e(String tag, [String? message, dynamic error, StackTrace? stackTrace]) {
    ZLog().logger.e("[$tag] ${message ?? ""}", error: error, stackTrace: stackTrace);
  }
}