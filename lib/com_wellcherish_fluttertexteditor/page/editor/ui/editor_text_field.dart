
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/build_context_extension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/string_extension.dart';

class EditorTextField extends StatefulWidget {
  final String? hint;
  /// 保存时，是否去除首尾的最大数量限制。
  final bool saveTrimText;
  /// 最大行数限制。
  final int? maxTextLines;
  /// 为空时，不设置最大数量限制。
  final int? maxTextLength;
  /// 是否使用最大尺寸？
  final bool expanded;
  final bool showSuffixIcon;
  final TextStyle? textStyle;
  final TextEditingController? controller;
  final ScrollController? scrollController;

  EditorTextField({
    super.key,
    this.hint,
    this.maxTextLines,
    this.saveTrimText = true,
    this.maxTextLength,
    this.textStyle,
    this.controller,
    this.scrollController,
    this.expanded = false,
    this.showSuffixIcon = false,
  });

  @override
  State<EditorTextField> createState() => _EditorTextFieldState();
}

class _EditorTextFieldState extends State<EditorTextField> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final heightMatchParent = widget.expanded;
    return TextField(
      controller: controller,
      scrollController: widget.scrollController,
      style: widget.textStyle,
      expands: heightMatchParent,
      // 最大字数限制，为空则不限制，按字符计算。
      maxLength: heightMatchParent ? null : widget.maxTextLength,
      minLines: heightMatchParent ? null : 1,
      // 需求 4：行数控制
      // 如果 maxLines 为 1，TextField 会自动水平滚动
      // 如果 maxLines > 1，TextField 会在内容超标时向下滚动
      maxLines: widget.maxTextLines,
      textAlignVertical: TextAlignVertical.top, // 让文字从顶部开始输入
      decoration: InputDecoration(
        // 关键：禁用字数显示
        counterText: "",
        // 背景色。
        fillColor: context.appBackground,
        // Hint 提示
        hintText: widget.hint,
        border: InputBorder.none,//const OutlineInputBorder(),
        // 如果为空，返回 null；如果不为空，展示清除按钮。
        suffixIcon: widget.showSuffixIcon && controller?.text.isNullOrEmpty != true ? IconButton(
          icon: const Icon(Icons.cancel_rounded),
          onPressed: () {
            controller?.clear(); // 点击清空内容
          },
        ) : null,
      ),
    );
  }
}