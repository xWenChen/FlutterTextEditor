
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/router/app_router.dart';
import '../../../resource/sizes.dart';
import '../../../resource/strings.dart';
import '../../extension/build_context_extension.dart';
import 'appbar_settings_item.dart';

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Future<void> Function()? handleBack;

  const EditorAppBar({
    super.key,
    this.leading,
    this.title,
    this.centerTitle = false,
    this.actions,
    this.handleBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.colorScheme.primaryContainer,
      leading: leading ?? IconButton(
        iconSize: Sizes.appbarIcon,
        icon: Icon(
          Icons.arrow_back_rounded,
          color: context.colorScheme.onPrimaryContainer,
        ),
        onPressed: handleBack ?? () async => AppRouter.handleBack(context),
      ),
      title: title ?? Text(
        Strings.appName,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: context.colorScheme.onPrimaryContainer,
        ),
      ),
      centerTitle: centerTitle,
      actions: actions ?? [
        AppBarSettingsItem()
      ],
      titleSpacing: 0,
      /// 禁用在滚动内容时，自动触发的“抬升”效果。
      /// 即使你没有显式设置，AppBar 也会改变背景颜色，混合一种叫 surfaceTintColor 的颜色，使得背景看起来变深或变色。
      /// 表现出来的效果就是标题栏变色，金禁用后标题栏不会变色。
      surfaceTintColor: Colors.transparent, // 禁用自动变色
      scrolledUnderElevation: 0,            // 禁用滚动时的阴影/深度效果
    );
  }

  /// 必须重写这个 get 方法，告诉系统高度。kToolbarHeight 是 Flutter 定义的默认导航栏高度（通常是 56.0）
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
