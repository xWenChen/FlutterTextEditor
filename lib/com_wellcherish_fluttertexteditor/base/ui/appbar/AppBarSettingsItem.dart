
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/extension/BuildContextExtension.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/sizes.dart';
import '../../../router/app_router.dart';

class AppBarSettingsItem extends StatelessWidget {
  const AppBarSettingsItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: Sizes.appbarIcon,
      icon: Icon(
        Icons.settings_rounded,
        color: context.colorScheme.onPrimaryContainer,
      ),
      onPressed: ()  => AppRouter.goSettingsPage(context),
    );
  }
}