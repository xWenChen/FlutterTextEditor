
class DefaultConfig {
  /**
   * 标题的最大字符数量。
   * */
  static final int titleTextLength = 20;
  /**
   * 是否将标题作为文件名。
   * */
  static final bool titleIsFileName = false;
  /**
   * 编辑文件时，自动保存文件的时间间隔，单位秒。
   * */
  static final int editorAutoSaveDuration = 5;
  /**
   * 编辑器保存字符数量时，是否忽略首尾空格。
   * */
  static final bool editorSaveTrimText = false;
  /**
   * 列表数据，标题可以展示的行数。
   * */
  static final int listTitleLines = 1;
  /**
   * 列表数据，文本可以展示的行数。
   * */
  static final int listTextLines = 2;
}