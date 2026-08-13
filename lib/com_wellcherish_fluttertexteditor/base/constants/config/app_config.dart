import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/config/default_config.dart';

class AppConfig {
  /**
   * 文件列表页中展示的标题的数量。
   * */
  static int titleTextLength = DefaultConfig.titleTextLength;
  /**
   * 是否将标题作为文件名。
   * */
  static bool titleIsFileName = DefaultConfig.titleIsFileName;
  /**
   * 编辑文件时，自动保存文件的时间间隔，单位秒。
   * */
  static int editorAutoSaveDuration = DefaultConfig.editorAutoSaveDuration;
  /**
   * 编辑器保存字符数量时，是否忽略首尾空格。
   * */
  static final bool editorSaveTrimText = DefaultConfig.editorSaveTrimText;
}
