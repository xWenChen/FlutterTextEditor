
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension ThemeContext on BuildContext {
  // 顺便也可以把常用的 colorScheme 和 textTheme 加上，以后更方便
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  CardThemeData get cardTheme => Theme.of(this).cardTheme;
  GoRouter get goRouter => GoRouter.of(this);
}