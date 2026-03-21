import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';

import '../router/app_router.dart';

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    var color = Colors.lightGreen;
    return MaterialApp.router(
      routerConfig: AppRouter.router, // 注入我们写好的配置
      title: Strings.appName,
      // 亮色主题
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.light,
        ),
      ),
      // 深色主题 - 基于相同的 seedColor 自动生成深色版本
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: color,
          brightness: Brightness.dark,  // 关键：指定深色亮度
        ),
      ),
    );
  }
}