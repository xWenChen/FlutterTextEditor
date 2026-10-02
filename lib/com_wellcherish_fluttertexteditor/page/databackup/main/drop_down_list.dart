
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_shapes.dart';

import '../../../base/constants/material3/app_space.dart';
import '../../../base/extension/build_context_extension.dart';

class DropDownList<T> extends StatefulWidget {

  final void Function(T?)? onChange;
  final T selectedValue;
  final List<DropdownMenuEntry<T>> items;

  DropDownList({
    required this.items,
    required this.selectedValue,
    this.onChange = null,
  });

  @override
  State<DropDownList> createState() => _DropDownListState<T>();
}

class _DropDownListState<T> extends State<DropDownList<T>> {

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      width: 90,
      initialSelection: widget.selectedValue,
      showTrailingIcon: false, // 文本离右侧图标太远了，会导致overflow，使用自定义的方案。
      expandedInsets: null, // 设置为 null 即为不撑满宽度（对应 isExpanded: false）
      dropdownMenuEntries: widget.items, // 需确保类型为 List<DropdownMenuEntry<T>>
      onSelected: widget.onChange,
      textStyle: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.secondary,
      ),
      // 通过 inputDecorationTheme 调整外部边框与文字的边距
      inputDecorationTheme: InputDecorationTheme(
        isDense: true, // 开启紧凑模式，消除默认的大高度 padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpace.extraSmall, // 左右边距：文字离左右边框的距离
          vertical: AppSpace.extraSmallS,    // 上下边距：文字离上下边框的距离
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppShapes.small),
        ),
      ),
    );
  }
}