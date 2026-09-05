extension StringExtension on String? {
  bool get isNullOrEmpty => (this == null) || (this!.isEmpty);

  String ifEmpty(String defaultText) {
    if (this.isNullOrEmpty) {
      return defaultText;
    }
    return this!;
  }
}