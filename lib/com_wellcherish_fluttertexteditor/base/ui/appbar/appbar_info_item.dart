
import 'package:flutter/material.dart';

import '../../../resource/sizes.dart';
import '../../extension/build_context_extension.dart';

class AppbarInfoItem extends StatelessWidget {
  final String pageName;

  const AppbarInfoItem({
    super.key,
    required this.pageName,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: Sizes.appbarIcon,
      icon: Icon(
        Icons.help_rounded,
        color: context.contentColor,
      ),
      onPressed: () => context.goRouter.pushNamed(pageName),
    );
  }
}