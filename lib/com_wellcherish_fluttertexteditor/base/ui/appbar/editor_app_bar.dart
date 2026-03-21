
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/router/app_router.dart';
import '../../../resource/strings.dart';
import 'AppBarSettingsItem.dart';

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? title;
  final bool centerTitle;
  final List<Widget>? actions;

  const EditorAppBar({
    super.key,
    this.backgroundColor,
    this.leading,
    this.title,
    this.centerTitle = false,
    this.actions
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      leading: leading ?? IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () async => AppRouter.handleBack(context),
      ),
      title: title ?? const Text(Strings.appName),
      centerTitle: centerTitle,
      actions: actions ?? [
        AppBarSettingsItem()
      ],
    );
  }

  /// 必须重写这个 get 方法，告诉系统高度。kToolbarHeight 是 Flutter 定义的默认导航栏高度（通常是 56.0）
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
