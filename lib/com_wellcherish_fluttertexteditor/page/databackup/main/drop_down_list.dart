
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/constants/material3/app_shapes.dart';

import '../../../base/constants/material3/app_size.dart';
import '../../../base/constants/material3/app_space.dart';
import '../../../base/extension/build_context_extension.dart';

/// 辅助模型，用于定义下拉项的显示文本与对应的值
class DropdownMenuItemModel<T> {
  final T value;
  final String label;

  const DropdownMenuItemModel({
    required this.value,
    required this.label,
  });
}

class DropDownList<T> extends StatefulWidget {
  final void Function(T?)? onChange;
  final T? selectedValue;
  final List<DropdownMenuItemModel<T>> items;

  const DropDownList({
    super.key,
    required this.items,
    required this.selectedValue,
    this.onChange,
  });

  @override
  State<DropDownList<T>> createState() => _DropDownListState<T>();
}

class _DropDownListState<T> extends State<DropDownList<T>> {
  bool _isOpen = false;
  // 把页面上的“锚点按钮”和悬浮的“下拉菜单”紧紧绑定在一起，让下拉菜单能够实时追踪按钮的位置
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    // 这两行代码非常关键，它的核心作用是：“获取当前按钮在屏幕上实际的宽高（特别是高度和宽度）
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => _DropdownOverlay<T>(
        layerLink: _layerLink,
        width: size.width,
        height: size.height,
        items: widget.items,
        selectedValue: widget.selectedValue,
        onSelected: (value) {
          widget.onChange?.call(value);
          _closeDropdown();
        },
        onDismiss: _closeDropdown,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = widget.items.cast<DropdownMenuItemModel<T>?>().firstWhere(
          (item) => item?.value == widget.selectedValue,
      orElse: () => null,
    );
    final displayText = currentItem?.label ?? '';

    // CompositedTransformTarget 是锚点组件。
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        child: GestureDetector(
          onTap: _toggleDropdown,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.extraSmall,
              vertical: AppSpace.extraSmallS,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppShapes.small),
              border: Border.all(
                color: context.colorScheme.outline,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    displayText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: context.textTheme.bodyLarge?.copyWith(
                      color: context.contentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.extraSmallS),
                Image.asset(
                  'assets/images/ic_arrow_up_down.png', // 你的上箭头图片路径
                  width: AppSize.smallIcon,
                  height: AppSize.smallIcon,
                  color: context.contentColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 抽离出来的独立下拉浮层组件
class _DropdownOverlay<T> extends StatelessWidget {
  final LayerLink layerLink;
  final double width;
  final double height;
  final List<DropdownMenuItemModel<T>> items;
  final T? selectedValue;
  final ValueChanged<T> onSelected;
  final VoidCallback onDismiss;

  const _DropdownOverlay({
    required this.layerLink,
    required this.width,
    required this.height,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 点击空白处关闭
        ModalBarrier(
          color: Colors.transparent,
          dismissible: true,
          onDismiss: onDismiss,
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, height + 4), // 高度上偏移4个像素
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppShapes.small),
            color: context.widgetBackground,
            child: Container(
              width: width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppShapes.small),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = item.value == selectedValue;

                  return InkWell(
                    onTap: () => onSelected(item.value),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.extraSmall,
                        vertical: AppSpace.extraSmallS,
                      ),
                      child: Text(
                        item.label,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: isSelected
                              ? context.contentColor
                              : context.colorScheme.secondary,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}