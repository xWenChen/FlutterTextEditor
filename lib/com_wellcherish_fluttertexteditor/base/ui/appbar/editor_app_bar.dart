
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/router/app_router.dart';
import '../../../resource/sizes.dart';
import '../../../resource/strings.dart';
import '../../extension/build_context_extension.dart';
import 'appbar_settings_item.dart';

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? backgroundColor;
  final Widget? leading;
  final Widget? title;
  final bool centerTitle;
  final List<Widget>? actions;

  const EditorAppBar({
    super.key,
    required this.backgroundColor,
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
        iconSize: Sizes.appbarIcon,
        icon: Icon(
          Icons.arrow_back_rounded,
          color: context.colorScheme.onPrimaryContainer,
        ),
        onPressed: () async => AppRouter.handleBack(context),
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
    );
  }

  /// 必须重写这个 get 方法，告诉系统高度。kToolbarHeight 是 Flutter 定义的默认导航栏高度（通常是 56.0）
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
