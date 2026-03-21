
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../router/app_router.dart';
import '../../../router/route_constants.dart';

class AppBarSettingsItem extends StatelessWidget {
  const AppBarSettingsItem({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings_rounded),
      onPressed: ()  => AppRouter.goSettingsPage(context),
    );
  }
}