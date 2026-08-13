import 'dart:io';

extension FileContentExtension on File? {

  // 获取绝对路径。
  String? get absolutePath => this?.absolute.path;

  /// 获取文件标题
  String? getFileTitle() {
    if (this == null) return null;
    // 这里的 FILE_NAME_SPLIT 请根据你原有的常量定义（如 "_" 或 "."）
    const String fileNameSplit = "_";

    // 获取文件名（包含后缀）
    String fileName = this!.path.split(Platform.pathSeparator).last;
    return fileName.split(fileNameSplit).first;
  }
}